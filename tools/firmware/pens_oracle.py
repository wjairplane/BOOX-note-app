"""Oracle: render strokes with the real xochitl pen code under Unicorn. See pens_emu.py.
render(tool, pts, ...) -> (H,W) uint8 array of RGBA bytes (as BGRA32 -> returns PIL image)."""
import sys, struct
sys.path.insert(0, "/tmp/claude-0/-home-user-BOOX-note-app/49c791b8-36e3-5584-bfb4-b5d40653e991/scratchpad/pylibs")
sys.path.insert(0, "/home/user/BOOX-note-app/tools/firmware")
import pens_emu
from PIL import Image
def pt(x, y, speed=0, width=16.0, direction=0, pressure=128):
    """width in page px (stored raw = width*4); direction 0..255 ; pressure 0..255"""
    return dict(x=x, y=y, speed=int(speed), width=int(round(width * 4)), direction=int(direction), pressure=int(pressure))
def render(tool, pts, W=256, H=128, color=0, argb=0xff000000, scale=0.0, zoom=1.0, bg=0xff, flag_extra=0, xform=None, depth=32, palette_mode=None, line_argb=0, thickness=1.0):
    e = pens_emu.Emu(W, H, depth)
    e.uc.mem_write(e.fb, (bytes(bg) if isinstance(bg, (tuple, list)) else bytes([bg, bg, bg, 255]) if depth == 32 else bytes([bg, bg])) * (W * H))
    e.color_fn = lambda t, c, a: argb
    if xform is None and zoom != 1.0: xform = [zoom, 0, 0, 0, zoom, 0, 0, 0, 1]   # QTransform m11 m12 m13 m21 m22 m23 m31 m32 m33
    e.make_renderer(scale=zoom, xform=xform, flag_extra=flag_extra)
    if palette_mode is not None: e.use_real_palette(palette_mode)
    L = e.make_line(tool, color, pts, thickness_scale=scale, argb=line_argb, thickness=thickness)
    e.call(0xb6c850, [e.holder, L]); e.call(0xb6bbf0, [e.holder])
    raw = bytes(e.uc.mem_read(e.fb, e.bpl * H))
    if depth == 32: return Image.frombytes("RGBA", (W, H), raw, "raw", "BGRA")
    return Image.frombytes("RGB", (W, H), raw, "raw", "BGR;16")
