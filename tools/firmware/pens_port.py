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
