package app.inkbridge.rm.edit

import app.inkbridge.rm.render.PageLayout
import kotlin.math.min

/**
 * Maps between view pixels and page units for a page drawn "fit to view": uniformly scaled, centred
 * horizontally, top-aligned. Must match how the page bitmap is placed on screen.
 */
class PageTransform(val layout: PageLayout, viewWidth: Float, viewHeight: Float) {
    val scale: Float = min(viewWidth / layout.width, viewHeight / layout.height)
    val offsetX: Float = (viewWidth - layout.width * scale) / 2f

    fun toPageX(vx: Float) = (vx - offsetX) / scale + layout.xMin
    fun toPageY(vy: Float) = vy / scale + layout.yMin
    fun toViewX(px: Float) = (px - layout.xMin) * scale + offsetX
    fun toViewY(py: Float) = (py - layout.yMin) * scale

    /** Page-unit size of one view pixel; useful for converting a radius in px to page units. */
    fun pagePerPixel(): Float = 1f / scale
}
