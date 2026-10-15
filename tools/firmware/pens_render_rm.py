"""Render the pen strokes of a .rm (v6) file with the real xochitl pen code (oracle). Needs rmscene (pip) on PYTHONPATH/pylibs.
Usage: python3 -I pens_render_rm.py file.rm out.png [palette_mode=1] [flag=0]"""
import sys
sys.path.insert(0, "/tmp/claude-0/-home-user-BOOX-note-app/49c791b8-36e3-5584-bfb4-b5d40653e991/scratchpad/pylibs")
sys.path.insert(0, "/home/user/BOOX-note-app/tools/firmware")
from rmscene import read_blocks
from rmscene.scene_items import Line
import pens_emu
from PIL import Image
TOOLID = {"PAINTBRUSH_1": 0, "PENCIL_1": 1, "BALLPOINT_1": 2, "MARKER_1": 3, "FINELINER_1": 4, "HIGHLIGHTER_1": 5, "ERASER": 6, "MECHANICAL_PENCIL_1": 7, "ERASER_AREA": 8,
          "PAINTBRUSH_2": 12, "MECHANICAL_PENCIL_2": 13, "PENCIL_2": 14, "BALLPOINT_2": 15, "MARKER_2": 16, "FINELINER_2": 17, "HIGHLIGHTER_2": 18, "CALLIGRAPHY": 21, "SHADER": 23}
COLORID = {"BLACK": 0, "GRAY": 1, "WHITE": 2, "YELLOW": 3, "GREEN": 4, "PINK": 5, "BLUE": 6, "RED": 7, "GRAY_OVERLAP": 8, "HIGHLIGHT": 9, "GREEN_2": 10, "CYAN": 11, "MAGENTA": 12, "YELLOW_2": 13}
def load_lines(path):
    out = []
    with open(path, "rb") as fh:
        for b in read_blocks(fh):
            v = getattr(getattr(b, "item", None), "value", None)
            if isinstance(v, Line): out.append(v)
    return out
def render_file(path, pal=1, flag=0, margin=20):
    lines = load_lines(path)
    xs = [p.x for l in lines for p in l.points]; ys = [p.y for l in lines for p in l.points]
    x0, y0 = min(xs) - margin, min(ys) - margin
    W, H = int(max(xs) - x0 + margin), int(max(ys) - y0 + margin)
    e = pens_emu.Emu(W, H, 32)
    e.uc.mem_write(e.fb, b"\xff\xff\xff\xff" * (W * H))
    e.make_renderer(xform=[1, 0, 0, 0, 1, 0, -x0, -y0, 1], flag_extra=flag)
    e.use_real_palette(pal)
    n = 0
    for l in lines:
        tid = TOOLID.get(l.tool.name)
        if tid is None or tid in (0, 1, 2, 3, 7, 6, 8): continue   # legacy/eraser not emulated
        argb = 0
        c = getattr(l, 'color_rgba', None)
        if c is not None: argb = (c[3] << 24) | (c[0] << 16) | (c[1] << 8) | c[2]   # straight ARGB, used for colour id 9 (HIGHLIGHT)
        pts = [dict(x=p.x, y=p.y, speed=p.speed, width=p.width, direction=p.direction, pressure=p.pressure) for p in l.points]
        L = e.make_line(tid, COLORID.get(l.color.name, 0), pts, thickness_scale=float(l.starting_length), argb=argb, thickness=float(l.thickness_scale))
        e.call(0xb6c850, [e.holder, L]); e.call(0xb6bbf0, [e.holder]); n += 1
    raw = bytes(e.uc.mem_read(e.fb, e.bpl * H))
    return Image.frombytes("RGBA", (W, H), raw, "raw", "BGRA"), n
if __name__ == "__main__":
    im, n = render_file(sys.argv[1], int(sys.argv[3]) if len(sys.argv) > 3 else 1, int(sys.argv[4]) if len(sys.argv) > 4 else 0)
    im.convert("RGB").save(sys.argv[2]); print("lines drawn", n, im.size)
