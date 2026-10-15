"""Compare the Python ports in pens_port.py against the oracle (firmware code under Unicorn). Usage: python3 -I pens_verify.py [N]
Prints, per pen, total ink pixels in the oracle and the number of differing pixels (mismatch)."""
import sys, random
sys.path.insert(0, "/home/user/BOOX-note-app/tools/firmware")
from pens_oracle import render, pt
from pens_port import *
import numpy as np
W, H = 128, 64
def orc(tool, pts, **kw):
    return np.array(render(tool, pts, W, H, **kw).convert("L"))
def rand_pts(rng, k, zoom=1.0):
    return [pt(rng.uniform(10, 60 if zoom > 1 else 118), rng.uniform(10, 30 if zoom > 1 else 54), rng.randint(0, 300), rng.uniform(2, 14), rng.randint(0, 255), rng.randint(0, 255)) for _ in range(k)]
def run(N=6, seed=1):
    rng = random.Random(seed)
    cases = [(1.0, 1.0), (1.0, 2.0), (2.0, 1.0), (0.5, 1.0), (1.5, 3.0)]
    pens = {
        4: lambda P, z, s: render_solid(P, 1, 2, z), 17: lambda P, z, s: render_solid(P, 1, 2, z), 19: lambda P, z, s: render_solid(P, 1, 2, z),
        21: lambda P, z, s: render_solid(P, 1, 2, z), 5: lambda P, z, s: render_solid(P, 0, 1, z), 18: lambda P, z, s: render_solid(P, 0, 0, z),
        14: lambda P, z, s: render_pencil([(p["x"] * z, p["y"] * z, round(p["width"]) / 4.0, p["pressure"]) for p in P], W, H, z, s),
        13: lambda P, z, s: render_pencil([(p["x"] * z, p["y"] * z, round(p["width"]) / 4.0, p["pressure"]) for p in P], W, H, z, s),
        15: lambda P, z, s: render_ballpoint([(p["x"] * z, p["y"] * z, round(p["width"]) / 4.0, p["pressure"], p["speed"]) for p in P], W, H, z, s),
        16: lambda P, z, s: render_marker2([(p["x"] * z, p["y"] * z, round(p["width"]) / 4.0, p["speed"]) for p in P], W, H, z, s),
        12: lambda P, z, s: render_paintbrush2([(p["x"] * z, p["y"] * z, round(p["width"]) / 4.0, p["pressure"], p["speed"]) for p in P], W, H, z, s),
    }
    def render_solid(P, j, c, z):
        g = StrokeGeom(j, c)
        for p in P: g.add(p["x"] * z, p["y"] * z, round(p["width"]) / 4.0 * z)
        g.finish()
        return fill_tris([tuple(v.p for v in t) for t in g.triangles()], W, H)
    for tool, f in pens.items():
        ink = diff = 0
        for z, s in cases:
            for _ in range(N):
                P = rand_pts(rng, rng.randint(3, 8), z)
                o = orc(tool, P, zoom=z, scale=s) < 250
                m = f(P, z, s)
                ink += int(o.sum()); diff += int((o ^ m).sum())
        print(f"tool {tool:2d}: ink px {ink:7d}  mismatching px {diff:5d}  ({100.0 * diff / max(ink, 1):.3f}%)")
if __name__ == "__main__":
    run(int(sys.argv[1]) if len(sys.argv) > 1 else 6)
