package app.inkbridge.rm.scene

import java.util.PriorityQueue

data class CrdtSequenceItem<out T>(
    val itemId: CrdtId,
    val leftId: CrdtId,
    val rightId: CrdtId,
    val deletedLength: Int,
    val value: T,
)

/**
 * Ordered CRDT sequence. Items carry left/right neighbour ids; the visible order is a
 * topological sort of those constraints (port of rmscene's `toposort_items`).
 */
class CrdtSequence<T>(items: Iterable<CrdtSequenceItem<T>> = emptyList()) {
    private val byId = LinkedHashMap<CrdtId, CrdtSequenceItem<T>>()

    init {
        items.forEach { byId[it.itemId] = it }
    }

    /** Items in insertion (file) order. Used when writing back. */
    val sequenceItems: List<CrdtSequenceItem<T>> get() = byId.values.toList()

    fun add(item: CrdtSequenceItem<T>) {
        require(item.itemId !in byId) { "Already have item ${item.itemId}" }
        byId[item.itemId] = item
    }

    operator fun get(id: CrdtId): T = byId.getValue(id).value

    /** Ids in sequence order. */
    fun keys(): List<CrdtId> = toposort(byId.values)

    /** Items in sequence order. */
    fun orderedItems(): List<CrdtSequenceItem<T>> = keys().map { byId.getValue(it) }

    fun values(): List<T> = orderedItems().map { it.value }

    val size: Int get() = byId.size

    private companion object {
        // Sentinels that can never be real ids (authors are 0..255).
        val START = CrdtId(-1, -1)
        val END = CrdtId(-2, -2)

        // start < all items < end; among simultaneous candidates, higher author first, then lower counter.
        private val order = Comparator<CrdtId> { a, b -> key(a).compareTo(key(b)) }

        private fun key(n: CrdtId): Triple3 = when (n) {
            START -> Triple3(0, 0, 0)
            END -> Triple3(2, 0, 0)
            else -> Triple3(1, -n.author.toLong(), n.counter)
        }

        data class Triple3(val a: Int, val b: Long, val c: Long) : Comparable<Triple3> {
            override fun compareTo(other: Triple3): Int =
                compareValuesBy(this, other, { it.a }, { it.b }, { it.c })
        }

        fun <T> toposort(items: Collection<CrdtSequenceItem<T>>): List<CrdtId> {
            if (items.isEmpty()) return emptyList()
            val known = items.mapTo(HashSet()) { it.itemId }

            fun side(id: CrdtId, isLeft: Boolean): CrdtId =
                if (id == CrdtId.END_MARKER || id !in known) (if (isLeft) START else END) else id

            val inDegree = HashMap<CrdtId, Int>()
            val dependents = HashMap<CrdtId, MutableList<CrdtId>>()
            val nodes = HashSet<CrdtId>().apply { add(START); add(END) }

            for (item in items) {
                val l = side(item.leftId, true)
                val r = side(item.rightId, false)
                nodes += item.itemId; nodes += l; nodes += r
                // item comes after its left neighbour; right neighbour comes after item
                inDegree.merge(item.itemId, 1, Int::plus)
                dependents.getOrPut(l) { mutableListOf() }.add(item.itemId)
                inDegree.merge(r, 1, Int::plus)
                dependents.getOrPut(item.itemId) { mutableListOf() }.add(r)
            }

            val ready = PriorityQueue(order)
            nodes.filterTo(ready) { (inDegree[it] ?: 0) == 0 }

            val out = ArrayList<CrdtId>(items.size)
            while (ready.isNotEmpty()) {
                val node = ready.poll()
                if (node == END) break
                if (node in known) out += node
                for (d in dependents[node].orEmpty()) {
                    val left = inDegree.getValue(d) - 1
                    inDegree[d] = left
                    if (left == 0) ready += d
                }
            }
            check(inDegree.none { (k, v) -> v > 0 && k != END }) { "cyclic dependency in CRDT sequence" }
            return out
        }
    }
}
