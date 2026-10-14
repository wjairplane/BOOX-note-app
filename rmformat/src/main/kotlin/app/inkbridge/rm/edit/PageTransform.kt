package app.inkbridge.rm.edit

import app.inkbridge.rm.render.PageLayout
import kotlin.math.min

/**
 * Maps between view pixels and page units. The page is drawn "fit to view" (uniformly scaled, centred horizontally,
 * top-aligned) and can then be zoomed in by [zoom] (1 = fit) and panned. [panX] and [panY] are in view pixels and are
 * clamped so that a zoomed page never leaves a gap; a page smaller than the view stays centred / top-aligned.
 */
class PageTransform(val layout: PageLayout, val viewWidth: Float, val viewHeight: Float, zoom: Float = 1f, panX: Float = 0f, panY: Float = 0f) {
    /** The scale at which the whole page fits the view. */
    val fitScale: Float = min(viewWidth / layout.width, viewHeight / layout.height)
    val zoom: Float = zoom.coerceIn(MIN_ZOOM, MAX_ZOOM)
    val scale: Float = fitScale * this.zoom

    private val contentW = layout.width * scale
    private val contentH = layout.height * scale
    val offsetX: Float = if (contentW <= viewWidth) (viewWidth - contentW) / 2f else (panX).coerceIn(viewWidth - contentW, 0f)
    val offsetY: Float = if (contentH <= viewHeight) 0f else (panY).coerceIn(viewHeight - contentH, 0f)

    fun toPageX(vx: Float) = (vx - offsetX) / scale + layout.xMin
    fun toPageY(vy: Float) = (vy - offsetY) / scale + layout.yMin
    fun toViewX(px: Float) = (px - layout.xMin) * scale + offsetX
    fun toViewY(py: Float) = (py - layout.yMin) * scale + offsetY

    /** The page's rectangle in view pixels, clipped to the view: where drawing is allowed. */
    fun visiblePageRect(): FloatArray = floatArrayOf(
        offsetX.coerceAtLeast(0f), offsetY.coerceAtLeast(0f),
        (offsetX + contentW).coerceAtMost(viewWidth), (offsetY + contentH).coerceAtMost(viewHeight),
    )

    /** Page-unit size of one view pixel; useful for converting a radius in px to page units. */
    fun pagePerPixel(): Float = 1f / scale

    /** The same page and view with a different zoom, keeping the page point under ([focusX], [focusY]) fixed. */
    fun zoomedAround(newZoom: Float, focusX: Float, focusY: Float): PageTransform {
        val z = newZoom.coerceIn(MIN_ZOOM, MAX_ZOOM)
        val px = toPageX(focusX); val py = toPageY(focusY)
        val s = fitScale * z
        return PageTransform(layout, viewWidth, viewHeight, z, focusX - (px - layout.xMin) * s, focusY - (py - layout.yMin) * s)
    }

    /** Pan by ([dx], [dy]) view pixels. */
    fun pannedBy(dx: Float, dy: Float) = PageTransform(layout, viewWidth, viewHeight, zoom, offsetX + dx, offsetY + dy)

    /** Zoom so the page is as wide as the view, showing its top. */
    fun fitWidth(): PageTransform = PageTransform(layout, viewWidth, viewHeight, (viewWidth / layout.width) / fitScale, 0f, 0f)

    /** Zoom so the page is as tall as the view. */
    fun fitHeight(): PageTransform = PageTransform(layout, viewWidth, viewHeight, (viewHeight / layout.height) / fitScale, 0f, 0f)

    companion object {
        const val MIN_ZOOM = 1f
        const val MAX_ZOOM = 4f
    }
}
