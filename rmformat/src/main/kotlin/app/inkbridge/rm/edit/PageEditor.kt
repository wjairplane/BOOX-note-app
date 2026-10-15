package app.inkbridge.rm.edit

import app.inkbridge.rm.io.*
import app.inkbridge.rm.render.PageRenderer
import app.inkbridge.rm.scene.*
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

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
    class AddedStroke(val line: Line, val ox: Float, val oy: Float, val itemId: CrdtId)

    /**
     * Add a stroke drawn at page-space [input] points. Returns the new stroke, or null if the tool
     * isn't a pen or there was no input.
     */
    /** The stroke [addStroke] would add for [input], without adding it (for drawing the stroke live while the pen is still down). */
    fun previewLine(spec: PenSpec, input: List<InputPoint>): AddedStroke? {
        val layer = activeLayer() ?: return null
        val (ox, oy) = renderer.offsetOf(layer)
        val line = StrokeBuilder.build(spec, input, ox, oy) ?: return null
        return AddedStroke(line, ox, oy, CrdtId(0, 0))
    }

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
        return AddedStroke(line, ox, oy, id)
    }

    // ---- erasing ----

    /**
     * Erase every visible stroke that passes within [radius] page units of the dragged [path].
     * Returns how many strokes were removed (one undo step covers them all).
     */
    fun eraseAlong(path: List<Pair<Float, Float>>, radius: Float): Int {
        if (path.isEmpty()) return 0
        val hit = renderer.placedLines().filter { touches(it, path, radius) }
        if (hit.isEmpty()) return 0
        // The eraser takes out only the part of a stroke it passes over: what is left on either side stays as separate strokes.
        val originals = HashSet<CrdtId>()
        val pieces = LinkedHashMap<Group, MutableList<Line>>()
        for (p in hit) {
            val local = path.map { (x, y) -> (x - p.ox) to (y - p.oy) }
            val parts = erasedParts(p.line, local, radius) ?: continue
            originals += p.itemId
            pieces.getOrPut(p.parent) { ArrayList() }.addAll(parts)
        }
        if (originals.isEmpty()) return 0
        var next: List<Block> = blocks.map { b -> if (b is SceneItemBlock && b.blockType == SceneItemBlock.LINE && b.itemId in originals && b.value is Line) tombstone(b) else b }
        for ((layer, lines) in pieces) if (lines.isNotEmpty()) next = appended(next, layer, lines).first
        commit(next)
        return originals.size
    }

    /** What is left of [line] after erasing within [radius] of [path] (both relative to the line's layer); null if nothing was touched. */
    private fun erasedParts(line: Line, path: List<Pair<Float, Float>>, radius: Float): List<Line>? {
        // Densify first so a long segment between two surviving points can still be cut in the middle.
        val step = max(radius * 0.5f, 2f)
        val pts = ArrayList<Point>()
        for ((i, q) in line.points.withIndex()) {
            val n = line.points.getOrNull(i + 1)
            pts += q
            if (n != null) {
                val d = hypot(n.x - q.x, n.y - q.y)
                val k = (d / step).toInt()
                for (j in 1..k) {
                    val t = j / (k + 1f)
                    pts += Point(q.x + (n.x - q.x) * t, q.y + (n.y - q.y) * t, q.speed, q.direction, (q.width + (n.width - q.width) * t).roundToInt(), (q.pressure + (n.pressure - q.pressure) * t).roundToInt())
                }
            }
        }
        val erased = BooleanArray(pts.size) { i ->
            val q = pts[i]
            val r = radius + q.width / 8f
            if (path.size == 1) hypot(q.x - path[0].first, q.y - path[0].second) <= r
            else (0 until path.size - 1).any { distToSegment(q.x, q.y, path[it].first, path[it].second, path[it + 1].first, path[it + 1].second) <= r }
        }
        if (erased.none { it }) return null
        val out = ArrayList<Line>()
        var length = line.startingLength
        var i = 0
        while (i < pts.size) {
            if (erased[i]) { if (i > 0) length += hypot(pts[i].x - pts[i - 1].x, pts[i].y - pts[i - 1].y); i++; continue }
            val start = i
            while (i < pts.size && !erased[i]) i++
            val run = pts.subList(start, i)
            if (run.size >= 2) out += Line(line.tool, line.color, run.toList(), line.thicknessScale, length, line.moveId, line.colorRgba, line.timestamp)
            for (j in start + 1 until i) length += hypot(pts[j].x - pts[j - 1].x, pts[j].y - pts[j - 1].y)
        }
        return out
    }

    /** Erase the strokes with the given ids (one undo step). Returns how many were removed. */
    fun deleteStrokes(ids: Set<CrdtId>): Int {
        val hit = ids.filter { id -> blocks.any { it is SceneItemBlock && it.blockType == SceneItemBlock.LINE && it.itemId == id && it.value is Line } }.toSet()
        if (hit.isEmpty()) return 0
        commit(blocks.map { b -> if (b is SceneItemBlock && b.blockType == SceneItemBlock.LINE && b.itemId in hit && b.value is Line) tombstone(b) else b })
        return hit.size
    }

    /** Erase every visible stroke on the page (one undo step). Returns how many strokes were removed. */
    fun eraseAll(): Int = deleteStrokes(renderer.placedLines().map { it.itemId }.toSet())

    /** Erase every visible stroke on the current layer only (one undo step). Returns how many strokes were removed. */
    fun eraseCurrentLayer(): Int {
        val layer = activeLayer()?.nodeId ?: return 0
        return deleteStrokes(renderer.placedLines().filter { it.parent.nodeId == layer }.map { it.itemId }.toSet())
    }

    // ---- selection ----

    /** A stroke's bounds in page units. */
    class Bounds(val left: Float, val top: Float, val right: Float, val bottom: Float) {
        fun contains(x: Float, y: Float) = x in left..right && y in top..bottom
    }

    /**
     * The visible strokes that mostly lie inside the closed lasso [polygon] (page units): at least half of a stroke's points
     * must be inside it.
     */
    fun selectInside(polygon: List<Pair<Float, Float>>): Set<CrdtId> {
        if (polygon.size < 3) return emptySet()
        return renderer.placedLines().filter { p ->
            val pts = p.line.points
            pts.isNotEmpty() && pts.count { inside(polygon, it.x + p.ox, it.y + p.oy) } * 2 >= pts.size
        }.map { it.itemId }.toSet()
    }

    /** The combined bounds of the given strokes, or null if none of them is on the page. */
    fun boundsOf(ids: Set<CrdtId>): Bounds? {
        var l = Float.MAX_VALUE; var t = Float.MAX_VALUE; var r = -Float.MAX_VALUE; var b = -Float.MAX_VALUE
        var any = false
        for (p in renderer.placedLines()) if (p.itemId in ids) for (q in p.line.points) {
            any = true
            l = min(l, q.x + p.ox); r = max(r, q.x + p.ox); t = min(t, q.y + p.oy); b = max(b, q.y + p.oy)
        }
        return if (any) Bounds(l, t, r, b) else null
    }

    /** Move the given strokes by ([dx], [dy]) page units (one undo step). */
    fun moveStrokes(ids: Set<CrdtId>, dx: Float, dy: Float): Int {
        val hit = ids.filter { id -> blocks.any { it is SceneItemBlock && it.blockType == SceneItemBlock.LINE && it.itemId == id && it.value is Line } }.toSet()
        if (hit.isEmpty() || (dx == 0f && dy == 0f)) return 0
        commit(blocks.map { b ->
            if (b is SceneItemBlock && b.blockType == SceneItemBlock.LINE && b.itemId in hit && b.value is Line) withValue(b, shifted(b.value as Line, dx, dy)) else b
        })
        return hit.size
    }

    /** Copy the given strokes, shifted by ([dx], [dy]); returns the ids of the copies (one undo step). */
    fun duplicateStrokes(ids: Set<CrdtId>, dx: Float, dy: Float): Set<CrdtId> {
        val originals = blocks.filterIsInstance<SceneItemBlock>().filter { it.blockType == SceneItemBlock.LINE && it.itemId in ids && it.value is Line }
        if (originals.isEmpty()) return emptySet()
        val author = primaryAuthor()
        var counter = nextCounter()
        val lastIn = HashMap<CrdtId, CrdtId>() // layer -> last id so far (including the copies added here)
        val added = ArrayList<SceneItemBlock>()
        for (o in originals) {
            val layer = tree[o.parentId]
            val left = lastIn[o.parentId] ?: lastIdIn(layer)
            val id = CrdtId(author, counter++)
            lastIn[o.parentId] = id
            added += SceneItemBlock(SceneItemBlock.LINE, o.parentId, id, left, CrdtId.END_MARKER, 0, shifted(o.value as Line, dx, dy), LINE_ITEM_TYPE)
                .also { it.minVersion = o.minVersion; it.currentVersion = o.currentVersion }
        }
        commit(blocks + added)
        return added.map { it.itemId }.toSet()
    }

    /** A 2D affine map in page units: x' = a x + c y + tx, y' = b x + d y + ty. */
    data class Affine(val a: Float, val b: Float, val c: Float, val d: Float, val tx: Float, val ty: Float) {
        /** How much it scales lengths (for stroke widths). */
        val scale: Float get() = kotlin.math.sqrt(kotlin.math.abs(a * d - b * c))
        companion object { val IDENTITY = Affine(1f, 0f, 0f, 1f, 0f, 0f) }
    }

    /**
     * Apply [m] (in absolute page coordinates) to the given strokes: move, resize or rotate them (one undo step).
     * Stroke widths follow the scale. Returns how many strokes changed.
     */
    fun transformStrokes(ids: Set<CrdtId>, m: Affine): Int {
        if (m == Affine.IDENTITY) return 0
        val offsets = renderer.placedLines().filter { it.itemId in ids }.associate { it.itemId to (it.ox to it.oy) }
        if (offsets.isEmpty()) return 0
        commit(blocks.map { b ->
            if (b is SceneItemBlock && b.blockType == SceneItemBlock.LINE && b.value is Line) {
                val o = offsets[b.itemId]
                if (o != null) withValue(b, transformed(b.value as Line, o.first, o.second, m)) else b
            } else b
        })
        return offsets.size
    }

    private fun transformed(l: Line, ox: Float, oy: Float, m: Affine): Line {
        val k = m.scale
        return Line(
            l.tool, l.color,
            l.points.map { p ->
                val x = p.x + ox; val y = p.y + oy
                p.copy(x = m.a * x + m.c * y + m.tx - ox, y = m.b * x + m.d * y + m.ty - oy, width = (p.width * k).roundToInt().coerceAtLeast(1))
            },
            l.thicknessScale, l.startingLength, l.moveId, l.colorRgba, l.timestamp,
        )
    }

    /** The given strokes as free-standing lines in absolute page coordinates (for a clipboard). */
    fun copyStrokes(ids: Set<CrdtId>): List<Line> =
        renderer.placedLines().filter { it.itemId in ids }.map { shifted(it.line, it.ox, it.oy) }

    /** Paste [lines] (absolute page coordinates), shifted by ([dx], [dy]), onto the current layer; returns the new ids (one undo step). */
    fun pasteStrokes(lines: List<Line>, dx: Float, dy: Float): Set<CrdtId> {
        if (lines.isEmpty()) return emptySet()
        val layer = activeLayer() ?: return emptySet()
        val (ox, oy) = renderer.offsetOf(layer)
        val (blocksWith, ids) = appended(blocks, layer, lines.map { shifted(it, dx - ox, dy - oy) })
        commit(blocksWith)
        return ids
    }

    /** [list] plus [lines] chained after [layer]'s last item; returns the new blocks' ids too. */
    private fun appended(list: List<Block>, layer: Group, lines: List<Line>): Pair<List<Block>, Set<CrdtId>> {
        val author = primaryAuthor()
        var counter = nextCounter()
        var left = lastIdIn(layer)
        val added = ArrayList<SceneItemBlock>()
        for (l in lines) {
            val id = CrdtId(author, counter++)
            added += SceneItemBlock(SceneItemBlock.LINE, layer.nodeId, id, left, CrdtId.END_MARKER, 0, l, LINE_ITEM_TYPE)
                .also { it.minVersion = 2; it.currentVersion = 2 }
            left = id
        }
        return (list + added) to added.map { it.itemId }.toSet()
    }

    private fun shifted(l: Line, dx: Float, dy: Float) = Line(
        l.tool, l.color, l.points.map { it.copy(x = it.x + dx, y = it.y + dy) }, l.thicknessScale, l.startingLength, l.moveId, l.colorRgba, l.timestamp,
    )

    private fun withValue(b: SceneItemBlock, v: Any?) = SceneItemBlock(
        b.blockType, b.parentId, b.itemId, b.leftId, b.rightId, b.deletedLength, v, b.itemType, b.valueExtra, b.extra,
    ).also { it.minVersion = b.minVersion; it.currentVersion = b.currentVersion }

    private fun inside(poly: List<Pair<Float, Float>>, x: Float, y: Float): Boolean {
        var c = false
        var j = poly.size - 1
        for (i in poly.indices) {
            val (xi, yi) = poly[i]; val (xj, yj) = poly[j]
            if ((yi > y) != (yj > y) && x < (xj - xi) * (y - yi) / (yj - yi) + xi) c = !c
            j = i
        }
        return c
    }

    // ---- layers ----

    /** A layer (a group under the page root). [current] is the one new strokes go into. */
    class LayerInfo(val id: CrdtId, val label: String, val visible: Boolean, val current: Boolean)

    /** The page's layers from bottom to top. */
    fun layers(): List<LayerInfo> {
        val groups = tree.root.childItems().filterIsInstance<Group>()
        val cur = activeLayer()?.nodeId
        return groups.mapIndexed { i, g -> LayerInfo(g.nodeId, g.label.value.ifEmpty { "Layer ${i + 1}" }, g.visible.value, g.nodeId == cur) }
    }

    /** Add a layer on top and make it the current one. Returns its id. */
    fun addLayer(label: String): CrdtId {
        val author = primaryAuthor()
        val c = nextCounter()
        val node = CrdtId(0, c)
        val item = CrdtId(0, c + 2)
        val group = Group(node).apply { this.label = Lww(CrdtId(0, c + 1), label) }
        val added = listOf<Block>(
            SceneTreeBlock(node, CrdtId(0, 0), true, SceneTree.ROOT_ID).also { it.minVersion = 1; it.currentVersion = 1 },
            TreeNodeBlock(group).also { it.minVersion = 1; it.currentVersion = 1 },
            SceneItemBlock(SceneItemBlock.GROUP, SceneTree.ROOT_ID, item, lastIdIn(tree.root), CrdtId.END_MARKER, 0, node, 2)
                .also { it.minVersion = 1; it.currentVersion = 1 },
        )
        commit(withCurrentLayer(blocks + added, node, CrdtId(author, c + 3)))
        return node
    }

    fun setCurrentLayer(id: CrdtId) {
        if (layers().none { it.id == id }) return
        commit(withCurrentLayer(blocks, id, CrdtId(primaryAuthor(), nextCounter())))
    }

    fun setLayerVisible(id: CrdtId, visible: Boolean) = editGroup(id) { g, ts -> g.visible = Lww(ts, visible) }

    fun renameLayer(id: CrdtId, label: String) = editGroup(id) { g, ts -> g.label = Lww(ts, label.trim()) }

    /** Remove a layer and its strokes; the last remaining layer can't be removed. Returns false if nothing changed. */
    fun deleteLayer(id: Long, author: Int = 0): Boolean = deleteLayer(CrdtId(author, id))

    fun deleteLayer(id: CrdtId): Boolean {
        val all = layers()
        if (all.size <= 1 || all.none { it.id == id }) return false
        var next = blocks.map { b ->
            if (b is SceneItemBlock && b.blockType == SceneItemBlock.GROUP && b.value == id) tombstone(b) else b
        }
        // If the deleted layer was current, fall back to the topmost remaining visible one.
        if (activeLayer()?.nodeId == id) {
            val fallback = all.filter { it.id != id && it.visible }.lastOrNull() ?: all.first { it.id != id }
            next = withCurrentLayer(next, fallback.id, CrdtId(primaryAuthor(), nextCounter()))
        }
        commit(next)
        return true
    }

    /** Move a layer one step up ([up] = true, towards the top) or down. Returns false at the end of the stack. */
    fun moveLayer(id: CrdtId, up: Boolean): Boolean {
        val order = layers().map { it.id }.toMutableList()
        val i = order.indexOf(id)
        val j = if (up) i + 1 else i - 1
        if (i < 0 || j !in order.indices) return false
        order[i] = order[j].also { order[j] = order[i] }
        // Rewrite the neighbour links of the live layer items so the sequence reads exactly in the new order.
        val itemFor = blocks.filterIsInstance<SceneItemBlock>().filter { it.blockType == SceneItemBlock.GROUP && it.deletedLength == 0 && it.value is CrdtId }.associateBy { it.value as CrdtId }
        val newLeft = HashMap<CrdtId, CrdtId>()
        var prev = CrdtId.END_MARKER
        for (g in order) { val item = itemFor[g] ?: return false; newLeft[item.itemId] = prev; prev = item.itemId }
        commit(blocks.map { b ->
            val left = if (b is SceneItemBlock && b.blockType == SceneItemBlock.GROUP) newLeft[b.itemId] else null
            if (b is SceneItemBlock && left != null) SceneItemBlock(b.blockType, b.parentId, b.itemId, left, CrdtId.END_MARKER, b.deletedLength, b.value, b.itemType, b.valueExtra, b.extra)
                .also { it.minVersion = b.minVersion; it.currentVersion = b.currentVersion } else b
        })
        return true
    }

    /** Move a layer's strokes onto the layer below it and remove the (now empty) layer. Returns false for the bottom layer. */
    fun mergeLayerDown(id: CrdtId): Boolean {
        val all = layers()
        val i = all.indexOfFirst { it.id == id }
        if (i <= 0) return false
        val from = tree[id]; val to = tree[all[i - 1].id]
        val (fx, fy) = renderer.offsetOf(from); val (tx, ty) = renderer.offsetOf(to)
        val originals = blocks.filterIsInstance<SceneItemBlock>().filter { it.blockType == SceneItemBlock.LINE && it.parentId == id && it.deletedLength == 0 && it.value is Line }
        var next: List<Block> = blocks
        if (originals.isNotEmpty()) {
            next = appended(next, to, originals.map { shifted(it.value as Line, fx - tx, fy - ty) }).first
            val gone = originals.mapTo(HashSet()) { it.itemId }
            next = next.map { b -> if (b is SceneItemBlock && b.blockType == SceneItemBlock.LINE && b.itemId in gone && b.value is Line) tombstone(b) else b }
        }
        next = next.map { b -> if (b is SceneItemBlock && b.blockType == SceneItemBlock.GROUP && b.value == id) tombstone(b) else b }
        if (activeLayer()?.nodeId == id) next = withCurrentLayer(next, all[i - 1].id, CrdtId(primaryAuthor(), nextCounter() + originals.size))
        commit(next)
        return true
    }

    /** Whether the page's template / PDF background is shown (it is unless the file says otherwise). */
    val backgroundVisible: Boolean get() = tree.sceneInfo?.backgroundVisible?.value ?: true

    fun setBackgroundVisible(visible: Boolean) {
        if (visible == backgroundVisible) return
        val old = tree.sceneInfo
        val ts = CrdtId(primaryAuthor(), nextCounter())
        val current = old?.currentLayer ?: Lww(ts, activeLayer()?.nodeId ?: return)
        val info = SceneInfoBlock(current, Lww(CrdtId(primaryAuthor(), nextCounter() + 1), visible), old?.rootDocumentVisible, old?.paperSize, old?.extra ?: ByteArray(0))
            .also { it.minVersion = old?.minVersion ?: 0; it.currentVersion = old?.currentVersion ?: 1 }
        commit(if (old != null) blocks.map { if (it === old) info else it } else blocks + info)
    }

    private fun editGroup(id: CrdtId, edit: (Group, CrdtId) -> Unit) {
        val ts = CrdtId(primaryAuthor(), nextCounter())
        var found = false
        val next = blocks.map { b ->
            if (b is TreeNodeBlock && b.group.nodeId == id) {
                found = true
                val old = b.group
                val g = Group(id).apply {
                    label = old.label; visible = old.visible
                    anchorId = old.anchorId; anchorType = old.anchorType; anchorThreshold = old.anchorThreshold; anchorOriginX = old.anchorOriginX
                }
                edit(g, ts)
                TreeNodeBlock(g, b.extra).also { it.minVersion = b.minVersion; it.currentVersion = b.currentVersion }
            } else b
        }
        if (found) commit(next)
    }

    private fun withCurrentLayer(list: List<Block>, id: CrdtId, ts: CrdtId): List<Block> {
        val old = list.filterIsInstance<SceneInfoBlock>().firstOrNull()
        val info = SceneInfoBlock(Lww(ts, id), old?.backgroundVisible, old?.rootDocumentVisible, old?.paperSize, old?.extra ?: ByteArray(0))
            .also { it.minVersion = old?.minVersion ?: 0; it.currentVersion = old?.currentVersion ?: 1 }
        return if (old != null) list.map { if (it === old) info else it } else list + info
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
