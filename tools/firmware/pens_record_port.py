"""Python port of the recording side (LineBuilder::addSample 0xb63490 / 0xb62de4), checked against pens_recorder.Recorder (firmware under Unicorn).
record(tool, T, samples) -> list of (x, y, speed_raw, width_raw, direction_raw, pressure_raw)
sample = (x, y, pressure01, tiltX_rad, tiltY_rad). T = thickness (1,2,3 = Thin/Medium/Thick, divided by the page's penScale; eraser: squared)."""
import math
PI2 = 2 * math.pi
def rnd(x): return int(math.floor(x + 0.5)) if x >= 0 else -int(math.floor(-x + 0.5))   # roundf
def norm2pi(a):
    if a < 0: return math.fmod(a, PI2) + PI2
    if a >= PI2: return math.fmod(a, PI2)
    return a
def smooth(t): return (3 - 2 * t) * t * t
TOOL_SPEED_PRESSURE = (0, 1, 3, 12, 15, 23)   # 0x81900b mask (function 0xb5f1a8): tools whose pressure is reduced by speed (only evaluated in the old-style branch)
NEW_STYLE = (13, 14, 15, 16, 19, 20, 21, 23)  # mask 0x5cf: handled by 0xb62de4
def record(tool, T, samples, zoom=1.0, rot_deg=0.0, hand=0, style=0, flagA=0):
    out = []; prev = prev2 = None; last = None
    for s in samples:
        x, y, p, tx, ty = s
        if prev is None: prev = prev2 = s
        dx, dy = x - prev[0], y - prev[1]
        dirc = norm2pi(math.atan2(dy, dx))
        if tool in NEW_STYLE:
            tilt = math.atan(math.sqrt(math.tan(ty) ** 2 + math.tan(tx) ** 2)); tilt = min(tilt, 1.0)
            speed = zoom * math.hypot(dx, dy)
            direction = dirc
            Tp = T / 1.35 if T > 1.0 else T
            pres_byte = None
            if tool == 13:
                width = 4.0 * Tp
                pres_byte = 179 if p < 0 else 255 if p > 1 else rnd((0.7 + smooth(p) * 0.3) * 255)
            elif tool == 14:
                tf = 0.0 if tilt < 0.5235988 else ((tilt - 0.5235988) / 0.4363323 if tilt <= 0.9599311 else 1.0)
                tf = tf * tf if style == 0 else tf ** 4
                if last is not None: p = p * 0.2 + (last["pressure"] / 255.0) * 0.8
                pres_byte = rnd(p * 255); width = (p + 2.0 + tf * 15.0) * T
            elif tool == 15:
                width = max(p * 3, 2.0) * Tp; pres_byte = rnd(p * 255)
            elif tool == 16:
                width = ((p * 0.5 + 0.5) * tilt * tilt * 10 + 2.5) * T; pres_byte = rnd(p * 255)
            elif tool in (19, 20):
                width = 2 * T; pres_byte = rnd(p * 255)
            elif tool == 21:
                nib = ((40.0 if hand else 170.0) + rot_deg) * math.pi / 180.0
                az = math.atan2(math.sin(ty), math.sin(tx))
                if az < 0: az += PI2
                a = dirc - az
                if a < 0: a += PI2
                a -= (math.pi / 2 - nib)
                if a < 0: a += PI2
                if a > math.pi: a -= PI2
                f = max(0.0, (1.0471976 - abs(a)) / 1.0471976)
                width = (f * p * 4.5 + 1.0) * T
                width = max(width, 1.5)
                pres_byte = rnd(p * 255)
                if last is not None: width = width * 0.25 + (last["width"] * 0.25) * 0.75
            elif tool == 23:
                pf = 1 / 3 if p < 0.1 else ((lambda x: x + (1 - x) / 3)((p - 0.1) / 0.2) if p <= 0.3 else 1.0)
                width = (2.0 + 10.0 * T) * pf; pres_byte = rnd(p * 255)
                if last is not None: speed = speed * 0.1 + (last["speed"] * 0.25) * 0.9
            pt = dict(x=x, y=y, speed=rnd(speed * 4), width=rnd(width * 4), direction=rnd(direction * 255 / PI2), pressure=pres_byte)
        else:   # old-style tools (first half of 0xb63490)
            dx2, dy2 = prev[0] - prev2[0], prev[1] - prev2[1]
            angp = norm2pi(math.atan2(dy2, dx2))
            ps = min((p + prev[2]) * 0.5, 1.0)
            tmag = math.hypot(tx, ty)                       # tilt magnitude (fVar8)
            phi = math.atan2(ty, tx); sn, cs = math.sin(phi), math.cos(phi)
            d = math.hypot(dx, dy)
            near = (min(abs(x), abs(prev[0])) <= abs(dx) * 1e5) or (min(abs(y), abs(prev[1])) <= abs(dy) * 1e5)
            if near and d > 0:
                perp2 = 1 - ((dx * cs + dy * sn) / d) ** 2   # sin^2 of the angle between stroke direction and tilt direction
                perp = math.sqrt(max(perp2, 0.0))
            elif near: perp = 0.0
            else: perp = math.hypot(dx + cs, dy + sn)       # displacement tiny relative to the coordinates (also the very first sample): |d + tilt unit vector|
            perp = perp ** 3.5
            d2 = math.hypot(dx2, dy2)
            speed = (d + d2) * zoom * 0.5
            if flagA == 0 and tool in TOOL_SPEED_PRESSURE:
                f = 1.0 - ((d + d2) * 0.5) / 100.0
                if f < 0.5: ps *= 0.5
                elif f < 1.0: ps *= f
            direction = (angp + dirc) * 0.5
            pres_byte = rnd(ps * 255)
            Tp = T
            fixed_raw = None
            if tool in (0, 12):
                ps = max(ps, 0.25); pres_byte = rnd(ps * 255)
                a, b = (5.0, 10.0) if style == 0 else (4.5, 4.5)       # (tilt coef, pressure coef)
                width = b * ps ** 4.5 + a * tmag ** 4
                if width < 2.0: width = 2.0
            elif tool == 1:
                w = (tmag ** 4 - 0.5) * 20.0 * perp
                w = 1.5 if w < 1.5 else (40.0 if w >= 40.0 else w)
                Tp = T / 1.5
                width = float(int(w + ps * 1.5))
            elif tool == 2:
                Tp = T / 1.35 if T > 1.0 else T
                width = max(float(int(ps * 3.0)), 2.0)
                if T == 1.0:                       # exact T==1 ('thin'): special branch 0xb63ea0
                    if ps < 0.7: width = 2.0; pres_byte = 0xb3
                    else: width = float(int(ps * 3.0)); pres_byte = rnd(ps * 255)
            elif tool == 3:
                w = min(ps * ps * 4.0, 4.0)
                m = min(max(abs(tx), abs(ty)), 1.0)
                w = w + perp * 10.0 * m ** 6.0 + 2.5
                width = 2.0 if w < 2.0 else (20.0 if w >= 20.0 else float(int(w)))
            elif tool in (4, 17):
                width = 2.0
            elif tool in (5, 18):
                width = 30.0
                if flagA: fixed_raw = 120
            elif tool in (6, 22):
                width = 10.0 * T if flagA else 10.0       # eraser: thickness enters squared when flagA (0xb63a20)
                Tp = T
            elif tool == 7:
                if T <= 1.0: width = 3.0
                else: width = T / 1.35 * 3.0; Tp = 1.0
            elif tool in (8, 10, 11):
                fixed_raw = 16
            else: raise NotImplementedError(tool)
            if fixed_raw is not None: wraw = fixed_raw
            else:
                w = width * Tp
                wraw = 8 if w <= 2.0 else rnd(w * 4)
            pt = dict(x=x, y=y, speed=rnd(speed * 4), width=wraw, direction=rnd(direction * 255 / PI2), pressure=pres_byte)
        out.append(pt); last = pt
        prev2, prev = prev, s
    return out
