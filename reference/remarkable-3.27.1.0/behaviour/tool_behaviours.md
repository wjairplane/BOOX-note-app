# Tool behaviours: firmware vs InkBridge

[V] = read in QML/decompile, [I] = inferred, [U] = not recovered. App references are to `app/src/main/kotlin/app/inkbridge/...` and `rmformat/src/main/kotlin/app/inkbridge/rm/...`. Earlier deep-dive specs: scratchpad `spec_eraser.md`, `pen_spec.md`, `spec_pageslider.md`, `audit*_notebook.md`; they are not repeated here.

## 1. Stroke life cycle (ScenePenInputHandler, fn 0x14c580 / 0x453e20)

- On pen-down all registered touch/gesture filters see the sample first; a new stroke waits **up to 1000 ms** (10 ms polling) for a previous stroke that is still "intermediate"; otherwise "Cancelling stroke in intermediate state..." [V].
- "Cancelling stroke due to page loading", "Cancelling eraser stroke due to active selection" (an eraser stroke is dropped while an item selection exists) and "Cancelling selection stroke due to previously-active selection" [V, fn 0x14c580]. App: `PenSurface`/`PageSession.selectionStroke` lets the eraser work with a selection and treats a selection-tool stroke inside the frame as a drag: deviation (small).
- Stroke completion dispatch (`00da1f6c:690-722`) [V]: highlighter -> `highlightWithLine(stroke, snap)`; eraser (tool 6 and Erase-selection 8) -> `eraseWithLine`; selection tool -> see 3; else `addDrawingLine` then `queryAddStrokeMode` (refresh_policy.md section 5).
- Pen input noise filters exist as `FILTER_PEN_MEASUREMENT_NOISE` / `FILTER_ERASER_MEASUREMENT_NOISE` (peninputhandler config, fn 0x457690, strings 0x110bedc/0x110bebc). Not decoded; the app ports the recorder (`FirmwareRecorder`) and renderer (`PixelInk`) and checks them against emulation, so smoothing/pressure curves are covered by those ports. Remaining risk: Onyx raw pressure scale (`EpdController.getMaxTouchPressure`, default 4096 in `PenSurface.maxPressure`) vs Wacom 0..4095 of the rM2 digitiser (pen_spec.md): [U].

## 2. Eraser

| Firmware | App | Verdict |
|---|---|---|
| Plain eraser tool 6, "Selection eraser" (Erase selection) tool 8; foldout also "Erase all strokes" (`00ea5e6e`, `00ea7863`) | all three present | ok |
| Size is thickness squared: `calculateEraserThickness(t) = t*t`, default `calculateEraserThickness(2.4)/penScale` (`00da1f6c:645-681`) | `ERASER_RADII = 14/22/36` view px (`NotebookScreen.kt:85`) | radii differ; firmware page-px radius for thickness 1/2/3 is **5/20/45** [I, spec_eraser.md section 2] |
| Cut happens once, at pen-up, sub-segment accurate (new end points linearly interpolated in x, y, speed, width, pressure) (spec_eraser.md 3) | cut at pen-up, densified at max(r/2,2) | acceptable; app additionally adds `q.width/8` to the radius, firmware does not [I] |
| Live trail drawn by the pen renderer as MaskedEraser (tool 22, light "faded" pixels) | trail drawn as app preview | grey level [U] |
| Ignore eraser lines of > 30000 points | no guard | add |
| Erase-selection (tool 8): interior of the closed lasso, auto-closed | present | ok |

## 3. Selection tool (lasso)

