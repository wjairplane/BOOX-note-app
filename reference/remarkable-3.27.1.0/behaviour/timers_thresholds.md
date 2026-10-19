# Timers, thresholds, defaults (xochitl 3.27.1.0)

Sources: QML = `ui/qml_all/<offset>.qml:<line>`; BIN = `xochitl` ARM binary vaddr (Ghidra project copy; helper scripts in the scratchpad `b/` and `gs/`); [V] read directly, [I] inferred.
"App" = current InkBridge behaviour.

## 1. Power / standby / sleep screen

| Item | Value | Source | App |
|---|---|---|---|
| Standby ("display turns off") options | 5 min, 20 min, 1 hour (`5*60*1000`, `20*60*1000`, `60*60*1000` ms); MDM can filter out longer ones | QML `00d98d51:35-47` [V] | none (Android/BOOX decides) |
| IdleSuspendDelay default | **1,200,000 ms = 20 min** | BIN defaults switch fn 0x7b9dcc, case 9 -> 0x7b9ed8 `movw/movt 0x124f80` [V] | n/a |
| IdleToSuspendDelay default | **9,600,000 ms = 160 min** (display off -> deep sleep) | same switch, case 10 -> 0x7b9ee8 (`0x927c00`) [V] | n/a |
| SuspendPowerOffDelay default ("Power off") | **43,200,000 ms = 12 h**; UI text "Let your paper tablet power off when it's inactive for 12 hours"; toggle visible only when `Settings.powerOffDelaySet` | switch case 32 -> 0x7b9ef8 (`0x2932e00`); QML `00d98d51:113-135` [V] | n/a |
| LightSleepEnabled / AirplaneMode / AccessibleMode / EnablePowerLogging / Screenshot | default false | switch cases 0,1,5,25,40 -> 0x7b9e88 (`QVariant(false)`) [V] | - |
| RightHanded, ShapeSnapEnabled, RemoveLegacyLines | default **true** | cases 22,23,29 -> 0x7b9eb4 [V] | shapes default true (match); right-hand setting absent |
| HandwritingSearchLanguage / InputLocale / Keyboard | default `en_US` (Keyboard string at 0x112c218) | cases 11,38 [V] | - |
| SleepScreenPath default | `/usr/share/remarkable/suspended.png` (0x10e5750); a custom image is shown full-bleed (`isCustomSleepScreenPath`), otherwise a carousel illustration centred, width `carouselWidth` (portrait) / `carouselLandscapeWidth` | BIN case 31; QML `010498b2` [V] | none |
| Optional contact lines on sleep screen | `idleName`, `idleContact` Body text, centred at bottom margin `margin.horizontal.large` | QML `010498b2` [V] | none |
| "Press power button to continue" ActionBar | height 120, no buttons | QML `01049798` [V] | none |
| Max suspend delay a blocker may impose | 300,000 ms = 5 min ("Max suspend delay of {} reached") | BIN table 0x10692f0 (suspenddelayer.cpp) [I] | n/a |
| Retail demo: daily reboot (`rm.retaildemo.dailyReboot`) | n/a | BIN strings | n/a |

## 2. Auto-hide / dismiss timings (UI)

| Item | Value | Source | App |
|---|---|---|---|
| `Values.popupTimeout` (generic popup / page-slider / notification) | **4000 ms** | QML `00d82ba4:131` [V] | 4000 (files notifications, page label, page slider `GlobalOverlays.kt:265`): match |
| `pageFooterTimeout` | 8000 ms (defined, used by footers on ebooks) | `00d82ba4:132` | not used |
| `onboardingNextPageDelay` | 2000 ms | `00d82ba4:130` | n/a |
| Document-view notification bar (`notificationTimerInterval`) | **5000 ms**; clipboard hint ("Copied to clipboard. Tap any page with Marker to paste.") stays until dismissed ("Clear clipboard") | `00da96df:69,1148,2418`; `00da06f0` [V] | 5000 and sticky clipboard hint: match; "Clear clipboard" action missing |
| Page slider hides | `Values.popupTimeout` after release | `00d9fd92:101` | 4000: match |
| Scroll indicator timeout | 3000 ms (scroll-container fades) | `00d84aab:37`, `00d85bff:78` | n/a (no scroll bars) |
| Page-overview highlight | highlight set 100 ms after model change, cleared after 3000 ms | `00d9b294:194-208` | check overview |
| File-browser toasts | 3000 (archived doc without cloud), 4000 (connectivity header), 5000 (import "Open" / "Open in a new notebook") | `00d8b006:269,510,589,607` | single 4000 |
| Formatting menu (typed text) | 1500 ms hide interval after a key press | `00daebb5:39` | n/a (no text) |
| Handwriting-conversion bar | closes **8000 ms** after finishing; "Converting to text" bar stays 15000 ms (`barTimer`) with 500 ms fade (`animationTimer`) | `00daf19e:51`, `00dc02dd:141-148` | n/a |
| Key-popup auto-hide | 10000 ms | `00e48e6e:12,55` | n/a |
| Search indexing message | 5000 ms (`messageTimeoutMs`) | `0101f15d:32` | n/a |
| Sync message | 20000 ms / 3000 ms | `0101f818:133,140` | n/a |
| Loading spinner delay | spinner appears only if still loading after **500 ms**, hides immediately | `00da96df:1273`, `00d8df28:77` | none |
| "Last opened" updated | only after the document stayed open **5000 ms** ("69% of users open and close within 5 s") | `00da96df:592-599` [V] | `AppController.markOpened` on every close -> sort by Last opened is polluted by accidental opens |
| Standby panel wording | "Show your open document or overview when in standby" | `00e32954` | n/a |

