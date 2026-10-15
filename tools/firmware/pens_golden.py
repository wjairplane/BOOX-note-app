"""Write golden test vectors: strokes + oracle (real firmware code) renders, for validating a Kotlin port pixel by pixel.
Usage: python3 -I pens_golden.py OUTDIR. Each case: NAME.json {tool,color,startingLength,zoom,transform,palette_mode,points[{x,y,speed,width_raw,direction,pressure}]} + NAME.png (RGBA, 128x64, bg white, 1:1)."""
import sys, os, json, random
sys.path.insert(0, "/home/user/BOOX-note-app/tools/firmware")
from pens_oracle import render, pt
PENS = {4: "fineliner1", 5: "highlighter1", 12: "paintbrush2", 13: "mechpencil2", 14: "pencil2", 15: "ballpoint2", 16: "marker2", 17: "fineliner2", 18: "highlighter2", 19: "solidpen", 21: "calligraphy"}
if __name__ == "__main__":
    out = sys.argv[1]; os.makedirs(out, exist_ok=True)
    rng = random.Random(7)
    for tool, nm in PENS.items():
        for i in range(6):
            zoom = [1.0, 1.0, 1.0, 2.0, 0.5, 1.5][i]; ts = [0.0, 1.0, 2.0, 0.0, 5.0, 12.5][i]
            k = rng.randint(3, 9)
            lim_x, lim_y = (118, 54) if zoom <= 1 else (60, 28)
            pts = [pt(rng.uniform(10, lim_x), rng.uniform(10, lim_y), rng.randint(0, 400), rng.uniform(2, 14), rng.randint(0, 255), rng.randint(0, 255)) for _ in range(k)]
            color = 0
            im = render(tool, pts, 128, 64, color=color, scale=ts, zoom=zoom, palette_mode=1)
            name = f"{nm}_t{tool}_{i}"
            im.save(f"{out}/{name}.png")
            json.dump({"tool": tool, "color": color, "startingLength": ts, "thicknessScale": 2.0, "zoom": zoom, "transform": "scale(zoom), no translation", "palette_mode": 1, "antialias_flag": 0,
                       "canvas": [128, 64], "points": [{"x": p["x"], "y": p["y"], "speed": p["speed"], "width_raw": p["width"], "direction": p["direction"], "pressure": p["pressure"]} for p in pts]},
                      open(f"{out}/{name}.json", "w"), indent=1)
    print("ok")
