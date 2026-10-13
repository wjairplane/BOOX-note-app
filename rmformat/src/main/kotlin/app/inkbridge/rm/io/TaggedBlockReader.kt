package app.inkbridge.rm.io

import app.inkbridge.rm.scene.CrdtId
import app.inkbridge.rm.scene.Lww

const val HEADER_V6 = "reMarkable .lines file, version=6          "

class MainBlockInfo(
    val offset: Int,
    val size: Int,
    val blockType: Int,
    val minVersion: Int,
    val currentVersion: Int,
) {
    val end: Int get() = offset + size
}

class SubBlockInfo(val offset: Int, val size: Int) {
    val end: Int get() = offset + size
}

class BlockOverflowException(message: String) : Exception(message)

/** Reads tagged values and (sub)blocks from a v6 file. Port of rmscene's `TaggedBlockReader`. */
class TaggedBlockReader(bytes: ByteArray) {
    val data = RmDataStream(bytes)
    var currentBlock: MainBlockInfo? = null
        private set

    fun readHeader() {
        val header = String(data.readBytes(HEADER_V6.length), Charsets.ISO_8859_1)
        require(header == HEADER_V6) { "Not a reMarkable v6 .rm file (header: '${header.trim()}')" }
    }

    // ---- tagged simple values ----

    fun readId(index: Int): CrdtId { data.readTag(index, TagType.ID); return data.readCrdtId() }
    fun readBool(index: Int): Boolean { data.readTag(index, TagType.BYTE1); return data.readBool() }
    fun readByte(index: Int): Int { data.readTag(index, TagType.BYTE1); return data.readU8() }
    /** Tagged 4-byte unsigned integer, returned as the raw 32 bits. */
    fun readInt(index: Int): Int { data.readTag(index, TagType.BYTE4); return data.readInt32() }
    fun readFloat(index: Int): Float { data.readTag(index, TagType.BYTE4); return data.readFloat32() }
    fun readDouble(index: Int): Double { data.readTag(index, TagType.BYTE8); return data.readFloat64() }

    fun readIntOptional(index: Int): Int? = if (data.checkTag(index, TagType.BYTE4)) readInt(index) else null

    /** Optional colour stored as a packed little-endian uint32 (BGRA); returned as [r, g, b, a]. */
    fun readColorOptional(index: Int): IntArray? {
        if (!data.checkTag(index, TagType.BYTE4)) return null
        val p = readInt(index)
        return intArrayOf((p ushr 16) and 0xFF, (p ushr 8) and 0xFF, p and 0xFF, (p ushr 24) and 0xFF)
    }

    // ---- blocks ----

    /**
     * Read one top-level block header, run [body] on its content, then skip any unread bytes.
     * Returns null at end of file. Unread trailing bytes (newer firmware fields) are handed to
     * [onExtra] so they can be preserved for round-tripping.
     */
    fun <T> readBlock(body: (MainBlockInfo) -> T, onExtra: (ByteArray) -> Unit = {}): T? {
        check(currentBlock == null) { "Already in a block" }
        if (data.position + 8 > data.size) return null
        val length = data.readU32()
        require(length <= Int.MAX_VALUE) { "Absurd block length $length" }
        val unknown = data.readU8()
        val minVersion = data.readU8()
        val currentVersion = data.readU8()
        val blockType = data.readU8()
        require(unknown == 0) { "Unexpected block header byte $unknown at ${data.position}" }
        val info = MainBlockInfo(data.position, length.toInt(), blockType, minVersion, currentVersion)
        require(info.end <= data.size) { "Block of $length bytes at ${info.offset} runs past EOF (${data.size})" }
        currentBlock = info
        try {
            val result = body(info)
            checkPosition(info.offset, info.end, onExtra)
            return result
        } finally {
            currentBlock = null
        }
    }

    /** Skip a block we can't parse; return its raw content. */
    fun rawBlockContent(info: MainBlockInfo): ByteArray {
        data.position = info.offset
        return data.readBytes(info.size)
    }

    fun bytesRemainingInBlock(): Int {
        val b = checkNotNull(currentBlock) { "Not in a block" }
        return b.end - data.position
    }

    fun <T> readSubblock(index: Int, onExtra: (ByteArray) -> Unit = {}, body: (SubBlockInfo) -> T): T {
        data.readTag(index, TagType.LENGTH4)
        val size = data.readU32().toInt()
        val info = SubBlockInfo(data.position, size)
        check(info.end <= data.size) { "Subblock of $size bytes at ${info.offset} runs past EOF" }
        val result = body(info)
        checkPosition(info.offset, info.end, onExtra)
        return result
    }

    /** True if a sub-block with [index] is next (and we're not already at the end of the block). */
    fun hasSubblock(index: Int): Boolean {
        if (currentBlock != null && bytesRemainingInBlock() <= 0) return false
        return data.checkTag(index, TagType.LENGTH4)
    }

    private fun checkPosition(offset: Int, end: Int, onExtra: (ByteArray) -> Unit) {
        val pos = data.position
        if (pos > end) throw BlockOverflowException("Read up to $pos but block at $offset ends at $end")
        if (pos < end) onExtra(data.readBytes(end - pos))
    }

    // ---- compound values ----

    fun readLwwBool(index: Int): Lww<Boolean> = readSubblock(index) { Lww(readId(1), readBool(2)) }
    fun readLwwByte(index: Int): Lww<Int> = readSubblock(index) { Lww(readId(1), readByte(2)) }
    fun readLwwFloat(index: Int): Lww<Float> = readSubblock(index) { Lww(readId(1), readFloat(2)) }
    fun readLwwId(index: Int): Lww<CrdtId> = readSubblock(index) { Lww(readId(1), readId(2)) }
    fun readLwwString(index: Int): Lww<String> = readSubblock(index) { Lww(readId(1), readString(2)) }

    fun readString(index: Int): String = readSubblock(index) { readStringBody(it) }

    /** String sub-block that may be followed by an inline format code (tag 2). */
    fun readStringWithFormat(index: Int): Pair<String, Int?> = readSubblock(index) { info ->
        val s = readStringBody(info)
        val fmt = if (data.checkTag(2, TagType.BYTE4)) readInt(2) else null
        s to fmt
    }

    private fun readStringBody(info: SubBlockInfo): String {
        val len = data.readVarUInt().toInt()
        data.readBool() // "is ascii" flag; always set in practice, strings are UTF-8
        require(len + 2 <= info.size) { "String length $len does not fit in subblock of ${info.size}" }
        return String(data.readBytes(len), Charsets.UTF_8)
    }

    fun readIntPair(index: Int): Pair<Long, Long> = readSubblock(index) { data.readU32() to data.readU32() }
}
