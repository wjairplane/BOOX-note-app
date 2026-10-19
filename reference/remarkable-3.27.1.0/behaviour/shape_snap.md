# Draw-and-hold shape snap and select-below (xochitl 3.27.1.0)

Source: ARM binary `xochitl` (Ghidra 11.3.2 decompile + disassembly). Tags: **[V]** value or structure read directly from the binary,
**[I]** inferred (meaning, units, naming). "Scene px" = stroke coordinate units (rM2 page 1404 x 1872, about 226 dpi, 89 px = 1 cm).

Functions:

| Address | Role |
|---|---|
| `0x150ed4` | `DrawAndHoldGesture::evaluate` (drawandholdgesture.cpp), vtable slot 1 of vtable `0xccc044` |
| `0x149880` | `DrawAndHoldGesture` slot 0, the pen-down hook |
| `0x44979c` | fit score of a point list against a `ShapeGeometry` |
| `0x44c4e8` | convex hull |
| `0xb60e2c` | `Line` simplifier (Ramer-Douglas-Peucker with extra per-point attributes) |
| `0x44e924` | `ShapesOverlay::updateImage` (shapesoverlay.cpp) |
| `0x149c50` | `PartitionGesture::evaluate`, vtable `0x109d0f4` |
| `0x820d0c` | inlined constructors of both gestures: `DrawAndHoldGesture` at `0x820fd0..0x82105c`, `PartitionGesture` at `0x821140..0x8211ac` |

Gesture activation (QML `00da1f6c:638-667`) [V]:
- DrawAndHold is active only for writing tools and only if `Settings.shapeSnapEnabled` (default true).
- For the selection tool the active gesture is `PartitionGesture` (select below). Other tools have no gestures.

## 1. Constants

| Constant | Value | Tag | Where |
|---|---|---|---|
| Hold time, "still" timer (`QElapsedTimer` at obj+0x08 vs int at obj+0x3c) | **250 ms** | [V] | ctor `0x821260` = 0xfa |
| Evaluate rate limiter (timer at obj+0x18 vs int at obj+0x40) | **100 ms** | [V] | ctor `0x821264` = 0x64 |
| Stillness radius between two evaluate calls | **0.5** (units of the x,y passed to evaluate; scene px [I]) | [V] | `0x151078` |
| Minimum raw stroke points | **10** (`count > 9`) | [V] | `0x151058` |
| Minimum chord (first to last raw point) | `3 / scale` scene units (about 3 screen px) | [V]/[I] | `0x15100c`; `scale = sqrt(det(3x3 view matrix in ctx))` |
| Shape-snap enabled flag (obj+0x44) | default 1, set by `setShapeDetection(Settings.shapeSnapEnabled)` | [V] | ctor `0x82104c` |
| Pre-simplification (RDP) epsilon | **1.0** scene px (position) | [V] | `0x1510a0` `d0 = 1.0` |
| Extra per-point keep tolerances in that RDP | 0.1 / 0.5 / 1.0 (pressure / width / speed, [I] which is which), all enabled | [V] values | `0x1510a4-0x151118` |
| Straight line: max deviation | `< 0.1 * chord` | [V] | `0x151840` |
| Straight line: path length | `< 1.2 * chord` | [V] | `0x151848` |
| Ellipse fit tolerance (normalised radial) | **0.2** | [V] | `0x151ef0` |
| Ellipse accept: inlier fraction | **> 0.9** | [V] | `0x151f08` |
| Rectangle fit tolerance (normalised) | **0.35** | [V] | `0x151ef8` |
| Rectangle accept: inlier fraction | **> 0.95** | [V] | `0x151f10` |
| Fit guard: stroke polyline length vs shape outline length | `polyline < 0.9 * outline` gives score 0 | [V] | `0x4499c8` |
| Circle/square rule: `min(w,h)/max(w,h)` | **> 0.8** gives w = h = (w+h)/2 | [V] | `0x151f00` |
| Polygon branch: start-end gap | `< max(diag/3, 1.0)` (`diag = sqrt(w0^2+h0^2)`, raw box) | [V] | `0x151bf4` |
| Polygon RDP epsilon | `diag / 10` (`diag` from the raw min-area box w0,h0), position only | [V] | `0x152a9c` |
| Polygon vertex counts accepted | simplified point count 4 or 5, i.e. 3 or 4 vertices | [V] | `local_b0._4_4_ - 4U < 2` |
| Polygon accept: `len(simplified) / len(P)` | **> 0.93** | [V] | `0x1536c8` |
| Polygon vertex axis-alignment snap | `15 / scale` scene units | [V] | `0x15318c` |
| Overlay refresh while holding | 100 ms repeating timer (`snapImageTimer`) | [V] | QML `00da87d5:46` |
| Rotation snap after recognition | multiples of pi/4, tolerance 2 deg (0.0349066 rad) | [V] | `0x44e924` literals `0x3fe921fb54442d18`, `0x3fa1df46a2529d39` |
| Line axis snap after recognition | `max(L/3, 10) / scale` | [V] | `0x44e924` ~lines 396-398 |

