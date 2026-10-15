package app.inkbridge.rm.render

import app.inkbridge.rm.scene.Line
import app.inkbridge.rm.scene.PenColorId
import app.inkbridge.rm.scene.PenId
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.ceil
import kotlin.math.cos
import kotlin.math.floor
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin

/**
 * The tablet's pen renderer (xochitl 3.27.1.0, `stroke::v2`), ported from the firmware's own code: strokes are drawn as tapered
 * quads with round or square joins and caps, rasterised with the firmware's scan rule, and each pen decides per pixel whether it is
 * inked (no anti-aliasing, as on the tablet's live view). The pen fills (ballpoint, pencil, marker, paintbrush) use the firmware's
 * noise function and constants. See reference/remarkable-3.27.1.0/pens/ and tools/firmware/pens_port.py (checked pixel by pixel
 * against the real code run under emulation).
 *
 * The buffer holds premultiplied ARGB, the way the firmware keeps its tiles; 0 is transparent.
 */
class PixelInk(val width: Int, val height: Int) {
    val px = IntArray(width * height)

    // The area touched since [resetDirty], so a caller can refresh just that.
    var dirtyLeft = width; private set
    var dirtyTop = height; private set
    var dirtyRight = -1; private set
    var dirtyBottom = -1; private set
    val isDirty: Boolean get() = dirtyRight >= dirtyLeft && dirtyBottom >= dirtyTop

    fun clear() { px.fill(0); resetDirty() }
    fun resetDirty() { dirtyLeft = width; dirtyTop = height; dirtyRight = -1; dirtyBottom = -1 }

    private fun touch(l: Int, t: Int, r: Int, b: Int) {
        dirtyLeft = min(dirtyLeft, l); dirtyTop = min(dirtyTop, t); dirtyRight = max(dirtyRight, r); dirtyBottom = max(dirtyBottom, b)
    }

    /** Page to device mapping: `device = scale * page + (tx, ty)`. */
    class Transform(val scale: Float, val tx: Float, val ty: Float)

    /** Source-over of [src] (premultiplied) onto the opaque ARGB [dst] pixel. */
    private fun over(src: Int, dst: Int): Int {
        val sa = src ushr 24
        if (sa == 255) return src
        if (sa == 0) return dst
        val inv = 255 - sa
        val r = ((src shr 16) and 255) + (((dst shr 16) and 255) * inv + 127) / 255
        val g = ((src shr 8) and 255) + (((dst shr 8) and 255) * inv + 127) / 255
        val b = (src and 255) + ((dst and 255) * inv + 127) / 255
        return (0xFF shl 24) or (min(r, 255) shl 16) or (min(g, 255) shl 8) or min(b, 255)
    }

    /** Composite the ink over [base] (opaque ARGB, same size) into [out] for the given rectangle (inclusive-exclusive). */
    fun compositeInto(base: IntArray, out: IntArray, left: Int, top: Int, right: Int, bottom: Int) {
        for (y in max(top, 0) until min(bottom, height)) {
            val row = y * width
            for (x in max(left, 0) until min(right, width)) out[row + x] = over(px[row + x], base[row + x])
        }
    }

    // ---- colour ----

    /** The firmware's colour for a stroke, premultiplied. [paletteMode] 0 = colour, 1 = grayscale (the reMarkable 2). */
    fun colorOf(line: Line, paletteMode: Int = 0): Int {
        var argb = when {
            line.color == PenColorId.HIGHLIGHT && line.colorRgba != null ->
                (line.colorRgba[3] shl 24) or (line.colorRgba[0] shl 16) or (line.colorRgba[1] shl 8) or line.colorRgba[2]
            line.color == PenColorId.BLACK && (line.tool == PenId.HIGHLIGHTER_1 || line.tool == PenId.HIGHLIGHTER_2) -> 0xfffefd60.toInt()
            else -> PALETTE[line.color] ?: 0xff000000.toInt()
        }
        if (paletteMode == 1) {
            val r = (argb shr 16) and 255; val g = (argb shr 8) and 255; val b = argb and 255
            val gray = (150 * g + 77 * r + 29 * b) shr 8
            argb = (argb and 0xFF000000.toInt()) or (gray shl 16) or (gray shl 8) or gray
        }
        return premultiply(argb)
    }

