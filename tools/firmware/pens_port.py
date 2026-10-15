"""Python port (work in progress) of xochitl's stroke::v2 geometry + scanline rule, validated against the oracle (pens_oracle.py).
Triangle scan rule (verified from the Rasterizer<Fill*> disassembly): sample row centres cy=k+0.5 with ymin < cy <= ymax,
x range per row: ix in [trunc(xl+0.5), trunc(xr-0.5)]  (centre ix+0.5 in (xl, xr])."""
import math, struct
import numpy as np
def f32(x): return struct.unpack("<f", struct.pack("<f", x))[0]
def tri_pixels(a, b, c, W, H):
    """yield (ix, iy, bary(l0,l1,l2)) for pixels covered by triangle a,b,c (tuples x,y)."""
    v = sorted([a, b, c], key=lambda p: p[1])
    (x0, y0), (x1, y1), (x2, y2) = v
    if y2 <= y0: return
    def first(y):  # smallest centre strictly > y
        f = math.floor(y); fr = y - f
        return f + (1.5 if fr >= 0.5 else 0.5)
    def last(y):   # largest centre <= y
        f = math.floor(y); fr = y - f
        return f + (0.5 if fr >= 0.5 else -0.5)
    cy = first(y0); end = last(y2)
    while cy <= end:
        # long edge 0-2
        xa = x0 + (cy - y0) * (x2 - x0) / (y2 - y0)
        if cy <= last(y1) and y1 > y0:
            xb = x0 + (cy - y0) * (x1 - x0) / (y1 - y0)
        elif y2 > y1:
            xb = x1 + (cy - y1) * (x2 - x1) / (y2 - y1)
        else:
            xb = x2
        xl, xr = (xa, xb) if xa <= xb else (xb, xa)
        i0 = int(xl + 0.5); i1 = int(xr - 0.5)
        iy = int(cy)
        if 0 <= iy < H:
            for ix in range(max(i0, 0), min(i1, W - 1) + 1):
                yield ix, iy
        cy += 1.0
def fill_tris(tris, W, H):
    m = np.zeros((H, W), bool)
    for t in tris:
        for ix, iy in tri_pixels(*t, W, H): m[iy, ix] = True
    return m
def quad_tris(A, B, C, D):
    return [(A, B, C), (B, C, D)]

# ---------------------------------------------------------------- geometry of Pipeline<V>::addPoint (0xb74964 / 0xb7cb4c) + caps/joins
PI = math.pi
class V:
    """one quad vertex: position, the attribute record of the stroke point it belongs to, and the side sign (+1 R chain, -1 L chain)"""
    __slots__ = ("p", "attr", "side")
    def __init__(self, p, attr, side): self.p, self.attr, self.side = p, attr, side