PartitionGesture (select below): `+0x38` = **250 ms** (still timer), `+0x3c` = **100 ms** (rate limiter), movement threshold **0.5**
(same code shape as DrawAndHold), minimum horizontal extent **89** (QML `00da1f6c:661` `minHorizDistance: 89 // approx 1cm at 227 DPI`),
monotonic-direction ratio **2.0**, and QML `verticalThreshold` 15 / `arrowOffset` 5 (`00da01c3`).

## 2. Hold detection (`evaluate`, called repeatedly while the pen is down)

State: two `QElapsedTimer`s, A (obj+0x08) and B (obj+0x18), and `lastPos` (obj+0x28/0x30). Pen-down hook (slot 0, `0x149880`): if this is the
first sample of the stroke, restart A and B and set `lastPos = (x,y)`. [V]

```
evaluate(x, y, ctx):                       # ctx.line = stroke so far (points: x,y float + width/speed/pressure attrs)
    if !A.isValid(): return NOT_YET(0)
    if B.elapsed() <= 100 ms: return 0       # rate limit: at most one real evaluation per >100 ms
    first = line[0]; last = line[n-1]
    chord = |last - first|
    prev = lastPos; lastPos = (x,y)          # updated only when the rate limiter passed
    if 3/scale > chord  or  n < 10  or  |(x,y) - prev| > 0.5:
        A.restart(); B.restart(); return 0   # moved, too short or too few points: hold timer restarts
    if A.elapsed() <= 250 ms:
        B.restart(); return 0                # still, but not long enough
    # still for > 250 ms, and the last two evaluations were > 100 ms apart
    -> run detection (section 3); returns 1 (accepted) or 2 (rejected, gesture over)
```

Effect [I]: the shape appears after the pen has stayed within 0.5 px for 250 ms, quantised by the 100 ms evaluation grid, so about
250..350 ms. After acceptance both timers are invalidated (`QElapsedTimer::invalidate`). The result map (`type`, `name`, `bounds`, `line`,
`path`, `rotation`) goes to QML as `gestureData`.

## 3. Detection (all numbers from section 1)