    private fun premultiply(argb: Int): Int {
        val a = argb ushr 24
        if (a == 255) return argb
        fun c(v: Int) = (v * a + 127) / 255
        return (a shl 24) or (c((argb shr 16) and 255) shl 16) or (c((argb shr 8) and 255) shl 8) or c(argb and 255)
    }

    // ---- geometry (Pipeline<V>::addPoint) ----

    /** Per-point values the fills interpolate across a quad. */
    private class Attr(val a0: Double, val a1: Double, val a2: Double)
    private class Vtx(val x: Double, val y: Double, val attr: Attr, val side: Int)

    private class Quad(val a: Vtx, val b: Vtx, val c: Vtx, val d: Vtx, val ctx: Int)

    private class Geometry(val join: Int, val cap: Int) {
        val quads = ArrayList<Quad>()
        var ctx = 0
        private var state = 0
        private var px = 0.0; private var py = 0.0; private var pw = 0.0; private var pa: Attr? = null
        private var firstX = 0.0; private var firstY = 0.0; private var firstW = 0.0; private var firstA: Attr? = null
        private var curW = 0.0
        private var startCapDone = false
        private var fq: Array<Vtx>? = null
        private var pq: Array<Vtx>? = null

        private fun q(a: Vtx, b: Vtx, c0: Vtx, d0: Vtx, norm: Boolean = false) {
            var c = c0; var d = d0
            // 0xb653a4 with r1 != 0 (joins): make D-C parallel to B-A by swapping C and D.
            if (norm && (d.y - c.y) * (b.y - a.y) + (d.x - c.x) * (b.x - a.x) < 0) { c = d0; d = c0 }
            quads += Quad(a, b, c, d, ctx)
        }

        fun add(x: Double, y: Double, w: Double, attr: Attr, context: Int = 0) {
            ctx = context
            if (state == 0) {
                px = x; py = y; pw = w; pa = attr; firstX = x; firstY = y; firstW = w; firstA = attr; state = 1; curW = w; return
            }
            if (x == px && y == py) return
            val dx = x - px; val dy = y - py
            val ln = hypot(dx, dy); val ux = dx / ln; val uy = dy / ln
            val hw0 = pw * 0.5; val hw1 = w * 0.5
            val prevAttr = pa!!
            val nq = arrayOf(
                Vtx(px + uy * hw0, py - ux * hw0, prevAttr, 1), Vtx(x + uy * hw1, y - ux * hw1, attr, 1),
                Vtx(px - uy * hw0, py + ux * hw0, prevAttr, -1), Vtx(x - uy * hw1, y + ux * hw1, attr, -1),
            )
            if (state == 2) join(pq!!, nq, px, py, pw, prevAttr)
            q(nq[0], nq[1], nq[2], nq[3])
            if (state == 1) fq = nq
            pq = nq
            px = x; py = y; pw = w; pa = attr; curW = w
            state = 2
            if (!startCapDone) { cap(fq!!, firstX, firstY, firstW, firstA!!, true); startCapDone = true }
        }

        private fun join(pq: Array<Vtx>, nq: Array<Vtx>, cx: Double, cy: Double, w: Double, attr: Attr) {
            val pR1 = pq[1]; val pL1 = pq[3]; val nR0 = nq[0]; val nL0 = nq[2]
            if (join == 0) { q(pR1, nR0, pL1, nL0, true); return }
            val a0 = atan2(pR1.y - cy, pR1.x - cx); val a1 = atan2(nR0.y - cy, nR0.x - cx)
            var d = a1 - a0
            if (d >= -PI) { if (d > PI) d -= 2 * PI } else d += 2 * PI
            if (abs(d) < PI / 10) { q(pR1, nR0, pL1, nL0, true); return }
            val r = w * 0.5
            val n = min(ceil(abs((d * r).toFloat().toDouble() / PI)).toInt(), 30)
            if (n == 0) return
            val step = d / n
            var a = a0 + step
            var oR = pR1; var oL = pL1
            repeat(n) {
                val c = cos(a); val s = sin(a)
                val nR = Vtx(cx + c * r, cy + s * r, attr, 1); val nL = Vtx(cx - c * r, cy - s * r, attr, -1)
                q(oR, nR, oL, nL, true)
                oR = nR; oL = nL; a += step
            }
        }