- Tap detection: a selection stroke whose bounding box `max(w,h) < 30` scene px is a *tap*: first try `selectImageAtPoint(centre)`; otherwise the stroke is passed to `selectWithLine(stroke, mode)` with `mode = AcceptTapGesture` when in text mode else `IgnoreTapGesture` (`00da1f6c:699-716`) [V]. `pointCount == 0` clears the selection. App: tap if extent < 16 *view* px (`PageSession.selectionStroke`): deviation (zoom-dependent in app, scene-fixed in firmware).
- Lasso closing: `selectWithLine` takes the polyline as a polygon (auto-closed) and selects every item whose geometry is hit (`LineSelectionMode`: InitalSelection / ToggleSelection); details of the hit test (centre points vs any point) not recovered [U]. App: lasso selects strokes by `SelectionGesture`/`PageEditor` rules (see audit_notebook.md).
- Selection frame handles: 30 px squares, 40 px rotate circle, 15 px touch margin (already ported); drag threshold 10 (`audit_notebook.md:106`).
- Clipboard: after Copy/Cut the bar "Copied to clipboard. Tap any page with Marker to paste." stays until dismissed ("Clear clipboard"); pasting happens at the tap point (`getSelectionPastePos`); app has the hint but not the "Clear clipboard" action. Text copied from a typed-text note on a non-note page shows "Text copied to clipboard. Go to a notepage to paste." (`00da1f6c:997`).
- Tap outside the selection rect clears it (`00da6487:229-236`); tapping an image selects it (`selectImageAtPoint`) even without the lasso tool; tapping a link (internal page links, checkbox) follows it (`linkAt`, `linkHandler.activate`, inversion flash of the link rect) [V]. App: none of these tap behaviours (no links/images).
- **Select below** (hold a horizontal line): `PartitionSelectGesture` (`00da01c3`): vertical threshold 15 px, arrow offset 5; action `SelectBelow` selects the area from the line to the page bottom (`getArea(left, right, bottom)`); gesture id `PartitionGesture`; log "PartitionPageGesture accepted". App has "hold a horizontal line to select everything below it" but detects the line with its own heuristic (`ShapeSnap.isHorizontalLine`, |dx| > 3|dy|) [deviation: thresholds].

## 4. Draw-and-hold: shape snapping and straight lines

Firmware (`DrawAndHoldGesture::evaluate`, fn 0x150ed4; `ShapeDetector`, shapedetector.cpp; `Settings.shapeSnapEnabled` default **true**; toolbar "Enable shapes" `00ea79f5`):
- The gesture is evaluated while the pen is down and still; it needs **>= 10 points** (`FUN_00b5f574 < 10` rejects) and the pen position may move at most **0.5 scene px** between evaluations or both elapsed timers restart; two `QElapsedTimer` thresholds (object +0x3c, +0x40; hold durations set in the constructor, **values not recovered**) gate "shape" vs "straight line" [I]. Log lines: "Line accepted as a shape", "Line rejected as a shape", "Line accepted as a straight line", "Line rejected", with `maxDistance={} accepted={}` and `lengthRatio={} accepted={}` (straight-line test uses the maximum distance of points from the chord and the ratio chord/length).
- Early test compares the chord (first to last point) with `3.0 / scale` (3 view px in scene units); direction of the comparison needs a second pass [U].
- Shape analysis constants found in the literal pool (doubles) of fn 0x150ed4 [V values, [I] roles]: **0.1** and **1.2** (multiplied with the first-to-last chord length: `local_290 = chord*0.1`, `local_298 = chord*1.2`; tolerance band for the straight-line / closure test), **0.2** and **0.35** (passed as parameters to two fit evaluations `FUN_0044979c` of the oriented box, probably ellipse vs rectangle tolerance), **0.8** (ratio shorter/longer side of the oriented bounding box: > 0.8 makes the shape a **circle**, both radii replaced by their mean), **0.9 / 0.95** (the two fit scores must both be <= these to accept the ellipse), **0.93** (polygon: ratio of fitted-polygon to stroke measure must be > 0.93, else "Invalid polygon: points = {}, factor"; below it "Polygon accepted: points, ratio, factor"), a point-count comparison against 12/13 inside the polygon branch, and 1e5 / 1e12 as +-infinity sentinels. The recognised result carries `bounds`, `rotation`, `shape` (`sceneview::ShapeGeometry::Type`); a "Straight Line" label is used for the line case; `ShapesOverlay` previews with `snapImageTimer` every 100 ms (`00da87d5:45`).
- App (1.2.0): `HoldGesture` uses the firmware timing (250 ms still, 100 ms looks, 0.5 page-unit radius) and `ShapeSnap.detect` follows the recovered algorithm in shape_snap.md (RDP 1.0, line 0.1/1.2, ellipse 0.2/0.9, rectangle 0.35/0.95 on the minimum-area box of the hull, circle rule 0.8, 3/4-corner polygon with 15 px axis snap and the 0.93 ratio, line levelling within max(L/3, 10)). Deviations: the 3 px chord rule is tested on the stroke's size (a closed loop has no chord); the live preview, the drag-to-rotate/scale follow-up and the 45 degree rotation snap are not implemented (the snapped shape comes out selected instead); the select-below hold still triggers from any pen tool, the firmware ties it to the selection tool.
- While a snap preview is active the whole view is in Animation mode (refresh_policy.md section 4).