## 3. Touch / gesture thresholds

| Item | Value | Source | App |
|---|---|---|---|
| `pixelsPerCm` | `DeviceScreenInfo.pixelsPerCm` (rM2 ~ 89 px at 226 dpi) | `00da6487:28` | `pixelsPerCm` passed in: ok |
| Short page swipe | 0.6 cm, needs release; long swipe 3.0 cm fires at once (1 finger, not in text mode) | `00da6487:420-421`, `longMode` | 0.6 / 3.0 match |
| Jump (vertical swipe) | `verticalJumpDistance = height * 0.8`, aligned to top/bottom of the page if closer | `00da1f6c:133,1650-1690` | **0.85** (`PageSession.kt:121`) and no alignment snap |
| Edge zone | 1 cm (`edgeSize = pixelsPerCm`) | `00da6487:29` | match |
| Quick-settings corner | `Values.quickSettingsGestureWidth` (350 px) | `00da6487` | 3.9 cm ~= 350: match |
| Document drawer (2 fingers from top) | travel 0.3 cm in the top 1 cm | `00da6487` `swipeDownForRecent` | match |
| Tap palm threshold | `20*20` = 400 px^2 contact area | `00da6487:35` | no area test (Android has no equivalent unless `MotionEvent.getSize`) |
| Pen-close lockout | 500 ms after the pen leaves (`PenClosenessMonitorImpl.interval`), 200 ms for undo/redo taps | `00dba9aa:8`, `00da6487:121` | 500 / 200 match |
| Multi-tap window (text mode) | 300 ms, tap distance < 0.6 cm; 1 tap on cursor = selection menu, 2 = word, 3 = paragraph, 4 = all text, >4 reset; double tap on page inside text bounds (+50 px margin) enters text mode | `00da6487:59-110,262-321` | none |
| Cursor drag | start after 0.2 cm; vertical threshold 0.8 cm; grab box 1 cm x max(1 cm, line height) | `00da6487:141-160` | none |
| Show text cursor delay | 250 ms | `00da1f6c:605` | none |
| Selection-menu open delay | 1000 ms (`openLaterTimer`) | `00dae11b:167` | n/a |
| Drag-and-zoom filter timeout | 2000 ms; pan/zoom min velocity 2.0 cm | `00da6487:397-401` | uses 0.5 cm travel / 8 % scale start |
| Ghost-buster tap | 5 fingers, enabled only when `Experimental.gestures.enabled` (flag default not recovered) | `00da6487:196-204` | always on |
| Undo/redo taps | 2 / 3 fingers, only `runningOnDevice` | `00da6487:177-190` | match |
| Long-press (pill) | Qt `pressAndHold` (500 ms default; QML sets none explicitly) on file items, template items (`00da0e96:104`), search results | `00d88833`, `00d92093:321` | long-press exists (check 500) |
| Keyboard long press | 300 ms (`longPressDelay`); key repeat starts 250 ms, accelerates to min 30 ms | `00e484bb:14,232-248` | n/a |
| Page-slider cancel | drag > 200 px above the slider cancels; snap to navigation points within `pageCount/40`; snapping only when > 50 pages | `00d85fe4:25-30,100-110` | see spec_pageslider.md |
| Slider height | 100 | `00d85fe4:36` | |
| Pen hold (draw-and-hold shape snap) | still **250 ms**, looked at no more often than every **100 ms**, moving at most **0.5** between looks; >= 10 points; chord >= 3 px | BIN `DrawAndHoldGesture` ctor `0x820d0c`, `evaluate` fn 0x150ed4 (shape_snap.md) [V] | `HoldGesture` (250 ms / 100 ms / 0.5 page units) |
| Select-below hold | vertical threshold 15 px, arrow offset 5 px | `00da01c3:23-30` | `ShapeSnap.isHorizontalLine` 3:1 ratio: guessed |
| Selection tap vs lasso | selection stroke whose bounding box max(w,h) < 30 scene px is a tap (selects an image at the point, else clears/lassos) | `00da1f6c:699-716` | `extent < 16f` view px (`PageSession.kt`) |
| Selection auto-scroll tick | 50 ms | `00da1f6c:959` | n/a |
| Shape overlay snap preview | 100 ms repeating `snapImageTimer` | `00da87d5:45` | |