```
P = RDP(rawStroke, eps = 1.0)              # keeps first/last; also keeps points where width/speed/pressure jump (see 6.)
chord = |raw.first - raw.last|
dist(p) = |p - raw.last|                   if first ~= last (qFuzzy test with 1e5 factor, so a closed loop)
        = perpendicular distance from p to the infinite line first->last   otherwise
maxDev  = max over P[1..] of dist(p)       # 0 if P has <= 1 point
pathLen = sum of |P[i]-P[i-1]|

# 3a. straight line
if maxDev < 0.1*chord  and  pathLen < 1.2*chord:
    result = { type:1, name:"Straight Line" }  -> "Line accepted as a straight line", return 1
if !shapeSnapEnabled: log "Line rejected", return 2

# 3b. oriented box: minimum-area rectangle of the convex hull of P
hull = convexHull(P)                       # sorted monotone chain
if |hull| < 3: w0,h0 from first/last point, theta = 0
else for each hull edge i: a = atan2(edge); u = cos a*x + sin a*y ; v = cos a*y - sin a*x   (over all hull points)
        area = (max u - min u) * (max v - min v); keep the minimum area -> theta = a, w0 = u extent, h0 = v extent
c    = centre of the AABB of P (the pen-width padding of that box is symmetric, so c = (min+max)/2)
rect = (c.x - w0/2, c.y - h0/2, w0, h0), rotation theta (radians)

# 3c. fit scores (fraction of P's points that are inliers)
score(shape, tol):
    local(p) = R(-theta) * (p - centre(rect))
    inlier(p) = | shape.d(local(p)) | < tol
    if len(polyline P) < 0.9 * length(shape outline): return 0
    return count(inlier) / |P|
  ellipse.d(x,y) = sqrt((x/(w0/2))^2 + (y/(h0/2))^2) - 1
  rect.d(x,y)    = max(|x| - w0/2, |y| - h0/2) / (min(w0,h0)/2)
sE = score(ellipse, 0.2) ; sR = score(rect, 0.35)

# 3d. final box (circle rule), applied after the scores
(w,h) = (w0,h0); if min(w0,h0)/max(w0,h0) > 0.8: w = h = (w0+h0)/2
bounds = (c.x - w0/2, c.y - h0/2, w, h)    # NB: x,y are NOT re-centred after the averaging (quirk, [V]); rotation is about the box centre [I]

# 3e. decision
if sE > 0.9:   type 4 Ellipse (path = 100-segment polygon of the ellipse in bounds)         # circle if w == h
elif sR > 0.95: type 3 Rectangle (addRect(bounds))                                          # square if w == h
else:
    gap = |P.first - P.last|
    if gap >= max(sqrt(w0^2+h0^2)/3, 1.0):  type 0, rejected
    else:
        S = RDP(P, eps = sqrt(w0^2+h0^2)/10)       # position only
        if |S| not in {4,5}: log "Invalid polygon: points = |S|-1, factor = eps"; type 0, rejected
        else:
            V = [ (S[0]+S[last])/2 ] + S[1 .. last-1]          # 3 or 4 vertices, closing point merged
            for i in 1..|V|-1: for j in 0..i-1:                 # in place, later j wins
                 if |V[i].x - V[j].x| < 15/scale: V[i].x = V[j].x
                 if |V[i].y - V[j].y| < 15/scale: V[i].y = V[j].y
            ratio = length(S) / length(P)
            if ratio <= 0.93: log "Invalid polygon : points, ratio, factor"; type 0, rejected
            else: log "Polygon accepted: points, ratio, factor"
                  type = 2 if |V| == 3 else 5 (|V| == 4); path = closed polygon V
accepted -> "Line accepted as a shape" (return 1); type 0 -> "Line rejected as a shape" (return 2)
```

Type numbers and names: 1 = StraightLine (name set explicitly), 3 = Rectangle, 4 = Ellipse [V]. 2 = Triangle (3 vertices) [I]. 5 = general
4-vertex polygon [V]; no name string found for it [U]. Telemetry shape names: StraightLine, Triangle, Rectangle, Ellipse; enum strings Unknown, Triangle, Rectangle, Ellipse.

## 4. What happens after recognition (`ShapesOverlay::updateImage`, every 100 ms and on pen move; pen still down)

`lastPos` follows the pen (QML `onGestureMoved`). On pen-up `finishGesture`: the shape is added as a new stroke only if `lastLine().lineLength() > 0`
(dragging the end back to the start cancels it). [V]

- Straight line (type 1) [V values, [I] reading]: start = first stroke point, end = pen position mapped to scene. `L = |start-end|`,
  `tol = max(L/3, 10) / scale`. Coordinates are rounded to integers. If `|dy| < tol` then `end.y = start.y` (horizontal); if `|dx| < tol` then
  `end.x = start.x` (vertical). The stroke points are re-spaced along the new segment in proportion to their cumulative length.