class StrokeGeom:
    """Emits quads (v0,v1,v2,v3) -> triangles (v0,v1,v2),(v1,v2,v3).  join: 0 bevel-quad, 1 round; cap: 0 none, 1 square, 2 round.
    Port of Pipeline<Varying*>::addPoint / capEnd / join (VERIFIED against the oracle for Fineliner/Highlighter, pixel-exact)."""
    def __init__(self, join=1, cap=2):
        self.join, self.cap = join, cap
        self.quads = []; self.qctx = []; self.state = 0; self.ctx = None
        self.prev = None; self.first = None; self.startcap_done = False
    def _q(self, A, B, C, D, norm=False):
        if norm:   # 0xb653a4 with r1!=0 (joins): make D-C parallel to B-A by swapping C and D
            if (D.p[1] - C.p[1]) * (B.p[1] - A.p[1]) + (D.p[0] - C.p[0]) * (B.p[0] - A.p[0]) < 0: C, D = D, C
        self.quads.append((A, B, C, D)); self.qctx.append(self.ctx)
    def add(self, x, y, w, attr=None, ctx=None):
        self.ctx = ctx   # per-point state that the rasterizer reads at the moment a quad is emitted (e.g. ballpoint/marker intensity)
        if self.state == 0:
            self.prev = (x, y, w, attr); self.first = self.prev; self.state = 1; self.curw = w; return
        px, py, pw, pa = self.prev
        if x == px and y == py: return
        dx, dy = x - px, y - py
        ln = math.hypot(dx, dy); ux, uy = dx / ln, dy / ln
        hw0, hw1 = pw * 0.5, w * 0.5
        L0 = (px - uy * hw0, py + ux * hw0); L1 = (x - uy * hw1, y + ux * hw1)
        R0 = (px + uy * hw0, py - ux * hw0); R1 = (x + uy * hw1, y - ux * hw1)
        q = (V(R0, pa, 1), V(R1, attr, 1), V(L0, pa, -1), V(L1, attr, -1))
        if self.state == 2: self._join(self.pq, q, (px, py), pw, pa)
        self._q(*q)
        if self.state == 1: self.fq = q
        self.pq = q
        self.prev = (x, y, w, attr); self.curw = w
        self.state = 2
        if not self.startcap_done:
            self._cap(self.fq, self.first, start=True); self.startcap_done = True
    def _join(self, pq, nq, c, w, attr):
        pR1, pL1 = pq[1], pq[3]; nR0, nL0 = nq[0], nq[2]
        if self.join == 0:
            self._q(pR1, nR0, pL1, nL0, True); return
        a0 = math.atan2(pR1.p[1] - c[1], pR1.p[0] - c[0]); a1 = math.atan2(nR0.p[1] - c[1], nR0.p[0] - c[0])
        d = a1 - a0
        if d >= -PI:
            if d > PI: d -= 2 * PI
        else: d += 2 * PI
        if abs(d) < PI / 10:
            self._q(pR1, nR0, pL1, nL0, True); return
        r = w * 0.5
        n = min(int(math.ceil(abs(f32(d * r) / PI))), 30)
        if n == 0: return
        step = d / n; a = a0 + step
        oR, oL = pR1, pL1
        for i in range(n):
            cx, sx = math.cos(a), math.sin(a)
            nR = V((c[0] + cx * r, c[1] + sx * r), attr, 1); nL = V((c[0] - cx * r, c[1] - sx * r), attr, -1)
            self._q(oR, nR, oL, nL, True)
            oR, oL = nR, nL; a += step
    def _cap(self, quad, point, start):
        x, y, w, attr = point; c = (x, y)
        if w <= 0 or self.cap == 0: return
        R0, R1, L0, L1 = quad
        if self.cap == 1:   # square cap: rectangle of depth curw/2 beyond the end edge (0xb65cb0)
            hw = self.curw * 0.5
            def ext(P, Q):
                dx, dy = P.p[0] - Q.p[0], P.p[1] - Q.p[1]; l = math.hypot(dx, dy)
                return V((P.p[0] + dx / l * hw, P.p[1] + dy / l * hw), P.attr, P.side)
            if start: self._q(L0, ext(L0, L1), R0, ext(R0, R1))
            else: self._q(R1, ext(R1, R0), L1, ext(L1, L0))
            return
        corner = L0.p if start else R1.p
        a0 = math.atan2(corner[1] - c[1], corner[0] - c[0]); r = w * 0.5
        n = min(int(math.ceil(abs(f32(r * PI) / PI))), 30)
        it = (n >> 1) if n > 3 else 1
        step = PI / n
        aT = a0; aB = a0 + PI
        oT = V((c[0] + math.cos(aT) * r, c[1] + math.sin(aT) * r), attr, 1); oB = V((c[0] + math.cos(aB) * r, c[1] + math.sin(aB) * r), attr, -1)
        for i in range(it):
            aT += step; aB -= step
            nT = V((c[0] + math.cos(aT) * r, c[1] + math.sin(aT) * r), attr, 1); nB = V((c[0] + math.cos(aB) * r, c[1] + math.sin(aB) * r), attr, -1)
            self._q(oT, nT, oB, nB); oT, oB = nT, nB
    def finish(self):
        if self.state == 2: self._cap(self.pq, self.prev, start=False)
    def triangles(self):
        t = []
        for A, B, C, D in self.quads: t += [(A, B, C), (B, C, D)]
        return t
    def triangles_ctx(self):
        t = []
        for (A, B, C, D), cx in zip(self.quads, self.qctx): t += [((A, B, C), cx), ((B, C, D), cx)]
        return t

# ---------------------------------------------------------------- Pencil fill (Rasterizer<FillPencil>, 0xb842e4) -- VERIFIED pixel-exact vs oracle (identity transform)
_NOISE_T = None
def noise_table():
    global _NOISE_T
    if _NOISE_T is None:
        import os
        p = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "reference", "remarkable-3.27.1.0", "pens", "pencil_noise_table_0x11dd648.bin")
        _NOISE_T = np.frombuffer(open(p, "rb").read(), np.uint8).astype(np.int64)
    return _NOISE_T
def _g(ix, iy):
    T = noise_table(); return int(T[int(T[iy & 255]) + (ix & 255)])
def _lerp2(u, v):
    ix = math.floor(u); iy = math.floor(v)
    fx = int((u - ix) * 255); fy = int((v - iy) * 255)
    r0 = (255 - fx) * _g(ix, iy) + fx * _g(ix + 1, iy)
    r1 = (255 - fx) * _g(ix, iy + 1) + fx * _g(ix + 1, iy + 1)
    return ((255 - fy) * r0 + fy * r1) >> 16