## 4. Zoom / view

| Item | Firmware | Source | App |
|---|---|---|---|
| Zoom range | **0.5x .. 5x** of the default (fit) scale (`minimumScaleFactor`/`maximumScaleFactor`; for non-note pages scaled by view/content) | `00da1f6c:128-129`, comments "min zoom is 0.5x / max zoom is 5x" `:1791-1796` [V] | **1x .. 4x** (`PageTransform.MIN_ZOOM/MAX_ZOOM`); cannot zoom out below fit |
| Snap to 100 % | band +-5 % (`scaleSnapHigh = defaultScale*1.05`, `scaleSnapLow = *0.95`) while pinching and on `zoom()` steps; when locked the view re-centres on `snapCenter` horizontally; centre pan also snaps (only at 1:1) | `00da1f6c:130-131,1604-1645,1785-1830` | none |
| Zoom button | shown when zoom != default; label = zoom mapped to pen-thickness scale with 1 decimal ("1.5x"); tap = `singleStepZoom` back to default (zoomed in -> 0.5 factor, zoomed out -> 2); rejected while pen is close if source is touch | `00dafa31`; `00da96df:2568-2600` [V] | button exists, mapping to verify |
| Single step zoom | x2 per step (zoom in) or x0.5 (zoom out); zooming in from <100 % jumps to 100 % first | `00da1f6c:1595-1625` | |
| Pen scale | stroke thickness divided by `penScale` (PDF fit scale) so a pen looks 1x on a fitted PDF | `00da1f6c:74,675,681` | check for PDFs |
| Page flip animation | none (e-ink); page change goes through `finalizeNewPage` -> ghost rules in refresh_policy.md | | no animation: match |

## 5. Other limits

| Item | Value | Source |
|---|---|---|
| Eraser stroke point cap | > 30000 points: not applied ("eraser line is too large") | BIN 0xa55320 (spec_eraser.md) |
| Max points per page when loading a scene | 7,489,828 (0x724924), else "Too many points in total" -> page status TooLargeError, UI "Stroke limit reached - start a new page or erase something" | BIN fn 0xaa6990; QML `00dbf955` |
| Undo stack | engine `stack::undo` / `macro::undo`, no numeric cap found | BIN 0xa25ebc; App: `MAX_UNDO = 100` |
| Passcode lockout | attempt 6 -> 1 min, 7 -> 5 min, 8 -> 15 min, 9 -> 60 min (table 60000/300000/900000/3600000 ms), final-try warning, then locked ("A reset is required"); lengths 4/6/8 digits | BIN fn 0x5ad518 case 2 (index `attempts-6`), table 0x10796c0; QML `00eb7583:59`, `00eb6e53:44-52`, `01068a3c` [I for exact attempt numbers] |
| Cloud/WiFi | scan every 20 s; update timeout 120 s; pairing timeout 30 s; code validity 60 s | `00e5a1a4:74`, `00e2f527:130`, `00ebfbfc:173`, `01036593:52` (n/a) |
| Autosave / debounce | **not found**: no QML timer; saves happen in the C++ DocumentWorker. Search typing debounce 2500 ms (telemetry only) / 5 ms; `viewportUpdateTimer` 1000 ms (see refresh_policy.md) | `00d92093:191,208` |

## 6. Deviations worth fixing (ordered)

1. Zoom range 1..4 -> 0.5..5 with the 95-105 % snap band (`PageTransform.kt`, `PenSurface.kt` MAX_ZOOM).
2. Jump distance 0.85 -> 0.8 of view height and align-to-page-edge logic (`PageSession.jump`).
3. `lastOpened` only after 5 s (`AppController.markOpened`).
4. Pen-hold / shape thresholds are guesses; firmware thresholds listed in tool_behaviours.md.
5. Spinner 500 ms delay, notification timeouts per type.
