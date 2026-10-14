package app.inkbridge.rm.io

import app.inkbridge.rm.scene.*
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.UUID

/** Reads a reMarkable v6 `.rm` page into blocks and a scene tree. Port of rmscene's `scene_stream`. */
object SceneStream {

    const val BLOCK_MIGRATION_INFO = 0x00
    const val BLOCK_SCENE_TREE = 0x01
    const val BLOCK_TREE_NODE = 0x02
    const val BLOCK_ROOT_TEXT = 0x07
    const val BLOCK_AUTHOR_IDS = 0x09
    const val BLOCK_PAGE_INFO = 0x0A
    const val BLOCK_SCENE_INFO = 0x0D

    /** Parse every block. Blocks that fail to parse come back as [UnreadableBlock] with their raw bytes. */
    fun readBlocks(bytes: ByteArray): List<Block> {
        val reader = TaggedBlockReader(bytes)
        reader.readHeader()
        val blocks = ArrayList<Block>()
        while (true) {
            var extra = ByteArray(0)
            var info: MainBlockInfo? = null
            val start = reader.data.position
            val block = try {
                reader.readBlock({ i ->
                    info = i
                    parseBlock(reader, i).also { it.minVersion = i.minVersion; it.currentVersion = i.currentVersion }
                }, { extra = it })
            } catch (e: Exception) {
                // Resynchronise on the block length so one bad block doesn't lose the page.
                val i = info
                if (i == null) throw IllegalArgumentException("Corrupt block header at $start: ${e.message}", e)
                val raw = reader.rawBlockContent(i)
                UnreadableBlock(i.blockType, raw, e.toString()).also { it.minVersion = i.minVersion; it.currentVersion = i.currentVersion }
            } ?: break
            blocks += if (extra.isNotEmpty() && block !is UnreadableBlock) withExtra(block, extra) else block
        }
        return blocks
    }

    fun readTree(bytes: ByteArray): SceneTree = SceneTree.build(readBlocks(bytes))

    private fun withExtra(b: Block, extra: ByteArray): Block = withExtra0(b, extra).also {
        it.minVersion = b.minVersion; it.currentVersion = b.currentVersion
    }

    private fun withExtra0(b: Block, extra: ByteArray): Block = when (b) {
        is AuthorIdsBlock -> AuthorIdsBlock(b.authors, extra)
        is MigrationInfoBlock -> MigrationInfoBlock(b.migrationId, b.isDevice, b.unknown, extra)
        is PageInfoBlock -> PageInfoBlock(b.loadsCount, b.mergesCount, b.textCharsCount, b.textLinesCount, b.typeFolioUseCount, extra)
        is SceneInfoBlock -> SceneInfoBlock(b.currentLayer, b.backgroundVisible, b.rootDocumentVisible, b.paperSize, extra)
        is SceneTreeBlock -> SceneTreeBlock(b.treeId, b.nodeId, b.isUpdate, b.parentId, extra)
        is TreeNodeBlock -> TreeNodeBlock(b.group, extra)
        is RootTextBlock -> RootTextBlock(b.blockId, b.value, extra)
        is SceneItemBlock -> SceneItemBlock(b.blockType, b.parentId, b.itemId, b.leftId, b.rightId, b.deletedLength, b.value, b.itemType, b.valueExtra, extra)
        is UnreadableBlock -> b
    }