def pencil_noise(px, py, a, b, cell=1.0, ox=0.0, oy=0.0):
    inv = 1.0 / cell
    x = (px - ox) * inv; y = (py - oy) * inv
    s = _lerp2(x, y) // 3 + _lerp2(x * 3, y * 3) // 2 + _lerp2(x * 7, y * 7) // 6
    return (7 * s >> 3) + (_lerp2(a, b) >> 3)
def pencil_pixel(px, py, a, b, c, d, cell=1.0, ox=0.0, oy=0.0):
    """True if pixel is inked. (a,b,c,d) = interpolated Varying4D at the pixel centre."""
    if d > 2.0:
        t = abs(b) / d
        if t < 0.5: fall = 1.0
        elif t > 1.0: fall = 0.0
        else:
            u = 2 * (t - 0.5); fall = 1 - (3 - 2 * u) * u * u
    else: fall = 1.0
    return pencil_noise(px, py, a, b, cell, ox, oy) <= c * fall
def bary(P, cx, cy):
    (x0, y0), (x1, y1), (x2, y2) = P
    det = (y1 - y2) * (x0 - x2) + (x2 - x1) * (y0 - y2)
    if det == 0: return None
    l0 = ((y1 - y2) * (cx - x2) + (x2 - x1) * (cy - y2)) / det; l1 = ((y2 - y0) * (cx - x2) + (x0 - x2) * (cy - y2)) / det
    return l0, l1, 1 - l0 - l1
def render_pencil(points, W, H, zoom=1.0, ts=1.0, flag=False, cell=1.0, A=0.02, B=1.5):
    """points: list of (x, y, width_px_before_zoom, pressure0_255) ; x,y already in device px. Returns bool mask."""
    g = StrokeGeom(1, 2)
    L = ts * zoom; last = None
    for (x, y, w, pr) in points:
        w = w * zoom + (0.75 if flag else 0.0)
        if last is not None:
            if x == last[0] and y == last[1]: continue
            L += math.hypot(x - last[0], y - last[1])
        last = (x, y)
        c = 35.0 + 165.0 * pr / 255.0
        g.add(x, y, w, (A * L, c, B * w * 0.5))
    g.finish()
    m = np.zeros((H, W), bool)
    for tri in g.triangles():
        P = [v.p for v in tri]
        for ix, iy in tri_pixels(*P, W, H):
            if m[iy, ix]: continue
            bc = bary(P, ix + 0.5, iy + 0.5)
            if bc is None: continue
            a = sum(bc[k] * tri[k].attr[0] for k in range(3))
            b = sum(bc[k] * tri[k].side * tri[k].attr[2] for k in range(3))
            c = sum(bc[k] * tri[k].attr[1] for k in range(3))
            d = sum(bc[k] * tri[k].attr[2] for k in range(3))
            if pencil_pixel(ix, iy, a, b, c, d, cell): m[iy, ix] = True
    return m


# ---------------------------------------------------------------- Ballpoint (Pipeline<Varying2D> + Rasterizer<FillBallpoint>)
def ballpoint_intensity(pressure, speed_raw):
    """0xb7a7bc: returns uint intensity 0..255 (VERIFIED from disassembly)."""
    pr = pressure / 255.0
    if pr <= 0.7:
        t = pr / 0.7; f = 0.5 + 0.5 * (3 - 2 * t) * t * t
    else: f = 1.0
    sp = speed_raw / 4.0
    if sp < 5: sf = 255.0
    elif sp > 30: sf = 205.0
    else:
        x = (sp - 5) / 25.0; sf = 255.0 - 50.0 * (3 - 2 * x) * x * x
    return int(f * sf)
def render_ballpoint(points, W, H, zoom=1.0, ts=1.0, flag=False):
    """points: list of (x_dev, y_dev, width_px_before_zoom, pressure, speed_raw). Non-AA mode. Returns bool mask."""
    g = StrokeGeom(1, 2)
    L = ts * zoom; last = None
    for (x, y, w, pr, spd) in points:
        w = w * zoom + (0.75 if flag else 0.0)
        if last is not None:
            if x == last[0] and y == last[1]: continue
            L += math.hypot(x - last[0], y - last[1])
        last = (x, y)
        g.add(x, y, w, (0.01 * L / zoom, w * 0.5 / zoom), ctx=ballpoint_intensity(pr, spd))
    g.finish()
    m = np.zeros((H, W), bool)
    for tri, inten in g.triangles_ctx():
        P = [v.p for v in tri]
        for ix, iy in tri_pixels(*P, W, H):
            if m[iy, ix]: continue
            bc = bary(P, ix + 0.5, iy + 0.5)
            if bc is None: continue
            u = sum(bc[k] * tri[k].attr[0] for k in range(3))
            v = sum(bc[k] * tri[k].side * tri[k].attr[1] for k in range(3))
            if inten > _lerp2(u, v): m[iy, ix] = True
    return m

