package app.inkbridge.rm.edit

import app.inkbridge.rm.io.*
import app.inkbridge.rm.render.PageRenderer
import app.inkbridge.rm.scene.*
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min

/**
 * Editable `.rm` page. Edits operate on the block list, the same representation that is written
 * to disk, so everything the app doesn't touch stays byte-for-byte as the tablet wrote it.
 *
 * New strokes are appended as line blocks chained after the layer's last item; erased strokes are
 * replaced by tombstones (same ids, `deleted_length = 1`, no payload), exactly how the tablet
 * records deletions. New ids use the file's own (first) author with counters above every counter
 * already in the file, so ids can't collide with existing ones.
 */
class PageEditor private constructor(initial: List<Block>) {
    private var blocks: List<Block> = initial
    private var savedBlocks: List<Block> = initial
    private val undoStack = ArrayDeque<List<Block>>()
    private val redoStack = ArrayDeque<List<Block>>()

    var tree: SceneTree = SceneTree.build(blocks)
        private set
    var renderer: PageRenderer = PageRenderer(tree)
        private set

    val canUndo get() = undoStack.isNotEmpty()
    val canRedo get() = redoStack.isNotEmpty()

    /** True when there are changes not yet marked saved via [markSaved]. */
    val isDirty get() = blocks !== savedBlocks

    fun toBytes(): ByteArray = SceneWriter.write(blocks)
    fun markSaved() { savedBlocks = blocks }

    // ---- adding strokes ----

    /** A stroke just added, with the page-space offset of its layer (needed to draw it incrementally). */
    class AddedStroke(val line: Line, val ox: Float, val oy: Float)

    /**
     * Add a stroke drawn at page-space [input] points. Returns the new stroke, or null if the tool
     * isn't a pen or there was no input.
     */
    fun addStroke(spec: PenSpec, input: List<InputPoint>): AddedStroke? {
        val layer = activeLayer() ?: throw IllegalStateException("Page has no layer to draw on")
        val (ox, oy) = renderer.offsetOf(layer)
        val line = StrokeBuilder.build(spec, input, ox, oy) ?: return null

        val author = primaryAuthor()
        val id = CrdtId(author, nextCounter())
        val block = SceneItemBlock(
            blockType = SceneItemBlock.LINE,
            parentId = layer.nodeId,
            itemId = id,
            leftId = lastIdIn(layer),
            rightId = CrdtId.END_MARKER,
            deletedLength = 0,
            value = line,
            itemType = LINE_ITEM_TYPE,
        ).also { it.minVersion = 2; it.currentVersion = 2 }

        commit(blocks + block)
        return AddedStroke(line, ox, oy)
    }

    // ---- erasing ----

    /**
     * Erase every visible stroke that passes within [radius] page units of the dragged [path].
     * Returns how many strokes were removed (one undo step covers them all).
     */
    fun eraseAlong(path: List<Pair<Float, Float>>, radius: Float): Int {
        if (path.isEmpty()) return 0
        val hit = renderer.placedLines().filter { touches(it, path, radius) }.map { it.itemId }.toSet()
        if (hit.isEmpty()) return 0
        val next = blocks.map { b ->
            if (b is SceneItemBlock && b.blockType == SceneItemBlock.LINE && b.itemId in hit && b.value is Line) tombstone(b) else b
        }
        commit(next)
        return hit.size
    }

    /** Erase every visible stroke on the page (one undo step). Returns how many strokes were removed. */
    fun eraseAll(): Int {
        val hit = renderer.placedLines().map { it.itemId }.toSet()
        if (hit.isEmpty()) return 0
        commit(blocks.map { b -> if (b is SceneItemBlock && b.blockType == SceneItemBlock.LINE && b.itemId in hit && b.value is Line) tombstone(b) else b })
        return hit.size
    }

    private fun tombstone(b: SceneItemBlock) = SceneItemBlock(
        blockType = b.blockType, parentId = b.parentId, itemId = b.itemId, leftId = b.leftId, rightId = b.rightId,
        deletedLength = 1, value = null, itemType = null,
    ).also { it.minVersion = b.minVersion; it.currentVersion = b.currentVersion }

    private fun touches(p: PageRenderer.PlacedLine, path: List<Pair<Float, Float>>, radius: Float): Boolean {
        val pts = p.line.points
        if (pts.isEmpty()) return false
        // Cheap reject on the stroke's bounding box before the segment tests.
        var minX = Float.MAX_VALUE; var maxX = -Float.MAX_VALUE; var minY = Float.MAX_VALUE; var maxY = -Float.MAX_VALUE
        for (q in pts) { minX = min(minX, q.x); maxX = max(maxX, q.x); minY = min(minY, q.y); maxY = max(maxY, q.y) }
        minX += p.ox; maxX += p.ox; minY += p.oy; maxY += p.oy
        val r = radius + p.line.thicknessScale.toFloat() * 4
        if (path.all { (x, _) -> x < minX - r || x > maxX + r } || path.all { (_, y) -> y < minY - r || y > maxY + r }) return false

        for ((i, q) in pts.withIndex()) {
            val ax = q.x + p.ox; val ay = q.y + p.oy
            val b = pts.getOrNull(i + 1)
            val bx = (b?.x ?: q.x) + p.ox; val by = (b?.y ?: q.y) + p.oy
            for ((px, py) in path) if (distToSegment(px, py, ax, ay, bx, by) <= r) return true
        }
        return false
    }