    private fun parseBlock(r: TaggedBlockReader, info: MainBlockInfo): Block = when (info.blockType) {
        BLOCK_MIGRATION_INFO -> {
            val id = r.readId(1)
            val device = r.readBool(2)
            val unknown = if (r.bytesRemainingInBlock() > 0) r.readBool(3) else null
            MigrationInfoBlock(id, device, unknown)
        }
        BLOCK_SCENE_TREE -> {
            val treeId = r.readId(1)
            val nodeId = r.readId(2)
            val isUpdate = r.readBool(3)
            val parent = r.readSubblock(4) { r.readId(1) }
            SceneTreeBlock(treeId, nodeId, isUpdate, parent)
        }
        BLOCK_TREE_NODE -> {
            val g = Group(r.readId(1))
            g.label = r.readLwwString(2)
            g.visible = r.readLwwBool(3)
            if (r.bytesRemainingInBlock() > 0) {
                g.anchorId = r.readLwwId(7)
                g.anchorType = r.readLwwByte(8)
                g.anchorThreshold = r.readLwwFloat(9)
                g.anchorOriginX = r.readLwwFloat(10)
            }
            TreeNodeBlock(g)
        }
        BLOCK_ROOT_TEXT -> readRootText(r)
        BLOCK_AUTHOR_IDS -> {
            val n = r.data.readVarUInt().toInt()
            val map = LinkedHashMap<Int, UUID>()
            repeat(n) {
                r.readSubblock(0) {
                    val len = r.data.readVarUInt().toInt()
                    require(len == 16) { "Expected 16-byte UUID, got $len" }
                    val uuid = uuidFromLe(r.data.readBytes(16))
                    map[r.data.readU16()] = uuid
                }
            }
            AuthorIdsBlock(map)
        }
        BLOCK_PAGE_INFO -> {
            val loads = r.readInt(1)
            val merges = r.readInt(2)
            val chars = r.readInt(3)
            val lines = r.readInt(4)
            val folio = if (r.bytesRemainingInBlock() > 0) r.readInt(5) else null
            PageInfoBlock(loads, merges, chars, lines, folio)
        }
        BLOCK_SCENE_INFO -> {
            val layer = r.readLwwId(1)
            val bg = if (r.bytesRemainingInBlock() > 0) r.readLwwBool(2) else null
            val doc = if (r.bytesRemainingInBlock() > 0) r.readLwwBool(3) else null
            val paper = if (r.bytesRemainingInBlock() > 0 && r.hasSubblock(5)) r.readIntPair(5) else null
            SceneInfoBlock(layer, bg, doc, paper)
        }
        SceneItemBlock.GLYPH, SceneItemBlock.GROUP, SceneItemBlock.LINE,
        SceneItemBlock.TEXT, SceneItemBlock.TOMBSTONE -> readSceneItem(r, info)
        else -> throw IllegalArgumentException("Unknown block type ${info.blockType}")
    }

    private fun readSceneItem(r: TaggedBlockReader, info: MainBlockInfo): SceneItemBlock {
        val parent = r.readId(1)
        val itemId = r.readId(2)
        val left = r.readId(3)
        val right = r.readId(4)
        val deleted = r.readInt(5)
        var value: Any? = null
        var itemType: Int? = null
        var valueExtra = ByteArray(0)
        if (r.hasSubblock(6)) {
            r.readSubblock(6, onExtra = { valueExtra = it }) {
                itemType = r.data.readU8()
                value = when (info.blockType) {
                    SceneItemBlock.GLYPH -> readGlyph(r)
                    SceneItemBlock.GROUP -> r.readId(2)
                    SceneItemBlock.LINE -> readLine(r, info.currentVersion)
                    else -> null
                }
            }
        }
        return SceneItemBlock(info.blockType, parent, itemId, left, right, deleted, value, itemType, valueExtra)
    }

    private fun readPoint(d: RmDataStream, version: Int): Point {
        val x = d.readFloat32()
        val y = d.readFloat32()
        return if (version == 1) {
            // v1 stored floats; convert to v2 integer units like rmscene does.
            val speed = (d.readFloat32() * 4).toInt()
            val direction = (255 * d.readFloat32() / (2 * Math.PI)).toInt()
            val width = Math.round(d.readFloat32() * 4)
            val pressure = (d.readFloat32() * 255).toInt()
            Point(x, y, speed, direction, width, pressure)
        } else {
            val speed = d.readU16()
            val width = d.readU16()
            val direction = d.readU8()
            val pressure = d.readU8()
            Point(x, y, speed, direction, width, pressure)
        }
    }

