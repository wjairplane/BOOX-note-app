# InkBridge

A handwriting notes app for the **BOOX Note Air5 C** (colour e-ink, Wacom stylus) that looks and behaves like the
**reMarkable 2** (firmware 3.27.1.0): the screens, menus, icons, fonts, templates, gestures and pens are taken from
that firmware.

**What it is:** notebooks and PDF annotation with a *My files* browser, the reMarkable toolbar (two quick-switch
pens, eraser, selection tool, undo/redo, layers, page overview, notebook menu), page templates, settings and guides.

**What it is not:** a sync client or a viewer for other people's reMarkable files. You create notebooks in the app.

*InkBridge is an independent project, not made by, affiliated with or endorsed by reMarkable AS. The icons, fonts,
illustrations and templates in `reference/` were extracted from the public firmware image for personal use.*

## What is in it

| Area | Notes |
|---|---|
| My files | grid / list, folders, favorites, tags, trash, move mode, sort, search, full-screen New notebook / New folder / Rename, quick sheets, notifications |
| Notebook editor | toolbar in any of the four positions (drag the hide button to an edge), pen foldouts, eraser (and *Erase selection*), selection tool (lasso, move, resize, rotate, cut, copy, paste), layers, page overview, zoom, PDF background, export to SVG / PNG / PDF |
| Pens | ported from the firmware's own renderer (`PixelInk`, checked pixel by pixel against the real code run under emulation) and recorder (`FirmwareRecorder`); ballpoint, fineliner, marker, pencil, mechanical pencil, paintbrush, calligraphy pen, highlighter, shader |
| Templates | the firmware's 65 template files (lines, grids, dots, margins, planners, music sheets, storyboards...) drawn by a small engine that evaluates the template DSL; picker with categories and orientation |
| Gestures | the firmware's finger gestures: flip page (short and long swipe), jump, pinch and pan, two-finger tap = undo, three-finger tap = redo, five-finger tap = clear ghosting, swipe down from the top = close document, two fingers from the top = document drawer, top-right corner = quick settings, swipe up from the bottom = quick browse; hold at the end of a stroke to snap a shape, hold a horizontal line to select everything below it |
| Device gestures | BOOX's own edge gestures can be blocked while the app is open (Settings), and the screen edges are reserved for the app's gestures |
| Performance | pen rendering is culled and parallel, the page base layer and PDF render are cached, release builds are minified |

## Layout

- `rmformat/` – pure-Kotlin library, unit-tested on the JVM: the page store (`.rm` v6 line format), the pen renderer, editing
  (strokes, erase, selection, layers, undo), templates, library operations, export.
- `app/` – the Android app (Jetpack Compose; black on white, no animations, for e-ink).
- `reference/remarkable-3.27.1.0/` – assets and QML recovered from the firmware (see its README); `tools/firmware/` – the scripts
  used to carve and port them.

Pages are stored in the reverse-engineered reMarkable v6 line format (a Kotlin port based on
[rmscene](https://github.com/ricklupton/rmscene) and [rmc](https://github.com/ricklupton/rmc), MIT, © Rick Lupton) inside the
app's private folder, in the tablet's file layout.

## Build and test

```bash
./gradlew :rmformat:test          # parser / renderer / pens / templates; PNGs land in rmformat/build/render-snapshots
./gradlew :app:testDebugUnitTest  # renders the real screens to PNG on the JVM (Robolectric): app/build/ui-snapshots
./gradlew :app:assembleRelease    # app/build/outputs/apk/release/app-release.apk (minified, debug-signed so it can be sideloaded)
./gradlew :app:assembleDebug      # the debug APK (much slower UI: use the release build on the tablet)
```

Needs JDK 17+ and the Android SDK (platform 35). GitHub Actions builds both APKs on every push.

## Notes

- The Onyx pen SDK is only published on `repo.boox.com` over plain HTTP. `settings.gradle.kts` limits that repository to the SDK's
  own groups, but artifacts from it are not integrity-checked in transit; vendor the `.aar` files into the repo if that matters.
- The screenshots made by the tests are Robolectric renders, not photos of a device; pen feel, refresh behaviour and gesture
  thresholds can only be tuned on the tablet.
