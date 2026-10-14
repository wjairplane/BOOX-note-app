package app.inkbridge.rm.io

import app.inkbridge.rm.scene.CrdtId
import app.inkbridge.rm.scene.Lww
import java.io.ByteArrayOutputStream

/** Growable little-endian byte sink. Sub-blocks are built in a child sink so their length is known. */
open class ByteSink {
    protected val out = ByteArrayOutputStream()

    fun toByteArray(): ByteArray = out.toByteArray()
    val size: Int get() = out.size()

    fun bytes(b: ByteArray) = out.write(b)
    fun u8(v: Int) = out.write(v and 0xFF)
    fun bool(v: Boolean) = u8(if (v) 1 else 0)
    fun u16(v: Int) { u8(v); u8(v shr 8) }
    fun int32(v: Int) { u8(v); u8(v shr 8); u8(v shr 16); u8(v shr 24) }
    fun u32(v: Long) = int32(v.toInt())
    fun float32(v: Float) = int32(v.toRawBits())
    fun float64(v: Double) { val b = v.toRawBits(); int32(b.toInt()); int32((b ushr 32).toInt()) }

    fun varUInt(value: Long) {
        require(value >= 0) { "negative varuint" }
        var v = value
        while (true) {
            val low = (v and 0x7F).toInt()
            v = v ushr 7
            if (v != 0L) u8(low or 0x80) else { u8(low); return }
        }
    }

    fun crdtId(id: CrdtId) { require(id.author in 0..255) { "author too large: $id" }; u8(id.author); varUInt(id.counter) }
    fun tag(index: Int, type: TagType) = varUInt((index.toLong() shl 4) or type.code.toLong())
}

/** Writes tagged values and blocks in the v6 layout. Mirror image of [TaggedBlockReader]. */
class TaggedBlockWriter : ByteSink() {
    fun writeHeader() = bytes(HEADER_V6.toByteArray(Charsets.ISO_8859_1))

    fun id(index: Int, v: CrdtId) { tag(index, TagType.ID); crdtId(v) }
    fun bool(index: Int, v: Boolean) { tag(index, TagType.BYTE1); bool(v) }
    fun byte(index: Int, v: Int) { tag(index, TagType.BYTE1); u8(v) }
    fun int(index: Int, v: Int) { tag(index, TagType.BYTE4); int32(v) }
    fun float(index: Int, v: Float) { tag(index, TagType.BYTE4); float32(v) }
    fun double(index: Int, v: Double) { tag(index, TagType.BYTE8); float64(v) }

    /** RGBA array [r, g, b, a] stored as a packed BGRA uint32. */
    fun color(index: Int, rgba: IntArray) =
        int(index, (rgba[3] shl 24) or (rgba[0] shl 16) or (rgba[1] shl 8) or rgba[2])

    fun block(type: Int, minVersion: Int, currentVersion: Int, extra: ByteArray, body: TaggedBlockWriter.() -> Unit) {
        val inner = TaggedBlockWriter().apply(body)
        inner.bytes(extra)
        u32(inner.size.toLong()); u8(0); u8(minVersion); u8(currentVersion); u8(type)
        bytes(inner.toByteArray())
    }

    fun subblock(index: Int, extra: ByteArray = ByteArray(0), body: TaggedBlockWriter.() -> Unit) {
        val inner = TaggedBlockWriter().apply(body)
        inner.bytes(extra)
        tag(index, TagType.LENGTH4); u32(inner.size.toLong())
        bytes(inner.toByteArray())
    }

    fun lwwBool(index: Int, v: Lww<Boolean>) = subblock(index) { id(1, v.timestamp); bool(2, v.value) }
    fun lwwByte(index: Int, v: Lww<Int>) = subblock(index) { id(1, v.timestamp); byte(2, v.value) }
    fun lwwFloat(index: Int, v: Lww<Float>) = subblock(index) { id(1, v.timestamp); float(2, v.value) }
    fun lwwId(index: Int, v: Lww<CrdtId>) = subblock(index) { id(1, v.timestamp); id(2, v.value) }
    fun lwwString(index: Int, v: Lww<String>) = subblock(index) { id(1, v.timestamp); string(2, v.value) }

    fun string(index: Int, s: String) = subblock(index) { stringBody(s) }

    fun stringWithFormat(index: Int, s: String, format: Int?) = subblock(index) {
        stringBody(s)
        if (format != null) int(2, format)
    }

    private fun stringBody(s: String) {
        val b = s.toByteArray(Charsets.UTF_8)
        varUInt(b.size.toLong()); bool(true); bytes(b)
    }

    fun intPair(index: Int, v: Pair<Long, Long>) = subblock(index) { u32(v.first); u32(v.second) }
}