        private fun cap(quad: Array<Vtx>, x: Double, y: Double, w: Double, attr: Attr, start: Boolean) {
            if (w <= 0 || cap == 0) return
            val r0 = quad[0]; val r1 = quad[1]; val l0 = quad[2]; val l1 = quad[3]
            if (cap == 1) {
                val hw = curW * 0.5
                fun ext(p: Vtx, o: Vtx): Vtx {
                    val dx = p.x - o.x; val dy = p.y - o.y; val l = hypot(dx, dy)
                    return Vtx(p.x + dx / l * hw, p.y + dy / l * hw, p.attr, p.side)
                }
                if (start) q(l0, ext(l0, l1), r0, ext(r0, r1)) else q(r1, ext(r1, r0), l1, ext(l1, l0))
                return
            }
            val cornerX = if (start) l0.x else r1.x; val cornerY = if (start) l0.y else r1.y
            val a0 = atan2(cornerY - y, cornerX - x); val r = w * 0.5
            val n = min(ceil(abs((r * PI).toFloat().toDouble() / PI)).toInt(), 30)
            if (n == 0) return
            val iterations = if (n > 3) n shr 1 else 1
            val step = PI / n
            var aT = a0; var aB = a0 + PI
            var oT = Vtx(x + cos(aT) * r, y + sin(aT) * r, attr, 1); var oB = Vtx(x + cos(aB) * r, y + sin(aB) * r, attr, -1)
            repeat(iterations) {
                aT += step; aB -= step
                val nT = Vtx(x + cos(aT) * r, y + sin(aT) * r, attr, 1); val nB = Vtx(x + cos(aB) * r, y + sin(aB) * r, attr, -1)
                q(oT, nT, oB, nB)
                oT = nT; oB = nB
            }
        }

        fun finish() { if (state == 2) cap(pq!!, px, py, pw, pa!!, false) }
    }

    // ---- scan conversion (the firmware's rule: row centres cy = k + 0.5 with ymin < cy <= ymax) ----

    private fun firstCentre(y: Double): Double { val f = floor(y); return f + if (y - f >= 0.5) 1.5 else 0.5 }
    private fun lastCentre(y: Double): Double { val f = floor(y); return f + if (y - f >= 0.5) 0.5 else -0.5 }

    private fun interface PixelFn { fun at(ix: Int, iy: Int, l0: Double, l1: Double, l2: Double) }

    private fun triangle(a: Vtx, b: Vtx, c: Vtx, minX: Int, minY: Int, maxX: Int, maxY: Int, fn: PixelFn) {
        val det = (b.y - c.y) * (a.x - c.x) + (c.x - b.x) * (a.y - c.y)
        if (det == 0.0) return
        // Sort by y for the scan rule.
        var v0 = a; var v1 = b; var v2 = c
        if (v0.y > v1.y) { val t = v0; v0 = v1; v1 = t }
        if (v1.y > v2.y) { val t = v1; v1 = v2; v2 = t }
        if (v0.y > v1.y) { val t = v0; v0 = v1; v1 = t }
        val y0 = v0.y; val y1 = v1.y; val y2 = v2.y
        if (y2 <= y0) return
        var cy = firstCentre(y0)
        val end = lastCentre(y2)
        val lastY1 = lastCentre(y1)
        while (cy <= end) {
            val xa = v0.x + (cy - y0) * (v2.x - v0.x) / (y2 - y0)
            val xb = if (cy <= lastY1 && y1 > y0) v0.x + (cy - y0) * (v1.x - v0.x) / (y1 - y0)
            else if (y2 > y1) v1.x + (cy - y1) * (v2.x - v1.x) / (y2 - y1) else v2.x
            val xl = min(xa, xb); val xr = max(xa, xb)
            val i0 = (xl + 0.5).toInt(); val i1 = (xr - 0.5).toInt()
            val iy = cy.toInt()
            if (iy in minY..maxY) {
                for (ix in max(i0, minX)..min(i1, maxX)) {
                    val pxC = ix + 0.5; val pyC = iy + 0.5
                    val l0 = ((b.y - c.y) * (pxC - c.x) + (c.x - b.x) * (pyC - c.y)) / det
                    val l1 = ((c.y - a.y) * (pxC - c.x) + (a.x - c.x) * (pyC - c.y)) / det
                    fn.at(ix, iy, l0, l1, 1 - l0 - l1)
                }
            }
            cy += 1.0
        }
    }

