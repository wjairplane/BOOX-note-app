package app.inkbridge.rm.scene

/** Identifier / timestamp used throughout the v6 format: (author id, per-author counter). */
data class CrdtId(val author: Int, val counter: Long) : Comparable<CrdtId> {
    override fun compareTo(other: CrdtId): Int =
        compareValuesBy(this, other, { it.author }, { it.counter })

    override fun toString() = "CrdtId($author, $counter)"

    companion object {
        val END_MARKER = CrdtId(0, 0)
    }
}

/** Last-write-wins register: a value plus the timestamp of its last write. */
data class Lww<T>(val timestamp: CrdtId, val value: T)
