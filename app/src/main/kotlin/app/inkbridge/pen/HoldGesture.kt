package app.inkbridge.pen

/**
 * "Hold at the end of a stroke" as the firmware's `DrawAndHoldGesture` sees it (reference/remarkable-3.27.1.0/behaviour/shape_snap.md): it looks
 * at the pen position at most every 100 ms, and the pen has to stay within 0.5 page units between two looks for 250 ms.
 */
object HoldGesture {
    const val HOLD_MS = 250L
    const val EVALUATE_MS = 100L
    /** Largest move between two looks, in page units (the firmware's 0.5). */
    const val STILL_RADIUS = 0.5f

    /**
     * The stroke without its resting tail, or null when it did not end with a hold. The pen counts as still while every look (the newest
     * sample at least [EVALUATE_MS] older than the previous look) lies within [radius] view pixels of the one before, for more than [minMs].
     */
    fun body(samples: List<PenSample>, radius: Float, minMs: Long = HOLD_MS): List<PenSample>? {
        if (samples.size < 10) return null
        var look = samples.size - 1
        var start = look
        while (true) {
            // The previous look: the newest sample at least one evaluation interval older than this one.
            var prev = look - 1
            while (prev >= 0 && samples[look].timeMs - samples[prev].timeMs < EVALUATE_MS) prev--
            if (prev < 0) break
            if (kotlin.math.hypot(samples[look].x - samples[prev].x, samples[look].y - samples[prev].y) > radius) break
            look = prev; start = prev
        }
        if (samples.last().timeMs - samples[start].timeMs <= minMs) return null
        // Samples that did not move within the radius of the hold's first look belong to the tail, not the shape.
        var end = start
        while (end > 0 && kotlin.math.hypot(samples[end - 1].x - samples[start].x, samples[end - 1].y - samples[start].y) <= radius) end--
        val body = samples.subList(0, end + 1)
        return if (body.size >= 5) body else null
    }

    /** Samples along [points] with the pressure of [from] (the mean) and steady timing, as if drawn quickly. */
    fun resample(points: List<Pair<Float, Float>>, from: List<PenSample>): List<PenSample> {
        val pressure = from.map { it.pressure }.average().toFloat().coerceIn(0.1f, 1f)
        val t0 = from.first().timeMs
        return points.mapIndexed { i, (x, y) -> PenSample(x, y, pressure, 0f, 0f, t0 + i * 6L) }
    }
}