    // ---- drawing a stroke ----

    /**
     * Draw [line] (whose points are relative to a layer at ([ox], [oy]) in page units) with page units mapped to device pixels by [tf].
     * [paletteMode] is 0 for colour, 1 for the grayscale tablet. Strokes made with eraser tools are not drawn.
     */
    fun drawLine(line: Line, ox: Float, oy: Float, tf: Transform, paletteMode: Int = 0) {
        val tool = line.tool
        if (tool == PenId.ERASER || tool == PenId.ERASER_AREA || tool == 22 || tool == 10 || tool == 11 || tool == 9) return
        if (line.points.size < 2) return
        val zoom = tf.scale.toDouble()
        val color = colorOf(line, paletteMode)
        val darken = line.color != PenColorId.GRAY_OVERLAP

        val geom = when (tool) {
            PenId.HIGHLIGHTER_1 -> Geometry(0, 1)
            PenId.HIGHLIGHTER_2 -> Geometry(0, 0)
            else -> Geometry(1, 2)
        }

        // Page -> device, in float32 as the firmware does.
        var length = line.startingLength * zoom
        var lastX = Double.NaN; var lastY = Double.NaN
        val aa = 0.0 // anti-aliasing is off (the tablet's live look)
        for (p in line.points) {
            val x = (tf.scale * (p.x + ox) + tf.tx).toDouble()
            val y = (tf.scale * (p.y + oy) + tf.ty).toDouble()
            if (!lastX.isNaN()) {
                if (x == lastX && y == lastY) continue
                length += hypot(x - lastX, y - lastY)
            }
            lastX = x; lastY = y
            val widthRaw = p.width / 4.0
            val pressure = p.pressure
            when (tool) {
                PenId.BALLPOINT_2 -> {
                    val w = widthRaw * zoom + aa
                    geom.add(x, y, w, Attr(0.01 * length / zoom, w * 0.5 / zoom, 0.0), ballpointIntensity(pressure, p.speed))
                }
                PenId.PENCIL_2, PenId.MECHANICAL_PENCIL_2 -> {
                    val w = widthRaw * zoom + aa
                    geom.add(x, y, w, Attr(0.02 * length, 35.0 + 165.0 * pressure / 255.0, 1.5 * w * 0.5))
                }
                PenId.MARKER_2 -> {
                    val w = widthRaw * zoom + aa
                    geom.add(x, y, w, Attr(0.02 * length / zoom, markerIntensity(p.speed).toDouble(), 1.5 * w * 0.5))
                }
                PenId.PAINTBRUSH_2 -> {
                    val (wf, inten) = paintbrush(pressure, p.speed)
                    val w = widthRaw * zoom * wf + aa
                    geom.add(x, y, w, Attr(0.02 * length / zoom, inten.toDouble(), 1.5 * w * 0.5))
                }
                else -> geom.add(x, y, widthRaw * zoom + aa, Attr(0.0, 0.0, 0.0))
            }
        }
        geom.finish()
        if (geom.quads.isEmpty()) return

        // Bounds of what will be touched.
        var bx0 = Double.MAX_VALUE; var by0 = Double.MAX_VALUE; var bx1 = -Double.MAX_VALUE; var by1 = -Double.MAX_VALUE
        for (q in geom.quads) for (v in arrayOf(q.a, q.b, q.c, q.d)) {
            bx0 = min(bx0, v.x); bx1 = max(bx1, v.x); by0 = min(by0, v.y); by1 = max(by1, v.y)
        }
        val minX = max(floor(bx0).toInt() - 1, 0); val maxX = min(ceil(bx1).toInt() + 1, width - 1)
        val minY = max(floor(by0).toInt() - 1, 0); val maxY = min(ceil(by1).toInt() + 1, height - 1)
        if (minX > maxX || minY > maxY) return
        val mw = maxX - minX + 1
        val mask = BooleanArray(mw * (maxY - minY + 1))

        val originX = tf.tx.toDouble(); val originY = tf.ty.toDouble() // where page (0, 0) lands: the pencil grain is pinned to the page
        for (q in geom.quads) {
            for (half in 0..1) {
                val t0: Vtx; val t1: Vtx; val t2: Vtx
                if (half == 0) { t0 = q.a; t1 = q.b; t2 = q.c } else { t0 = q.b; t1 = q.c; t2 = q.d }
                triangle(t0, t1, t2, minX, minY, maxX, maxY) { ix, iy, l0, l1, l2 ->
                    val mi = (iy - minY) * mw + (ix - minX)
                    if (mask[mi]) return@triangle
                    val inked = when (tool) {
                        PenId.BALLPOINT_2 -> {
                            val u = l0 * t0.attr.a0 + l1 * t1.attr.a0 + l2 * t2.attr.a0
                            val v = l0 * t0.side * t0.attr.a1 + l1 * t1.side * t1.attr.a1 + l2 * t2.side * t2.attr.a1
                            q.ctx > PenNoise.lerp2(u, v)
                        }
                        PenId.PENCIL_2, PenId.MECHANICAL_PENCIL_2 -> {
                            val aV = l0 * t0.attr.a0 + l1 * t1.attr.a0 + l2 * t2.attr.a0
                            val bV = l0 * t0.side * t0.attr.a2 + l1 * t1.side * t1.attr.a2 + l2 * t2.side * t2.attr.a2
                            val cV = l0 * t0.attr.a1 + l1 * t1.attr.a1 + l2 * t2.attr.a1
                            val dV = l0 * t0.attr.a2 + l1 * t1.attr.a2 + l2 * t2.attr.a2
                            pencilPixel(ix, iy, aV, bV, cV, dV, originX, originY)
                        }
                        PenId.MARKER_2, PenId.PAINTBRUSH_2 -> {
                            val aV = l0 * t0.attr.a0 + l1 * t1.attr.a0 + l2 * t2.attr.a0
                            val bV = l0 * t0.side * t0.attr.a2 + l1 * t1.side * t1.attr.a2 + l2 * t2.side * t2.attr.a2
                            val cV = l0 * t0.attr.a1 + l1 * t1.attr.a1 + l2 * t2.attr.a1
                            val dV = l0 * t0.attr.a2 + l1 * t1.attr.a2 + l2 * t2.attr.a2
                            markerPixel(ix, iy, aV, bV, cV, dV, zoom)
                        }
                        else -> true
                    }
                    if (inked) mask[mi] = true
                }
            }
        }

        // Write the covered pixels.
        val composed = tool == PenId.HIGHLIGHTER_1 || tool == PenId.HIGHLIGHTER_2
        val shader = tool == PenId.SHADER
        for (iy in minY..maxY) {
            val row = iy * width
            for (ix in minX..maxX) {
                if (!mask[(iy - minY) * mw + (ix - minX)]) continue
                val i = row + ix
                px[i] = when {
                    composed -> if (darken) blendDarken(color, px[i]) else blendSrcOver(color, px[i])
                    shader -> blendSrcOver(color, px[i])
                    else -> color
                }
            }
        }
        touch(minX, minY, maxX + 1, maxY + 1)
    }

