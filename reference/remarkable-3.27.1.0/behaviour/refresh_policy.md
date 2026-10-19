# E-ink refresh policy of xochitl 3.27.1.0 (rM2) and its mapping to Onyx

Marks: [V] read in decompile/QML, [I] inferred. Addresses are xochitl vaddrs (ARM). Decompiles were made with Ghidra 11.3.2 from a copy of the project (functions created at the listed addresses; nothing in the original project was changed).

## 1. Layers

```
QML  Epaper.ScreenModeItem {mode: UI|Content|Animation|Mono|Pen|Sleep}   (regions that ask for a screen mode)
 +-> EPFramebuffer (rm.framebuffer)  keeps one QRegion per mode (fn 0x5d4c0c: setScreenMode, 6 regions, modes >= 6 -> "Invalid screen mode being set")
 +-> swapBuffers(damage, modeRegions, flags)  fn 0x5d4f68   -> classifies damage into update classes
 +-> update(region, class, mode, flash)       fn 0x5d31dc   -> queue for the SWTCON software waveform generator (fn 0x5d9044, 'vsync-flip', 'framegen' threads)
GhostBuster (xofm.libs.ghostbuster)  viewChange()/forceClearNow()/retailRefresh()  -> EPFramebuffer ghost-control (vtable +0x58)
ScreenDriver (devicesceneview)        per-document state machine that switches the whole scene view between Normal / Animation / Mono modes and schedules a clear
```

The rM2 has no vendor EPD service: xochitl drives the panel itself (SWTCON, `/dev/fb0`, `.wbf` waveform file chosen by TFT_VID/FPL_LOT, temperature from `sy7636a_temperature`). Waveform mode names available in the wbf: INIT, DU, GC16, GL16, GC16_REGAL, GL16_REGAL, A2, DU4, mode8..mode11 (name table at 0x107ab90, strings 0x111e8a4..0x111e8f0).

## 2. ScreenModeItem modes (QML users)

| Mode | Used by | Meaning |
|---|---|---|
| UI (default, `!globalMode`) | everything not listed; `00d8b006:612-629` ("global") | normal, quality update |
| Content | scene view (`00da1f6c:802`), pen colour swatches on colour panels (`00eaba89:109`), setup/retail pages | grayscale/colour content, rendered at quality |
| Animation | page slider thumbnail area (`00d85fe4:271`), document drawer (`00cbcb2c:27`), scroll container (`00d84aab:302`), virtual keyboard (`00e484bb:59`), undo/redo/format bar (`00da8aeb:194`), text cursor/password cursor blink (`01066c38`, `010673c5`), accidental-touch slider (`01067a0b`), whole scene view while gesturing (below) | fast, low-fidelity updates; no flashing |
| Mono | pen swatches on mono panel (`00eaba89:374`, objectName `pen-mono-dither`), `globalMode == Mono` while a key is held in text mode (ScreenDriver fn 0x149fa4) | black/white only update |
| Pen | boot progress bar (`00cb404c:45`) | low-latency update |
| Sleep | sleep screen (`010498b2:92`) | full quality, then panel idles |

QML binding of the scene view (`00da1f6c:790-807`): `visible: !screenDriver.globalMode` for the Content item; `onGlobalModeChanged` records `isAnimationMode` and emits `exitedAnimationMode` when returning to normal.

## 3. swapBuffers: update classes (fn 0x5d4f68) [V]

Arguments: `(fb, damage, modeRegions, flags)`; `flags & 1` = full update, `flags & 2` = pen uses forced mode. The update call is `update(region, cls, mode, flash)` (fn 0x5d31dc: rectangles are 8-px aligned in x, mirrored to the 1404x1872 panel, queued with a monotonically rising id, `cls` stored as short, `flash` = bit 0 of last arg). Observed tuples:

