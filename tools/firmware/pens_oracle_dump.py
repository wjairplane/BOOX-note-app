"""Dump reference renders of xochitl's pens (real firmware code under Unicorn) to PNG.
Usage: python3 -I pens_oracle_dump.py OUTDIR   (needs unicorn+capstone+pyelftools+Pillow; see pens_emu.py paths)
Each PNG is a contact sheet: one labelled row per parameter value, a horizontal 20-point stroke, bg white, 1:1 pixels.
Point units are the .rm v2 units: width = page px (file raw/4), speed/direction/pressure raw file values."""
import sys, os, json, math
sys.path.insert(0, "/home/user/BOOX-note-app/tools/firmware")
from pens_oracle import *
from PIL import Image, ImageDraw
NAMES = {4: "fineliner1", 5: "highlighter1", 12: "paintbrush2", 13: "mech_pencil2", 14: "pencil2", 15: "ballpoint2", 16: "marker2",
         17: "fineliner2", 18: "highlighter2", 19: "solidpen", 21: "calligraphy", 23: "shadingmarker"}
BASE = dict(speed=100, width=8.0, direction=128, pressure=128)
SWEEPS = {
    "pressure": [0, 16, 32, 64, 96, 128, 160, 192, 224, 255],
    "speed": [0, 50, 100, 200, 400, 800, 1600, 3200],
    "direction": [0, 32, 64, 96, 128, 160, 192, 224, 255],
    "width": [1, 2, 3, 4, 6, 8, 12, 16, 24, 32],
}
def row(tool, key, val, scale=1.0, palette_mode=1, color=0, W=300, H=44):
    p = dict(BASE); p[key] = val
    pts = [pt(14 + i * 14, H // 2, p["speed"], p["width"], p["direction"], p["pressure"]) for i in range(20)]
    return render(tool, pts, W, H, color=color, scale=scale, palette_mode=palette_mode).convert("RGB")
def sheet(tool, key, palette_mode=1, color=0, scale=1.0):
    vals = SWEEPS[key]; H = 44
    im = Image.new("RGB", (400, H * len(vals)), (255, 255, 255)); d = ImageDraw.Draw(im)
    for i, v in enumerate(vals):
        im.paste(row(tool, key, v, scale, palette_mode, color), (100, i * H))
        d.text((4, i * H + 14), f"{key}={v}", fill=(200, 0, 0))
    return im
def curve(tool, palette_mode=1, color=0):
    pts = []
    for i in range(80):
        t = i / 79
        pts.append(pt(20 + t * 360, 60 + 40 * math.sin(t * 6.28 * 1.5), 150 + 100 * math.sin(t * 9), 6 + 6 * t, int(128 + 100 * math.sin(t * 4)), int(40 + 200 * math.sin(t * 3.14))))
    return render(tool, pts, 400, 120, color=color, palette_mode=palette_mode).convert("RGB")
if __name__ == "__main__":
    out = sys.argv[1]; os.makedirs(out, exist_ok=True)
    meta = {"base_point": BASE, "units": "width px, speed/direction/pressure raw uint", "sweeps": SWEEPS, "note": "palette_mode=1: firmware grayscale conversion (RM2)"}
    for tool, nm in NAMES.items():
        for key in SWEEPS:
            sheet(tool, key).save(f"{out}/{nm}_t{tool}_sweep_{key}.png")
        for sc in (1.0, 2.0, 3.0): pass
        curve(tool).save(f"{out}/{nm}_t{tool}_curve.png")
        print("done", nm)
    json.dump(meta, open(f"{out}/meta.json", "w"), indent=1)
