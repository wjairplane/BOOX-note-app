package app.inkbridge.rm.io

import app.inkbridge.rm.scene.*
import java.util.UUID

/** One top-level block of a v6 file. */
sealed interface Block {
    /** Bytes at the end of the block that this parser didn't understand (kept for round-trip). */
    val extra: ByteArray
}

class UnreadableBlock(
    val blockType: Int,
    val minVersion: Int,
    val currentVersion: Int,
    val data: ByteArray,
    val error: String,
) : Block { override val extra = ByteArray(0) }

class AuthorIdsBlock(val authors: Map<Int, UUID>, override val extra: ByteArray = ByteArray(0)) : Block

class MigrationInfoBlock(
    val migrationId: CrdtId, val isDevice: Boolean, val unknown: Boolean, override val extra: ByteArray = ByteArray(0),
) : Block

class PageInfoBlock(
    val loadsCount: Int, val mergesCount: Int, val textCharsCount: Int, val textLinesCount: Int,
    val typeFolioUseCount: Int, override val extra: ByteArray = ByteArray(0),
) : Block

class SceneInfoBlock(
    val currentLayer: Lww<CrdtId>,
    val backgroundVisible: Lww<Boolean>?,
    val rootDocumentVisible: Lww<Boolean>?,
    /** Paper size in page units when the file specifies it. */
    val paperSize: Pair<Long, Long>?,
    override val extra: ByteArray = ByteArray(0),
) : Block

class SceneTreeBlock(
    val treeId: CrdtId, val nodeId: CrdtId, val isUpdate: Boolean, val parentId: CrdtId,
    override val extra: ByteArray = ByteArray(0),
) : Block

class TreeNodeBlock(val group: Group, override val extra: ByteArray = ByteArray(0)) : Block

class RootTextBlock(val blockId: CrdtId, val value: Text, override val extra: ByteArray = ByteArray(0)) : Block

/** A sequence entry (group ref, line, glyph or tombstone) belonging to [parentId]. */
class SceneItemBlock(
    val blockType: Int,
    val parentId: CrdtId,
    val itemId: CrdtId,
    val leftId: CrdtId,
    val rightId: CrdtId,
    val deletedLength: Int,
    /** CrdtId (group ref), Line, GlyphRange, or null (tombstone / text-item marker). */
    val value: Any?,
    override val extra: ByteArray = ByteArray(0),
) : Block {
    companion object {
        const val GLYPH = 0x03
        const val GROUP = 0x04
        const val LINE = 0x05
        const val TEXT = 0x06
        const val TOMBSTONE = 0x08
    }
}