# ---------------------------------------------------------------- Marker v2 (tool 16) : 0xb80b50 per point, fill = lambda at 0xb75890 (see pen_spec.md)
def marker_intensity(speed_raw):
    sp = speed_raw / 4.0
    if sp < 3: return 255.0
    if sp > 100: return 153.0
    x = (sp - 3) / 97.0
    return (1.0 - 0.4 * (3 - 2 * x) * x * x) * 255.0
def marker_pixel(px, py, a, b, c, d, zoom=1.0):
    n = (3 * _lerp2(a, b / zoom) + _g(px, py)) >> 2
    t = abs(b) / d if d else 9
    if t < 0.5: thr = c
    elif t <= 1.0:
        u = 2 * (t - 0.5); thr = (1 - (3 - 2 * u) * u * u) * c
    else: thr = 0.0
    return float(n) <= thr
def render_marker2(points, W, H, zoom=1.0, ts=1.0, flag=False, A=0.02, B=1.5):
    """points: (x_dev, y_dev, width_px_before_zoom, speed_raw)"""
    g = StrokeGeom(1, 2)
    L = ts * zoom; last = None
    for (x, y, w, spd) in points:
        w = w * zoom + (0.75 if flag else 0.0)
        if last is not None:
            if x == last[0] and y == last[1]: continue
            L += math.hypot(x - last[0], y - last[1])
        last = (x, y)
        g.add(x, y, w, (A * L / zoom, marker_intensity(spd), B * w * 0.5))
    g.finish()
    m = np.zeros((H, W), bool)
    for tri in g.triangles():
        P = [v.p for v in tri]
        for ix, iy in tri_pixels(*P, W, H):
            if m[iy, ix]: continue
            bc = bary(P, ix + 0.5, iy + 0.5)
            if bc is None: continue
            a = sum(bc[k] * tri[k].attr[0] for k in range(3)); b = sum(bc[k] * tri[k].side * tri[k].attr[2] for k in range(3))
            c = sum(bc[k] * tri[k].attr[1] for k in range(3)); d = sum(bc[k] * tri[k].attr[2] for k in range(3))
            if marker_pixel(ix, iy, a, b, c, d, zoom): m[iy, ix] = True
    return m

# ---------------------------------------------------------------- Paintbrush v2 (tool 12): 0xb8078c per point, same fill as Marker v2
def _smooth(x): return (3 - 2 * x) * x * x
def paintbrush_params(pressure, speed_raw):
    """returns (width_factor, intensity) -- VERIFIED from disassembly 0xb8078c"""
    sp = speed_raw / 4.0; pr = pressure / 255.0
    pf = 1.0 if pr > 0.7 else _smooth(pr / 0.7)
    if sp < 5: wf = 1.0; sv = 255.0
    elif sp <= 50:
        wf = 1.0 - 0.3 * _smooth((sp - 5) / 45.0)
        sv = 120.0 if sp > 30 else 255.0 - 135.0 * _smooth((sp - 5) / 25.0)
    else: wf = 0.7; sv = 120.0
    return wf, pf * sv
def render_paintbrush2(points, W, H, zoom=1.0, ts=1.0, flag=False, A=0.02, B=1.5):
    """points: (x_dev, y_dev, width_px_before_zoom, pressure, speed_raw)"""
    g = StrokeGeom(1, 2)
    L = ts * zoom; last = None
    for (x, y, w, pr, spd) in points:
        wf, inten = paintbrush_params(pr, spd)
        w = w * zoom * wf + (0.75 if flag else 0.0)   # NOTE: flag handling unverified for paintbrush
        if last is not None:
            if x == last[0] and y == last[1]: continue
            L += math.hypot(x - last[0], y - last[1])
        last = (x, y)
        g.add(x, y, w, (A * L / zoom, inten, B * w * 0.5))
    g.finish()
    m = np.zeros((H, W), bool)
    for tri in g.triangles():
        P = [v.p for v in tri]
        for ix, iy in tri_pixels(*P, W, H):
            if m[iy, ix]: continue
            bc = bary(P, ix + 0.5, iy + 0.5)
            if bc is None: continue
            a = sum(bc[k] * tri[k].attr[0] for k in range(3)); b = sum(bc[k] * tri[k].side * tri[k].attr[2] for k in range(3))
            c = sum(bc[k] * tri[k].attr[1] for k in range(3)); d = sum(bc[k] * tri[k].attr[2] for k in range(3))
            if marker_pixel(ix, iy, a, b, c, d, zoom): m[iy, ix] = True
    return m