- Shapes (types 2..5): rotate and scale the shape about its centre so that the stroke end point follows the pen:
  `scale = |c->pen| / |c->origEnd|` (if `|c->origEnd| > 1`, else `|c->pen|`), `rotation_new = fmod(rotation + angleTo(c->origEnd, c->pen) in rad, 2pi)`
  (negative adds 2pi). If the result is within 2 deg of a multiple of pi/4 it snaps to that multiple.

## 5. PartitionGesture (select below)

```
slot0 (pen down): if first sample: A.restart(); B.restart(); lastPos = (x,y)
evaluate(x, y, ctx):
    if !A.isValid(): return 0
    if B.elapsed() <= 100 ms: return 0
    dx = |line.last.x - line.first.x|              # only x is tested; y is never tested
    move = |(x,y) - lastPos|; lastPos = (x,y)
    if dx < ctx.minHorizDistance (89)  or  move > 0.5:  A.restart(); B.restart(); return 0
    if A.elapsed() <= 250 ms: B.restart(); return 0
    log "PartitionPageGesture accepted"; invalidate timers
    pos = sum of positive successive x steps over all points; neg = sum of |negative steps|
    if last.x > first.x:  ok = (neg == 0) or pos/neg >= 2      # mostly monotonic to the right
    else:                 ok = (pos == 0) or neg/pos >= 2      # mostly monotonic to the left
    return ok ? 1 : 2
```

[V] Then QML (`00da01c3`): a "Select below" `ContextualMenu` button is shown at the hold start (x clamped to the screen, `y + 5`). While the pen is
still down, `onGestureMoved`: if the pen is more than 15 scene px **below** the hold start (`initialPos.y - pos.y < -15`) the pending action is
`SelectBelow`, otherwise `WaitForInput`. On pen-up `SelectBelow` is applied immediately; in `WaitForInput` the button stays until tapped
(touching elsewhere cancels). The selection area is `getArea(sceneRect.left, sceneRect.right, sceneRect.bottom)` closed by the drawn line.

## 6. App implementation notes

- Replace the app's 600 ms / 10 px hold by: still for **250 ms** (evaluate no more than every 100 ms; require movement <= **0.5** px between
  evaluations), at least 10 points, chord >= 3 screen px. The 0.5 px radius is very strict for a finger-less pen on Android; a looser radius
  would be an app deviation, so make it a named constant.
- Use RDP eps 1.0 for P. Geometry-only RDP is enough for a first port; the firmware additionally keeps points where width/speed/pressure change
  (callee `0xb60e2c`, gated by tool-type bit masks `0x81900b` / `0xa1f00f`), which only adds vertices.
- Implement the order exactly: line, then ellipse (> 0.9), then rectangle (> 0.95), then 3/4-vertex polygon. The fit score is the fraction of
  vertices of P (not length weighted) within tolerance.

## 7. Not recovered

- The caller cadence of `evaluate` (which loop or timer calls slot 1 and how often); inferred 100 ms from the rate limiter. The slot 0 caller is
  `0x14c580` (pen sample dispatcher), the slot 1 caller was not found.
- Whether the x,y passed to evaluate are scene or view coordinates (0.5 radius unit) and whether the ctx matrix is scene-to-view
  (so `3/scale` means 3 screen px) - both inferred.
- Which of the three attribute tolerances (0.1 / 0.5 / 1.0) belongs to pressure, width and speed, and the exact tool-type gating.
- Name string of type 5 and the numeric values of the `ShapeGeometry::Type` enum (2 and 5 inferred from code).
- Exact 100-point ellipse path parametrisation (`0x444a94`), the convex-hull tie handling and the direction convention of
  `QLineF::angleTo` in the rotate/scale follow-up (section 4); the PartitionGesture `Select below` hit region beyond the QML above.
- The ellipse/rectangle outline length used in the 0.9 guard is `QPainterPath::length()` of the shape path (100-segment polygon for the
  ellipse, 2(w0+h0) for the rectangle); computed from the code shape, not run.