| Debug label in binary | Region | cls | mode id | flash | Role |
|---|---|---|---|---|---|
| " - full update" | (damage U modeRegions[1] U [2]) intersect request, then the remainder | 2 / 2 | 7 / 12 | 1 / 1 | whole-screen flashing refresh (ghost clear); then `FUN_005d026c` flushes the queue |
| " - pen update" | damage inside modeRegions[0] (Pen) | 1 | **8 if flags&2; else 7 if any rect holds a pixel that is neither 0xff000000 nor 0xffffffff (fn 0x5c8514 scans the rect, ARGB32); else 0** | 2 (arg) | live stroke: fast mode; colour/grey strokes get mode 7, pure black/white mode 0 [I: lowest-latency] |
| " - animation (DU)" | Animation region when the previously animated region (`fb+0x28`) is not fully inside the new one (animation area shrank/moved) | 1 | 7 | 0 | fast; waits (usleep 100 loop) until the queue has drained |
| " - animation" | modeRegions[2] (Animation) otherwise | 6 | 7 | 0 | A2-class fast update |
| " - mono only" | modeRegions[1] (Mono) when nothing else is left to update | 1 | 7 | 0 | |
| " - mono" | modeRegions[1] (Mono) (rects are tested with fn 0x5c8514: grey-free rects are collected) | 3 | 7 | 0 | partial B/W update |
| " - grays" | all remaining damage when mono set empty | 3 | 12 | 0 | grayscale partial update |
| " - normal" | rest of the damage | 3 | 6 | 0 | default quality partial update (GL16-like) |
| " - post-animation" | region that was in animation since last frame (`fb+0x28`) | 2 | 6 | **1** | **flashing quality update after an animation ends** |
| " - rest" | leftover | 3 | 6 | 0 | |

The mode regions are, in the order of fn 0x5d4c0c: [0] Pen, [1] Mono, [2] Animation (the remaining modes UI/Content/Sleep have no region of their own: they are "the rest"). The exact set algebra of the region sets in this function was only partly traced [I]. The mode ids 6/7/8/12 are SWTCON-internal; they are not the index of the wbf name table (12 would be out of range of its 12 names), so the mapping to GC16/GL16/DU/A2 is [I] by role, not proven.

## 4. When does xochitl clear ghosting? (the "ghost counter" does not exist: there is no stroke or page counter)

1. **GhostBuster.viewChange(mode)** (fn 0x2f8cb4): for every ViewChangeMode the C++ ignores the value (only logged) and calls EPFramebuffer ghost-control with arg 1 = *schedule a full clear on the next frame* (sets byte `fb+0x6c`, consumed by the next swap as `flags&1`). Triggers present in QML:
   `SettingsOpened`/`SettingsClosed` (`00d96a54:50`, `00e3254c:26`), `ShareByEmailOpened/Closed` (`00df8e06:18,34`), `SetupStarted/Completed` (`00ec3596:31`, `00ec38d7:56`), `SplashScreenClosed` (`00f78d17:61`), `PincodeClosed`, `Rotation` (enum only), `DocumentViewDialogOpened/Closed` = Pages overview shown/hidden (`00da96df:2352,2379`), template selector open/close (`00da96df:2049-2083`), any dialog via `handleDialogGhosting` (`00da96df:408`).
2. **forceClearNow(reason)** (fn 0x2f8b7c): arg 0 = clear **now**: full-screen region, blocks until the update queue drains (`FUN_005d4984` -> `FUN_005cf7a4(fb, whole image rect)`). Triggered by the 5-finger tap ("5-finger gesture", `00da6487:203`, flag-gated `Experimental.gestures.enabled`), and in setup by page "Did you see that?" after **500 ms** and by its "Refresh again" button (`00ec3c3b:16-45`).
3. **retailRefresh** (fn 0x2f8a2c): schedule (arg 1); retail carousel changes (`00eb22b2:29,83`).
4. **ScreenDriver** (xofm.modules.devicesceneview.screendriver), per scene view:
   - *want-A2* = gestureMode (pan/zoom/drag in progress) OR selectionMode (item selection, text selection, cursor drag) OR snapMode (draw-and-hold shape/line preview) OR quickBrowse (page slider) OR hold timer active OR when-ready timer active (fn 0x14f8e0, log " - want-a2=%d->%d, gesture=%d, selection=%d, snap=%d, quick-browse=%d, holding=%d, awaiting-ready=%d, hold-after=%d, clear-after=%d"). While true: global screen mode = **Animation** (value 2), timers stopped.
   - When it ends: a **hold timer** (restarted while the pen is close: " - pen close, delaying hold phase...") then " - hold phase complete": if tiles are still pending -> **when-ready phase** (timer, extended while pen close, ended early when tiles ready) -> `fn 0x14f798` " - returning to normal **with clearing**" if `clear-after` (set when any of gesture/selection/snap was active) else " - without clearing". "With clearing" calls `fn 0x14f6d0` = " - clear on next frame..." (ghost-control arg 1) and stamps the time. Interval values of the two QTimers are set in the ScreenDriver constructor and were **not recovered** (callers use `QTimer::start()` without argument).
   - *Key interaction* in text mode (keys 0x53 / 6): enters **Mono** mode and starts the hold timer; keys 2,3,5,0xc2-0xc4 just delay hold/when-ready timers (fn 0x149fa4).
   - **finalizeNewPage()** (called when a page finished loading: `00da1f6c:1423,1490`; fn 0x14ff70): if it is the initial page of the view and no tiles are pending -> clear (the first page after opening a document flashes once). Otherwise, if **>= 30 s** (30,000,000,000 ns, compare vs `system_clock` stamp at +0x30) passed since the previous clear -> " - stayed long on page, clearing!". So a page turn only flashes after 30 s on the previous page.
