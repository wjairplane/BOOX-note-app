package app.inkbridge.rm.io

import app.inkbridge.rm.scene.*
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.UUID

/** Serialises blocks back to the v6 `.rm` layout. Inverse of [SceneStream.readBlocks]. */
object SceneWriter {

    fun write(blocks: List<Block>): ByteArray {
        val w = TaggedBlockWriter()
        w.writeHeader()
        for (b in blocks) writeBlock(w, b)
        return w.toByteArray()
    }

    private fun writeBlock(w: TaggedBlockWriter, b: Block) {
        when (b) {
            is UnreadableBlock -> w.block(b.blockType, b.minVersion, b.currentVersion, ByteArray(0)) { bytes(b.data) }
            is MigrationInfoBlock -> w.block(SceneStream.BLOCK_MIGRATION_INFO, b.minVersion, b.currentVersion, b.extra) {
                id(1, b.migrationId); bool(2, b.isDevice)
                b.unknown?.let { bool(3, it) }
            }
            is SceneTreeBlock -> w.block(SceneStream.BLOCK_SCENE_TREE, b.minVersion, b.currentVersion, b.extra) {
                id(1, b.treeId); id(2, b.nodeId); bool(3, b.isUpdate)
                subblock(4) { id(1, b.parentId) }
            }
            is TreeNodeBlock -> w.block(SceneStream.BLOCK_TREE_NODE, b.minVersion, b.currentVersion, b.extra) {
                val g = b.group
                id(1, g.nodeId); lwwString(2, g.label); lwwBool(3, g.visible)
                val anchor = g.anchorId
                if (anchor != null) {
                    lwwId(7, anchor)
                    lwwByte(8, checkNotNull(g.anchorType) { "anchor without type" })
                    lwwFloat(9, checkNotNull(g.anchorThreshold) { "anchor without threshold" })
                    lwwFloat(10, checkNotNull(g.anchorOriginX) { "anchor without origin" })
                }
            }
            is AuthorIdsBlock -> w.block(SceneStream.BLOCK_AUTHOR_IDS, b.minVersion, b.currentVersion, b.extra) {
                varUInt(b.authors.size.toLong())
                for ((author, uuid) in b.authors) subblock(0) {
                    varUInt(16); bytes(uuidToLe(uuid)); u16(author)
                }
            }
            is PageInfoBlock -> w.block(SceneStream.BLOCK_PAGE_INFO, b.minVersion, b.currentVersion, b.extra) {
                int(1, b.loadsCount); int(2, b.mergesCount); int(3, b.textCharsCount); int(4, b.textLinesCount)
                b.typeFolioUseCount?.let { int(5, it) }
            }
            is SceneInfoBlock -> w.block(SceneStream.BLOCK_SCENE_INFO, b.minVersion, b.currentVersion, b.extra) {
                lwwId(1, b.currentLayer)
                b.backgroundVisible?.let { lwwBool(2, it) }
                b.rootDocumentVisible?.let { lwwBool(3, it) }
                b.paperSize?.let { intPair(5, it) }
            }
            is RootTextBlock -> w.block(SceneStream.BLOCK_ROOT_TEXT, b.minVersion, b.currentVersion, b.extra) { writeRootText(b) }
            is SceneItemBlock -> w.block(b.blockType, b.minVersion, b.currentVersion, b.extra) { writeSceneItem(b) }
        }
    }

    private fun TaggedBlockWriter.writeSceneItem(b: SceneItemBlock) {
        id(1, b.parentId); id(2, b.itemId); id(3, b.leftId); id(4, b.rightId); int(5, b.deletedLength)
        val type = b.itemType ?: return
        subblock(6, b.valueExtra) {
            u8(type)
            when (val v = b.value) {
                is Line -> writeLine(v, b.currentVersion)
                is GlyphRange -> writeGlyph(v)
                is CrdtId -> id(2, v)
                else -> Unit
            }
        }
    }

    private fun TaggedBlockWriter.writeLine(l: Line, version: Int) {
        require(version == 2) { "Only v2 line blocks can be written (got v$version); convert the block first" }
        int(1, l.tool); int(2, l.color); double(3, l.thicknessScale); float(4, l.startingLength)
        subblock(5) {
            for (p in l.points) { float32(p.x); float32(p.y); u16(p.speed); u16(p.width); u8(p.direction); u8(p.pressure) }
        }
        id(6, l.timestamp)
        l.moveId?.let { id(7, it) }
        l.colorRgba?.let { color(8, it) }
    }

    private fun TaggedBlockWriter.writeGlyph(g: GlyphRange) {
        g.start?.let { int(2, it); int(3, g.length) }
        int(4, g.color)
        string(5, g.text)
        subblock(6) {
            varUInt(g.rectangles.size.toLong())
            for (r in g.rectangles) { float64(r.x); float64(r.y); float64(r.w); float64(r.h) }
        }
        g.colorRgba?.let { color(10, it) }
    }

    private fun TaggedBlockWriter.writeRootText(b: RootTextBlock) {
        id(1, b.blockId)
        val t = b.value
        subblock(2) {
            subblock(1) {
                subblock(1) {
                    val items = t.items.sequenceItems
                    varUInt(items.size.toLong())
                    for (item in items) subblock(0) {
                        id(2, item.itemId); id(3, item.leftId); id(4, item.rightId); int(5, item.deletedLength)
                        when (val v = item.value) {
                            is TextValue.Chars -> if (v.s.isNotEmpty()) string(6, v.s)
                            is TextValue.Format -> stringWithFormat(6, "", v.code)
                        }
                    }
                }
            }
            subblock(2) {
                subblock(1) {
                    varUInt(t.styles.size.toLong())
                    for ((charId, style) in t.styles) {
                        crdtId(charId)
                        id(1, style.timestamp)
                        subblock(2) { u8(17); u8(t.unknownStyleCodes[charId]?.takeIf { style.value == ParagraphStyle.PLAIN } ?: style.value.code) }
                    }
                }
            }
        }
        subblock(3) { float64(t.posX); float64(t.posY) }
        float(4, t.width)
    }

    private fun uuidToLe(u: UUID): ByteArray {
        val hi = u.mostSignificantBits
        val bb = ByteBuffer.allocate(16)
        bb.order(ByteOrder.LITTLE_ENDIAN)
        bb.putInt((hi ushr 32).toInt())
        bb.putShort((hi ushr 16).toShort())
        bb.putShort(hi.toShort())
        bb.order(ByteOrder.BIG_ENDIAN)
        bb.putLong(u.leastSignificantBits)
        return bb.array()
    }
}
