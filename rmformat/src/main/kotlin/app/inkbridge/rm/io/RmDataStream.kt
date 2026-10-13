package app.inkbridge.rm.io

import app.inkbridge.rm.scene.CrdtId
import java.io.EOFException

/** Tag type: the low 4 bits of every tag varint, telling what kind of value follows. */
enum class TagType(val code: Int) {
    ID(0xF),
    LENGTH4(0xC),
    BYTE8(0x8),
    BYTE4(0x4),
    BYTE1(0x1);

    companion object {
        fun of(code: Int): TagType? = entries.firstOrNull { it.code == code }
    }
}

/** Expected tag not found at the current position. The stream is rewound before this is thrown. */
class UnexpectedTagException(message: String) : Exception(message)

/**
 * Little-endian primitive reader over an in-memory `.rm` file.
 *
 * Pages are small (tens to hundreds of KB), so the whole file is read into memory; that makes
 * peeking and rewinding trivial.
 */
class RmDataStream(private val buf: ByteArray) {
    var position: Int = 0

    val size: Int get() = buf.size

    fun readBytes(n: Int): ByteArray {
        if (n < 0 || position + n > buf.size) throw EOFException("Need $n bytes at $position, file is ${buf.size}")
        val out = buf.copyOfRange(position, position + n)
        position += n
        return out
    }

    fun readU8(): Int {
        if (position >= buf.size) throw EOFException("EOF at $position")
        return buf[position++].toInt() and 0xFF
    }

    fun readBool(): Boolean = readU8() != 0

    fun readU16(): Int = readU8() or (readU8() shl 8)

    /** Raw 32 bits; use [readU32] when the unsigned value matters. */
    fun readInt32(): Int = readU8() or (readU8() shl 8) or (readU8() shl 16) or (readU8() shl 24)

    fun readU32(): Long = readInt32().toLong() and 0xFFFFFFFFL

    fun readFloat32(): Float = Float.fromBits(readInt32())

    fun readFloat64(): Double {
        val lo = readU32()
        val hi = readU32()
        return Double.fromBits((hi shl 32) or lo)
    }

    fun readVarUInt(): Long {
        var shift = 0
        var result = 0L
        while (true) {
            val b = readU8()
            result = result or ((b and 0x7F).toLong() shl shift)
            shift += 7
            if (b and 0x80 == 0) return result
            if (shift > 63) throw IllegalStateException("varuint too long at $position")
        }
    }

    /** CRDT ids are a one-byte author id followed by a varuint counter. */
    fun readCrdtId(): CrdtId = CrdtId(readU8(), readVarUInt())

    /** Read a tag (index, type). Returns null type for an unknown type nibble. */
    fun readTagValues(): Pair<Int, TagType?> {
        val x = readVarUInt()
        return (x ushr 4).toInt() to TagType.of((x and 0xF).toInt())
    }

    /** True if the next tag is exactly ([index], [type]). Never advances the stream. */
    fun checkTag(index: Int, type: TagType): Boolean {
        val pos = position
        return try {
            val (i, t) = readTagValues()
            i == index && t == type
        } catch (_: EOFException) {
            false
        } catch (_: IllegalStateException) {
            false
        } finally {
            position = pos
        }
    }

    fun readTag(index: Int, type: TagType) {
        val pos = position
        val (i, t) = try {
            readTagValues()
        } catch (e: EOFException) {
            position = pos
            throw UnexpectedTagException("Expected tag $index/$type at $pos, got EOF")
        }
        if (i != index || t != type) {
            position = pos
            throw UnexpectedTagException("Expected tag $index/$type at $pos, got $i/$t")
        }
    }
}