5. Opening/closing the document drawer, quick settings, etc.: Animation regions (no clear) plus GhostBuster events only where listed above.

## 5. Stroke refresh (pen up) [V]

`DeviceSceneViewBehavior.queryAddStrokeMode(stroke)` (fn 0x14e6e0) returns `{addToTiles, markViewportDirty, delayedRefresh}`. `delayedRefresh` is true when the stroke colour is **not** pure black or white (table 0x0ccc010: colour ids -> ARGB; 0xff000000/0xffffffff excluded) or a special flag of the tool. QML (`00da1f6c:723-738`): delayed strokes call `viewportUpdateTimer.markDirtyAndRestart(rect)` (interval **1000 ms**; fires only if the pen has been up for >= 100 ms, else restarts; on fire `inputSurface.clearFramebuffer()` + `viewport.requestRepaintDirty()` = re-render the dirty tiles at quality). In Animation global mode the area is simply marked dirty (no flash). Other strokes are marked dirty at once (fast pen-update class). The eraser does not use this path; it re-renders tiles after the cut (spec_eraser.md section 5).

## 6. Mapping to Onyx `EpdController` / `UpdateMode` (names from the Onyx SDK; verify against the SDK version in use)

| xochitl situation | Onyx equivalent |
|---|---|
| live pen stroke (class 1, pure B/W) | raw drawing / `UpdateMode.DU` (app: `PenSurface` DU) |
| coloured / grey stroke after pen-up (delayedRefresh, 1 s idle) | `refreshScreenRegion(view, rect, UpdateMode.GU)` (or REGAL on colour panels) once, 1000 ms after the last stroke |
| Animation mode (pan, zoom, selection drag, shape preview, page slider, keyboard, drawer, cursor blink) | `UpdateMode.ANIMATION` / `A2`-style (app uses DU in `beginFastPreview`) |
| Mono mode | `UpdateMode.DU` |
| normal content / UI partial update | `UpdateMode.GU` (default view mode) |
| post-animation / ghost clear / `forceClearNow` / initial page / 30 s rule / ViewChange | full-screen `refreshScreen(view, UpdateMode.GC)` (flash); `forceClearNow` waits for completion, others are "on next frame" |

## 7. What InkBridge does today and the gaps

| Firmware | InkBridge (`PenSurface.kt`, `NotebookScreen.kt`) | Gap |
|---|---|---|
| Clear (flash) after every pan/zoom/selection/snap gesture once the hold phase ends | `beginFastPreview` DU, `endFastPreview` `resetViewUpdateMode`; no clear | add a GC refresh after the gesture + hold timer (suggest ~700 ms, firmware interval unknown) |
| Clear on first page of a document and after >30 s on the previous page | clear only when `refreshEveryStrokes > 0` on page change (setting meant for strokes) | implement the 30 s rule and first-page clear |
| Clear on dialog/overview/settings/template picker open or close | none | call `fullRefresh()` when overview/settings/template selector open or close |
| 5-finger tap = immediate blocking full clear | `FingerGestures` tap(5) -> `fullRefresh()` | ok (firmware flag-gated) |
| Colour/grey stroke: re-render at quality after 1 s idle | none (stroke stays in pen/DU render) | add idle timer 1000 ms (>=100 ms after pen up) + GU/REGAL region refresh |
| Pure B/W vs coloured regions use different classes | single DU | choose DU for black/white pens, GU/REGAL region refresh after pen-up for colours and highlighter |
| Stroke-count flash | user setting 0/10/25/50 strokes | not in firmware: optional extra |
