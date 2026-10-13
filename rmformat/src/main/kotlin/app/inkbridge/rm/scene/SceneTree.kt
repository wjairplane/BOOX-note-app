package app.inkbridge.rm.scene

import app.inkbridge.rm.io.*

/** The page scene graph: a root group whose children are layers containing strokes and highlights. */
class SceneTree {
    val root = Group(ROOT_ID)
    private val nodes = HashMap<CrdtId, Group>().also { it[ROOT_ID] = root }
    var sceneInfo: SceneInfoBlock? = null
        private set
    var rootText: Text? = null
        private set

    operator fun contains(id: CrdtId) = id in nodes
    operator fun get(id: CrdtId): Group = nodes.getValue(id)

    /** All leaf items (lines, glyphs) in drawing order, depth-first through layers. */
    fun walk(): List<SceneItem> = buildList { collect(root, this) }

    private fun collect(g: Group, out: MutableList<SceneItem>) {
        for (c in g.childItems()) if (c is Group) collect(c, out) else out += c
    }

    companion object {
        val ROOT_ID = CrdtId(0, 1)

        fun build(blocks: List<Block>): SceneTree {
            val tree = SceneTree()
            for (b in blocks) {
                when (b) {
                    is SceneTreeBlock -> {
                        require(b.treeId !in tree.nodes) { "Node ${b.treeId} already in tree" }
                        tree.nodes[b.treeId] = Group(b.treeId)
                    }
                    is TreeNodeBlock -> {
                        val node = tree.nodes[b.group.nodeId]
                            ?: throw IllegalArgumentException("Node does not exist for TreeNodeBlock: ${b.group.nodeId}")
                        node.label = b.group.label
                        node.visible = b.group.visible
                        node.anchorId = b.group.anchorId
                        node.anchorType = b.group.anchorType
                        node.anchorThreshold = b.group.anchorThreshold
                        node.anchorOriginX = b.group.anchorOriginX
                    }
                    is SceneItemBlock -> tree.addSceneItem(b)
                    is SceneInfoBlock -> tree.sceneInfo = b
                    is RootTextBlock -> tree.rootText = b.value
                    else -> Unit
                }
            }
            return tree
        }
    }

    private fun addSceneItem(b: SceneItemBlock) {
        val value: SceneItem? = when (b.blockType) {
            SceneItemBlock.GROUP -> (b.value as? CrdtId)?.let { nodes[it] ?: throw IllegalArgumentException("Node does not exist for group item: $it") }
            SceneItemBlock.LINE -> b.value as? Line
            SceneItemBlock.GLYPH -> b.value as? GlyphRange
            else -> return // tombstones and text markers carry nothing to draw
        }
        if (b.blockType == SceneItemBlock.GROUP && value == null) return
        val parent = nodes[b.parentId] ?: throw IllegalArgumentException("Parent id not known: ${b.parentId}")
        parent.children.add(CrdtSequenceItem(b.itemId, b.leftId, b.rightId, b.deletedLength, value))
    }
}
