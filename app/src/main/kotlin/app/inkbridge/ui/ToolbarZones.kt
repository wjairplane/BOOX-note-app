package app.inkbridge.ui

import app.inkbridge.ToolbarPosition
import kotlin.math.PI
import kotlin.math.atan2
import kotlin.math.hypot

/**
 * Which edge a dragged hide button chooses (the firmware's drop-zone logic, xochitl `00ea8903`): nothing until the finger is more than
 * 240 px from the toolbar's corner; then a 160 px strip along an edge wins; otherwise the finger's angle from that corner picks the edge.
 */
internal object ToolbarZones {
    private const val ZONE = 160f

    fun target(current: ToolbarPosition, x: Float, y: Float, width: Float, height: Float): ToolbarPosition? {
        val ox = if (current == ToolbarPosition.RIGHT) width else 0f
        val oy = if (current == ToolbarPosition.BOTTOM) height else 0f
        if (hypot(x - ox, y - oy) <= 1.5f * ZONE) return null

        fun strip(): ToolbarPosition? = when {
            x < ZONE && current != ToolbarPosition.LEFT -> ToolbarPosition.LEFT
            y < ZONE && current != ToolbarPosition.TOP -> ToolbarPosition.TOP
            x > width - ZONE && current != ToolbarPosition.RIGHT -> ToolbarPosition.RIGHT
            y > height - ZONE && current != ToolbarPosition.BOTTOM -> ToolbarPosition.BOTTOM
            else -> null
        }
        strip()?.let { return it }

        val relX = kotlin.math.abs(x - ox); val relY = kotlin.math.abs(y - oy)
        val angle = atan2(relY, relX).coerceIn(0f, (PI / 2).toFloat()) * 180f / PI.toFloat()
        val horizontal = current == ToolbarPosition.TOP || current == ToolbarPosition.BOTTOM
        val close = if (horizontal) 30f else 15f
        val wide = if (horizontal) 7f else 30f
        return when {
            angle < close -> when (current) { ToolbarPosition.TOP -> ToolbarPosition.RIGHT; ToolbarPosition.RIGHT -> ToolbarPosition.TOP; ToolbarPosition.BOTTOM -> ToolbarPosition.RIGHT; ToolbarPosition.LEFT -> ToolbarPosition.TOP }
            angle < 90f - wide -> when (current) { ToolbarPosition.TOP -> ToolbarPosition.BOTTOM; ToolbarPosition.BOTTOM -> ToolbarPosition.TOP; ToolbarPosition.LEFT -> ToolbarPosition.RIGHT; ToolbarPosition.RIGHT -> ToolbarPosition.LEFT }
            else -> when (current) { ToolbarPosition.TOP -> ToolbarPosition.LEFT; ToolbarPosition.RIGHT -> ToolbarPosition.BOTTOM; ToolbarPosition.BOTTOM -> ToolbarPosition.LEFT; ToolbarPosition.LEFT -> ToolbarPosition.BOTTOM }
        }
    }
}
