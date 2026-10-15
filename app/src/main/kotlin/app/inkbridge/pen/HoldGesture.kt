package app.inkbridge.pen

/** "Hold at the end of a stroke": the pen stays (nearly) still for a moment before it lifts. */
object HoldGesture {
    const val HOLD_MS = 600L

    /** The stroke without its resting tail, or null when it did not end with a hold of [minMs] inside [radius] px. */
    fun body(samples: List<PenSample>, radius: Float = 10f, minMs: Long = HOLD_MS): List<PenSample>? {
        if (samples.size < 6) return null
        val last = samples.last()
        var i = samples.size - 1
        while (i > 0 && kotlin.math.hypot(samples[i - 1].x - last.x, samples[i - 1].y - last.y) <= radius) i--
        if (last.timeMs - samples[i].timeMs < minMs) return null
        val body = samples.subList(0, i + 1)
        return if (body.size >= 5) body else null
    }

    /** Samples along [points] with the pressure of [from] (the mean) and steady timing, as if drawn quickly. */
    fun resample(points: List<Pair<Float, Float>>, from: List<PenSample>): List<PenSample> {
        val pressure = from.map { it.pressure }.average().toFloat().coerceIn(0.1f, 1f)
        val t0 = from.first().timeMs
        return points.mapIndexed { i, (x, y) -> PenSample(x, y, pressure, 0f, 0f, t0 + i * 6L) }
    }
}