    private fun readLine(r: TaggedBlockReader, version: Int): Line {
        require(version == 1 || version == 2) { "Unknown line version $version" }
        val tool = r.readInt(1)
        val color = r.readInt(2)
        val thickness = r.readDouble(3)
        val startLen = r.readFloat(4)
        val pointSize = if (version == 1) 0x18 else 0x0E
        val points = r.readSubblock(5) { sub ->
            require(sub.size % pointSize == 0) { "Point data size ${sub.size} is not a multiple of $pointSize" }
            List(sub.size / pointSize) { readPoint(r.data, version) }
        }
        val timestamp = r.readId(6)
        var moveId: CrdtId? = null
        if (r.bytesRemainingInBlock() >= 3 && r.data.checkTag(7, TagType.ID)) moveId = r.readId(7)
        val rgba = r.readColorOptional(8)
        return Line(tool, color, points, thickness, startLen, moveId, rgba, timestamp)
    }

    private fun readGlyph(r: TaggedBlockReader): GlyphRange {
        val start = r.readIntOptional(2)
        val length = r.readIntOptional(3)
        val color = r.readInt(4)
        val text = r.readString(5)
        val rects = r.readSubblock(6) {
            val n = r.data.readVarUInt().toInt()
            List(n) { Rectangle(r.data.readFloat64(), r.data.readFloat64(), r.data.readFloat64(), r.data.readFloat64()) }
        }
        val rgba = r.readColorOptional(10)
        return GlyphRange(start, length ?: text.length, text, color, rects, rgba)
    }

    private fun readRootText(r: TaggedBlockReader): RootTextBlock {
        val blockId = r.readId(1)
        require(blockId == CrdtId.END_MARKER) { "Unexpected root text block id $blockId" }
        val items = ArrayList<CrdtSequenceItem<TextValue>>()
        val styles = LinkedHashMap<CrdtId, Lww<ParagraphStyle>>()
        r.readSubblock(2) {
            r.readSubblock(1) {
                r.readSubblock(1) {
                    repeat(r.data.readVarUInt().toInt()) { items += readTextItem(r) }
                }
            }
            r.readSubblock(2) {
                r.readSubblock(1) {
                    repeat(r.data.readVarUInt().toInt()) {
                        val charId = r.data.readCrdtId() // untagged
                        val ts = r.readId(1)
                        val style = r.readSubblock(2) {
                            r.data.readU8() // always 17
                            ParagraphStyle.of(r.data.readU8())
                        }
                        styles[charId] = Lww(ts, style)
                    }
                }
            }
        }
        val (posX, posY) = r.readSubblock(3) { r.data.readFloat64() to r.data.readFloat64() }
        val width = r.readFloat(4)
        return RootTextBlock(blockId, Text(CrdtSequence(items), styles, posX, posY, width))
    }

    private fun readTextItem(r: TaggedBlockReader): CrdtSequenceItem<TextValue> = r.readSubblock(0) {
        val id = r.readId(2)
        val left = r.readId(3)
        val right = r.readId(4)
        val deleted = r.readInt(5)
        val value: TextValue = if (r.hasSubblock(6)) {
            val (s, fmt) = r.readStringWithFormat(6)
            if (fmt != null) TextValue.Format(fmt) else TextValue.Chars(s)
        } else TextValue.Chars("")
        CrdtSequenceItem(id, left, right, deleted, value)
    }

    private fun uuidFromLe(b: ByteArray): UUID {
        // reMarkable stores UUIDs in Microsoft "bytes_le" order: first three fields little-endian.
        val bb = ByteBuffer.wrap(b)
        val a = bb.order(ByteOrder.LITTLE_ENDIAN).int.toLong() and 0xFFFFFFFFL
        val s2 = bb.short.toLong() and 0xFFFF
        val s3 = bb.short.toLong() and 0xFFFF
        bb.order(ByteOrder.BIG_ENDIAN)
        val rest = bb.long
        return UUID((a shl 32) or (s2 shl 16) or s3, rest)
    }
}
