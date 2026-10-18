"""Emulate xochitl's live eraser (tool 22 MaskedEraser, stroke::v2 kind-0 pipeline) under Unicorn (see pens_emu.py).
Result (fw 3.27.1.0, RM2, ctx byte +0x6e == 0): the live eraser draws, for every framebuffer pixel inside the swept disc
(diameter = point width_raw/4 * zoom, per-point, round caps) with (x+y) even, a SOLID WHITE pixel (0xFFFF / 0xFFFFFFFF),
independent of the pixels underneath, of pressure, speed.  Odd-parity pixels are untouched => 50% white/ink checkerboard.
Rasteriser = triangle filler at 0xb6e7a0..0xb6ea30: stores 32-bit word (2 px) every 2nd pixel, value = ctx[0x20 + 4*(y&1)].
Usage: python3 eraser_emu.py   (self-checks, prints a summary)"""
import sys
sys.path.insert(0, "/home/user/BOOX-note-app/tools/firmware")
import numpy as np, pens_emu, pens_oracle as o

def live_eraser(pts, W=128, H=64, depth=16, bg=0, zoom=1.0, flag6e=0):
    """pts: list of o.pt(...) (width = diameter in page px). Returns raw fb as uint array (H,W)."""
    e = pens_emu.Emu(W, H, depth)
    px = (bytes([bg & 255, bg >> 8 & 255]) if bg > 255 else bytes([bg, bg])) if depth == 16 else bytes([bg & 255] * 3 + [255])
    e.uc.mem_write(e.fb, px * (W * H))
    xf = [zoom, 0, 0, 0, zoom, 0, 0, 0, 1] if zoom != 1.0 else None
    # make_renderer builds the config block; patch +0x6e (colour-panel flag) just before the renderer ctor by wrapping alloc
    orig = e.alloc
    def alloc(n):
        a = orig(n)
        if n == 0x100: e._cfg = a
        return a
    e.alloc = alloc
    if flag6e:
        orig_call = e.call
        def call(addr, *a, **k):
            if addr == 0xb7f438: e.uc.mem_write(e._cfg + 0x6e, bytes([flag6e]))
            return orig_call(addr, *a, **k)
        e.call = call
    e.make_renderer(scale=zoom, xform=xf)
    L = e.make_line(22, 0, pts)
    e.call(0xb6c850, [e.holder, L]); e.call(0xb6bbf0, [e.holder])
    dt = {16: "<u2", 32: "<u4"}[depth]
    return np.frombuffer(bytes(e.uc.mem_read(e.fb, e.bpl * H)), dtype=dt).reshape(H, W)

if __name__ == "__main__":
    pts = [o.pt(20 + i * 7, 32, width=11.0) for i in range(12)]
    for depth, white in ((16, 0xFFFF), (32, 0xFFFFFFFF)):
        for bg in (0, 0x40):
            a = live_eraser(pts, depth=depth, bg=bg)
            ys, xs = np.nonzero(a == white)
            print(f"depth {depth} bg {bg:#x}: values {sorted(set(a.ravel().tolist()))[:4]} white px {len(ys)} parity(x+y)&1 {set(((xs+ys)&1).tolist())}")
    a = live_eraser([o.pt(20 + i * 7, 32, width=11.0) for i in range(12)], depth=16, bg=0xffff)
    print("on white paper: untouched =", bool((a == 0xFFFF).all()))
    a = live_eraser([o.pt(10 + i * 10, 20, width=10) for i in range(10)], W=200, H=80, depth=32, zoom=2.0)
    ys, xs = np.nonzero(a == 0xFFFFFFFF); print("zoom2 rows", ys.min(), ys.max(), "(diameter 20 px = 10*2)")
    a = live_eraser(pts, depth=32, flag6e=1)
    print("colour-panel flag +0x6e=1 values:", [hex(v) for v in sorted(set(a.ravel().tolist()))])
