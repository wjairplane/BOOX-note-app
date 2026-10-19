# QML coverage audit: xochitl 3.27.1.0 vs InkBridge

Method: all 542 files in `ui/qml_all/` (named by offset, e.g. `00da1f6c.qml`) were scripted: root type, objectNames and every `qsTr()` string were extracted; each string was searched in `app/src/main` and `rmformat/src/main`. Per-file result: `qml_coverage.csv` (same folder). Caveats: "present" is a string-match heuristic (short strings like "Back" give false hits); 192 files have no UI strings (layout parts, list delegates, gesture glue) and cannot be judged by strings; earlier audits (`audit_*.md`, `audit2_*.md` in the scratchpad) cover the visual details of the screens that do exist.

## Counts

| Class (by root type) | Files |
|---|---|
| screen (BaseView, SetupBasePage, DialogScreen ...) | 117 |
| screen/page (settings pages, panels with 2+ strings) | 77 |
| component (list items, controls, delegates) | 179 |
| menu / toolbar tool / foldout | 45 |
| dialog (InputBlocker, Popup, InformationDialog) | 24 |
| settings row (Cell / Panel wrappers) | 18 |
| token / glue (QtObject, Shortcut, tiny Text) | 82 (53 are the QtObject ark-token files `0112xxxx`, `011a5f32` ...) |

String status: 112 present, 52 partial, 72 MISSING, 32 MISSING but device/cloud-only (Wi-Fi, pairing, retail, update, beta), 192 unknown (no strings), 82 token/glue.

## What InkBridge already has (for orientation)

Files browser (grid/list, folders, favorites, tags, trash, sort, search, new notebook/folder, rename, quick sheets, recent/favorites drawer), notebook editor (toolbar in 4 positions, pens, eraser + erase selection, lasso, layers, page overview, page slider, quick settings, zoom/fit modes, export SVG/PNG/PDF), template picker, settings (General, Display, Accessibility=toolbar position, Help/About/Storage), guides, finger gestures.

## MISSING screens/features, ranked by user-visible importance (Android-feasible first)

| # | Feature | Firmware files (qml_all) | Evidence | Android feasibility |
|---|---|---|---|---|
| 1 | Typed-text tool: "Typing" toolbar menu (Add text / Edit text / Automatic reflow), text settings dialog (Font, Font size, Line spacing, Page margins, Justification, Reset/Save), text styles (Title / Subheading / Body text / bold / italic ...), formatting menu, text-selection menu, cursor drag, multi-tap word/paragraph/all selection | `00ea90a7`, `00ea8fa8`, `00dae71c`, `00da16b3`, `00da194f`, `00dafe90`, `00d9c76c`, `00d9a387`, `00daebb5`, `00da8aeb`, `00dae11b`, `00da792b`, `00da6487` (touch logic) | app has no text editing (only `rm/text/TextDocument.kt` for reading imported text) | high (Compose text + own layout) |
| 2 | On-screen e-ink keyboard (key size 100, font 34, long-press alternates, key popup) | `00e484bb`, `00e48e6e`, `01067f7f`, `01066c38` | grep: no keyboard UI | medium (or use IME) |
| 3 | Handwriting conversion ("Convert to text", progress bar, "Converted text added as new page / to clipboard", Undo, language picker "Handwriting conversion language") | `00ea7ca9`, `00dc02dd`, `00daf19e`, `00d9f14b`, `00df4f1a`, `00dc1fbf` (selection menu `hwc` button), `00d9ca54` | firmware sends pages to a cloud recognizer (`RecognitionTask` over `http`, strings `rm.recognizer*`); needs network | only with an OCR service / ML Kit Digital Ink |
| 4 | Share / export to email, "Share by URL", export integrations (Dropbox, Drive, OneDrive), screen share | `00df7e9b`, `00df78eb`, `00df8e06`, `00ea6a93`, `00ea6de9`, `00ea8590`, `00db1818`, `00ea5685`, `01028b33`, `01028e0e`, `00ea6b75`, `00f79844` | app only exports SVG/PNG/PDF via Android share | email/URL: use Android intents; cloud parts n/a |
| 5 | **Done in 1.2.0: Go to page, tag filter and page tagging; still missing: the rest of this row.** Page overview extras: "Go to page" / "Tagged pages" row, multi-select actions (Duplicate, Move, Delete, More), move placement foldout ("Place before/after", "Move here", "Move out"), "Convert to notebook" for PDFs | `00db2957`, `00db7b16`, `00db706f`, `00db7910`, `00db40c6`, `00d9b294`, `00d9ca54` | grep "Go to page", "Move out" = 0 | high |
| 6 | **Done in 1.2.0: table of contents (PDF outline) and internal PDF links with the "Back to page N" notification; still missing: the rest of this row.** PDF/ebook reading: table of contents, reading progress ("0% read"), PDF links (page links, checkbox toggle), password-protected PDF prompt, "Increase contrast" background filter, ebook text settings, "Original document / With edits" duplicate | `00d9aa25`, `00d9025f`, `00cc1548`, `00d8d745`, `00ea5340`, `00db0ef0`, `00da6487` (linkAt/linkHandler) | grep "Table of contents" = 0, "Increase contrast" = 0 | high |
| 7 | Sleep / standby: Battery settings page (Standby 5 min / 20 min / 1 hour; Power off after 12 h), "Visible content in standby" panel, sleep screen ("reMarkable is sleeping", suspended.png), "Press power button to continue", Restart / Turn off dialog | `00d98d51`, `00e32954`, `010498b2`, `01049798`, `00cc2852` | Android/BOOX owns power; app has only Exit button | low (could mirror as screen-timeout hint) |
| 8 | Passcode lock (4/6/8 digits, change/remove, lockout 1/5/15/60 min after attempts 6-9, reset after 10; unlock screen) | `00eb7947`, `01068a3c`, `01069123`, `00eb6e53`, `00eb7583`, `00eb73dd`, `01068715`, `0105586b` | grep: none | high (app-level lock) |
| 9 | Remaining Settings pages: Display (ghost-buster section), Language & keyboard (system language, handwriting conversion language, keyboard layout), Security, System time, Accessibility (text size Standard/Large, writing hand Left/Right), Software, Battery, Storage detail (web interface), Personal information/contact on sleep screen | `00d99369`, `00d9509c`, `00d9569b`, `0102590c`, `00d94a01`, `00e2e7cc`, `00d98d51`, `00d978e3`, `00eb6b5b`, `00e3199e` | app has General/Display/Accessibility(toolbar only)/Help | medium |
| 10 | Right/left-hand preference ("Choose your writing hand", setting key `RightHanded` default true) - mirrors toolbar/slider | `00e321fc`, `00d97445` | not in Prefs | easy |
| 11 | Onboarding: setup wizard, "Did you see that?" screen-blink page, release-notes/"Get started", "Ways of working", accidental-touch "Swipe to continue" slider, gesture tutorials | `00ec3596`, `00ec33c3`, `00ec3c3b`, `00f78d17`, `00df480a`, `01067a0b`, `0102b18d`, `0102cde3`, `00ec31d7` | app has a Guides screen only | medium |
| 12 | File browser extras: "Archive to cloud", Not-syncing badges, "Show all / Show less", filter dropdown ("Filters"), `Long-press for actions` hint, grid zoom factor (`GridViewZoomFactor`), tag pills row, "View all" tag list | `00db0b2f`, `00dc183a`, `00d89132`, `00db6543`, `00d9351f`, `00db9910` | partial | medium |
| 13 | Meeting notes / calendar integration | `0103a39b`, `0103a706`, `0103a90f`, `0103ad3e`, `01039e78`, `0103b0b0` | cloud + calendar, n/a | n/a |
| 14 | Document error pages: "Stroke limit reached", "Unable to view page. Low on memory", "Document is being synced", "Update software to view", "Disk corrupted" | `00dbf955`, `00dbe7d5`, `00d8ccea`, `00cc1b64` | app has none; firmware stroke cap is 7,489,828 points/page (0x724924, scene reader fn 0xaa6990) | easy |
| 15 | Device-only (no Android counterpart needed): Wi-Fi pages (`00e588ed`, `00e5918c`, `00e5a1a4`, `00e59533`...), cloud/account/pairing (`00d97fd4`, `00d98841`, `00ebfbfc`, `00ec06fc`, `00ec0d07`, `01035d9c`, `01036593`...), software update (`00e2f527`, `00e2e7cc`, `00e2fd4c`...), retail demo (`00eb2cd8`, `00eb22b2`, `00eb26ce`, `00eb3591`...), beta program (`00eb8899`, `00eb95f9`, `00eb9086`), factory reset / disk encryption (`010525d4`, `01054994`, `01055e9b`, `01056b77`), Type Folio (`01065461`, `01065d7b`, `01066263`), USB web interface (`00cb4a1b`, `00cb44b0`) | | n/a |