    // ---- the pens' fills ----

    private fun smooth(t: Double) = (3 - 2 * t) * t * t

    private fun ballpointIntensity(pressure: Int, speedRaw: Int): Int {
        val pr = pressure / 255.0
        val f = if (pr <= 0.7) { val t = pr / 0.7; 0.5 + 0.5 * smooth(t) } else 1.0
        val sp = speedRaw / 4.0
        val sf = if (sp < 5) 255.0 else if (sp > 30) 205.0 else 255.0 - 50.0 * smooth((sp - 5) / 25.0)
        return (f * sf).toInt()
    }

    private fun markerIntensity(speedRaw: Int): Int {
        val sp = speedRaw / 4.0
        val v = if (sp < 3) 255.0 else if (sp > 100) 153.0 else (1.0 - 0.4 * smooth((sp - 3) / 97.0)) * 255.0
        return v.toInt()
    }

    private fun paintbrush(pressure: Int, speedRaw: Int): Pair<Double, Int> {
        val sp = speedRaw / 4.0; val pr = pressure / 255.0
        val pf = if (pr > 0.7) 1.0 else smooth(pr / 0.7)
        val wf: Double; val sv: Double
        if (sp < 5) { wf = 1.0; sv = 255.0 }
        else if (sp <= 50) { wf = 1.0 - 0.3 * smooth((sp - 5) / 45.0); sv = if (sp > 30) 120.0 else 255.0 - 135.0 * smooth((sp - 5) / 25.0) }
        else { wf = 0.7; sv = 120.0 }
        return wf to (pf * sv).toInt()
    }