    private fun distToSegment(px: Float, py: Float, ax: Float, ay: Float, bx: Float, by: Float): Float {
        val dx = bx - ax; val dy = by - ay
        val len2 = dx * dx + dy * dy
        val t = if (len2 == 0f) 0f else (((px - ax) * dx + (py - ay) * dy) / len2).coerceIn(0f, 1f)
        return hypot(px - (ax + t * dx), py - (ay + t * dy))
    }

    // ---- undo / redo ----

    fun undo(): Boolean {
        val prev = undoStack.removeLastOrNull() ?: return false
        redoStack.addLast(blocks)
        apply(prev)
        return true
    }

    fun redo(): Boolean {
        val next = redoStack.removeLastOrNull() ?: return false
        undoStack.addLast(blocks)
        apply(next)
        return true
    }

    private fun commit(next: List<Block>) {
        undoStack.addLast(blocks)
        if (undoStack.size > MAX_UNDO) undoStack.removeFirst()
        redoStack.clear()
        apply(next)
    }

    private fun apply(next: List<Block>) {
        blocks = next
        tree = SceneTree.build(blocks)
        renderer = PageRenderer(tree)
    }

    // ---- ids and layers ----

    /** The layer new strokes go into: the file's current layer if set, else the topmost visible one. */
    private fun activeLayer(): Group? {
        val layers = tree.root.childItems().filterIsInstance<Group>().filter { it.visible.value }
        val current = tree.sceneInfo?.currentLayer?.value
        return layers.firstOrNull { it.nodeId == current } ?: layers.lastOrNull()
    }

    /** The author the tablet itself wrote with: the lowest author id in the file (1 if the file lists none). */
    private fun primaryAuthor(): Int =
        blocks.filterIsInstance<AuthorIdsBlock>().firstOrNull()?.authors?.keys?.minOrNull() ?: 1

    /** Last id used by [layer]'s sequence; a tombstone with length N spans ids id .. id+N-1. */
    private fun lastIdIn(layer: Group): CrdtId {
        val last = layer.children.orderedItems().lastOrNull() ?: return CrdtId.END_MARKER
        return if (last.deletedLength > 0) CrdtId(last.itemId.author, last.itemId.counter + last.deletedLength - 1) else last.itemId
    }

    private fun nextCounter(): Long = maxCounter(blocks) + 1

    companion object {
        private const val LINE_ITEM_TYPE = 3
        private const val MAX_UNDO = 100

        fun fromBytes(bytes: ByteArray): PageEditor = PageEditor(SceneStream.readBlocks(bytes))

        /** An empty page with a single layer. */
        fun blank(): PageEditor = PageEditor(BlankPage.blocks())

        /** Highest counter of any id appearing in [blocks] (items, tombstone runs, tree nodes, timestamps). */
        fun maxCounter(blocks: List<Block>): Long {
            var m = 0L
            fun see(id: CrdtId?) { if (id != null) m = max(m, id.counter) }
            for (b in blocks) when (b) {
                is SceneItemBlock -> {
                    see(b.itemId); see(b.leftId); see(b.rightId); see(b.parentId)
                    if (b.deletedLength > 0) m = max(m, b.itemId.counter + b.deletedLength - 1)
                    (b.value as? CrdtId)?.let(::see)
                }
                is SceneTreeBlock -> { see(b.treeId); see(b.nodeId); see(b.parentId) }
                is TreeNodeBlock -> b.group.let { g ->
                    see(g.nodeId); see(g.label.timestamp); see(g.visible.timestamp)
                    see(g.anchorId?.timestamp); see(g.anchorId?.value); see(g.anchorType?.timestamp)
                    see(g.anchorThreshold?.timestamp); see(g.anchorOriginX?.timestamp)
                }
                is MigrationInfoBlock -> see(b.migrationId)
                is SceneInfoBlock -> {
                    see(b.currentLayer.timestamp); see(b.currentLayer.value)
                    see(b.backgroundVisible?.timestamp); see(b.rootDocumentVisible?.timestamp)
                }
                is RootTextBlock -> {
                    for (i in b.value.items.sequenceItems) { see(i.itemId); see(i.leftId); see(i.rightId) }
                    for ((k, v) in b.value.styles) { see(k); see(v.timestamp) }
                }
                else -> Unit
            }
            return m
        }
    }
}