## 5. Highlighter

- Tool `Highlighterv2`; colours HighlighterGray/Pink/Green/Yellow... (colour table 0xccc010); the pen foldout shows a toggle **"Snap to text"** (`00eaba89:386-411`, key `snapHighlighterToText`) only for the highlighter; on stroke completion `controller.highlightWithLine(stroke, SnapEnabled|SnapDisabled)`; snapping builds a clean line from the text glyph boxes under the stroke (`addSnappedHighlightLine`, strings at 0x10ab70c) in typed text, PDFs and ebooks. App (1.2.0): the toggle is in the highlighter's pen menu; on PDF pages a stroke becomes a `GlyphRange` highlight of the text under it (PdfBox text positions; one box per line, first to last character touched); typed text and ebooks are not covered. The firmware's exact line-building rule (`addSnappedHighlightLine`) was not recovered. Highlighted strokes are not pure black/white, so they use the delayed 1 s quality refresh (refresh_policy.md section 5).

## 6. Typed text tool (completely absent in the app)

From QML (`00da6487`, `00ea90a7`, `00da1f6c`, `00daebb5`, `00dae71c`):
- Enter text mode by **double tap** on the page (second tap within **300 ms** and **0.6 cm** of the first, inside the text bounds + 50 px side margin) or via toolbar `typing` ("Add text", "Edit text", "Automatic reflow").
- Taps in text mode: 1 tap on the cursor (box 0.7 cm wide) = selection menu; 2 taps = select word; 3 = paragraph; 4 = all; the cursor drag handle area is 1 cm wide, drag threshold 0.2 cm, vertical lead 0.8 cm.
- Cursor blink: shown 250 ms after interaction; text selection auto-scroll tick 50 ms; format menu (80x80 button, foldout of `formattingOptions` rows of 80 px) hides 1500 ms after the last key.
- Text styles: Title, Subheading, Body text (+ bold, italic, lists, `Indent/Unindent`, `TitleStyle` key actions); page text settings: Font, Font size (`font-scale-`), Line spacing (minimum/medium/maximum), Page margins (minimum/medium/maximum), Justification (left/justify); default text margin `documentViewTextEditSideMargin = 200` (`00d82ba4:139`).
- Virtual keyboard (`00e484bb`): key size 100, font 34, popup keys min margin 20, row split when > 5 alternatives, long press 300 ms, repeat 250 ms -> 30 ms.

## 7. Undo / redo grouping

- Firmware: undo is a stack of scene actions with macros: `macro::undo`, `stack::undo`, per-CRDT actions (`create-group-crdt`, `delete-group-crdt`, `add-layer-crdt`, `move-layer-crdt`, `scene-doc-visible`, `background-visible`, `set-current-layer`); one erase (any number of cut strokes) = one `SceneMacroAction`; two-finger tap = undo, three-finger tap = redo, enabled only when `undoAvailable`/`redoAvailable`; handwriting conversion has its own "Undo" notification button (`00d9f14b`, `00daf19e`). Stack size limit not found [U].
- App: `PageEditor` keeps up to `MAX_UNDO = 100` whole-page block snapshots (`PageEditor.kt:521`); one user action = one snapshot (erase, move, paste ...). Equivalent for the user; memory use grows with page size (a snapshot per action is heavy for pages near the firmware's 7.49 M point limit).

## 8. Pen/menu details cross-checked as matching

Two quick-switch pen slots with remembered colour/thickness (`LastWritingTool`); thickness 1-3 grid; pen foldout widths 480, eraser 376; finger-gesture distances (0.6/3.0/1.0/0.3 cm); 2/3/5 finger taps; pen-close lockouts 500 ms and 200 ms; shape default on; Last-used templates ("RecentTemplates").

## 9. Top deviations to fix (tool side)

1. Eraser radii 5/20/45 page px and 30000-point guard.
2. Shape snap: use firmware tests (>= 10 points, 0.5 px stillness, 0.8 circle rule, 0.93 polygon rule) and the Enable-shapes toggle semantics.
3. Selection tap threshold 30 scene px (not 16 view px) and tap-to-select image; tap outside clears.
4. Highlighter "Snap to text" (needs PDF text layer).
5. Typed text tool, double-tap text entry, keyboard.
6. Cancel eraser strokes while a selection is active.