## Present but incomplete (partial)

- Notebook toolbar: missing `orientationButton` ("Set to landscape/portrait", `00ea6ca2`), `Increase contrast` (`00ea5340`), `More tools` foldout (`00eac8f4`), `Adjust view` has fit modes but no `ZoomButton` 0.5x..5x mapping (`00dafa31`), "Custom view" set popup (`00da0a73`: "Zoom and pan to adjust the page" / Set).
- Notifications: `NotificationBar` (`00da817a`, `0101f5fc`) has clipboard action "Clear clipboard" (`00da06f0`) not implemented.
- Pen foldout: "Snap to text" toggle for the highlighter (`00eaba89:386-410`) missing (see tool_behaviours.md).
- Search: file search exists; in-document handwriting search (`00db017b`, `01022944` "Handwriting search / Reset index", `0101f15d` indexing progress) missing; needs the same cloud recognizer.
- Tags screen/sort present; "Delete %n tag(s)?" (`01044757`) partially.

## Settings keys in the binary (QSettings, `x_strings.txt` 4733-4760; enum order verified through the defaults switch at 0x7b9dcc)

AccessibleMode, AirplaneMode, AscendingSort, AutoUpdate, BetaEnrolled, EnablePowerLogging, GridViewZoomFactor, HandwritingSearchLanguage, HomeSortOrder, IdleSuspendDelay, IdleToSuspendDelay, Keyboard, LastWritingTool, ListMode, OnboardingBanner, OnboardingProgress, OnboardingUpdateScreen, OutdatedSoftwareDisabledVersion, Password, PreviousVersion, RecentTemplates, RemoveLegacyLines, RightHanded, Rotation, Screenshot, SeabirdSetupCompleted, ServerAddress, ServiceEnvironment, ShapeSnapEnabled, ShowInactiveWarning, SleepScreenPath, SuspendPowerOffDelay, ThirdPartySortOrder, UpdateChannel, Username, WebInterfaceEnabled, InputFlavor, InputLocale, LastOpen, LightSleepEnabled, PaperSize, ToolbarPortraitPosition, ToolbarLandscapePosition. InkBridge persists: grid size, sort, reversed, template, pen slots, toolbar positions, shapes, refresh interval, swipe, finger, edge-gesture block. Not persisted but in firmware: RightHanded, LastWritingTool (app has slots), RecentTemplates (app has), HandwritingSearchLanguage, GridViewZoomFactor, ListMode, AccessibleMode (large text: Values.accessibilityMode doubles thumbnail row to 212, pill count to 100).