    private fun pencilPixel(ix: Int, iy: Int, a: Double, b: Double, c: Double, d: Double, ox: Double, oy: Double): Boolean {
        val fall = if (d > 2.0) {
            val t = abs(b) / d
            if (t < 0.5) 1.0 else if (t > 1.0) 0.0 else { val u = 2 * (t - 0.5); 1 - smooth(u) }
        } else 1.0
        val x = ix - ox; val y = iy - oy
        // The firmware samples the grain at the pixel's integer position relative to the page origin (cell = 1 device pixel).
        val s = PenNoise.lerp2(x, y) / 3 + PenNoise.lerp2(x * 3, y * 3) / 2 + PenNoise.lerp2(x * 7, y * 7) / 6
        val noise = ((7 * s) shr 3) + (PenNoise.lerp2(a, b) shr 3)
        return noise <= c * fall
    }

    private fun markerPixel(ix: Int, iy: Int, a: Double, b: Double, c: Double, d: Double, zoom: Double): Boolean {
        val n = (3 * PenNoise.lerp2(a, b / zoom) + PenNoise.g(ix, iy)) shr 2
        val t = if (d != 0.0) abs(b) / d else 9.0
        val thr = if (t < 0.5) c else if (t <= 1.0) { val u = 2 * (t - 0.5); (1 - smooth(u)) * c } else 0.0
        return n.toDouble() <= thr
    }

    // ---- blends on premultiplied ARGB ----

    private fun blendSrcOver(s: Int, d: Int): Int {
        val sa = s ushr 24
        if (sa == 255) return s
        val inv = 255 - sa
        fun ch(shift: Int) = min(((s shr shift) and 255) + (((d shr shift) and 255) * inv + 127) / 255, 255)
        val a = min(sa + (((d ushr 24) * inv + 127) / 255), 255)
        return (a shl 24) or (ch(16) shl 16) or (ch(8) shl 8) or ch(0)
    }

    /** `Sa' = Sa + Da - Sa*Da; C' = Cs + Cd - max(Cs*Da, Cd*Sa)` on premultiplied channels. */
    private fun blendDarken(s: Int, d: Int): Int {
        val sa = s ushr 24; val da = d ushr 24
        val a = sa + da - (sa * da + 127) / 255
        fun ch(shift: Int): Int {
            val cs = (s shr shift) and 255; val cd = (d shr shift) and 255
            return (cs + cd - max((cs * da + 127) / 255, (cd * sa + 127) / 255)).coerceIn(0, 255)
        }
        return (min(a, 255) shl 24) or (ch(16) shl 16) or (ch(8) shl 8) or ch(0)
    }

    companion object {
        /** The firmware's colour table (xochitl 0xccc010), ids as in the .rm file. */
        val PALETTE: Map<Int, Int> = mapOf(
            PenColorId.BLACK to 0xff000000.toInt(),
            PenColorId.GRAY to 0xff909090.toInt(),
            PenColorId.WHITE to 0xffffffff.toInt(),
            PenColorId.YELLOW to 0xfffefd60.toInt(),
            PenColorId.GREEN to 0xffa9fa5c.toInt(),
            PenColorId.PINK to 0xffff55cf.toInt(),
            PenColorId.BLUE to 0xff304ae0.toInt(),
            PenColorId.RED to 0xffc23132.toInt(),
            PenColorId.GRAY_OVERLAP to 0x40000000,
            PenColorId.GREEN_2 to 0xff91da71.toInt(),
            PenColorId.CYAN to 0xff74d2e8.toInt(),
            PenColorId.MAGENTA to 0xffc07fd2.toInt(),
            PenColorId.YELLOW_2 to 0xfffae719.toInt(),
        )
    }
}
