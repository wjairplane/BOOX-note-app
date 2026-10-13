# InkBridge

A handwriting notes app for the **BOOX Note Air5 C** (colour e-ink, Wacom stylus) whose screens and pens are
modelled on the **reMarkable 2**.

**What it is:** a notebook app with a reMarkable-style *My files* screen, a *Settings* screen, and the reMarkable
pen set (ballpoint, fineliner, marker, pencil, mechanical pencil, paintbrush, calligraphy pen, highlighter,
eraser) with colours.

**What it is not:** a viewer for reMarkable files. You create notebooks in the app; there is no import of
reMarkable notebooks.

*InkBridge is an independent project, not made by, affiliated with or endorsed by reMarkable AS. It copies the
layout and behaviour of an interface, not artwork, fonts, icons or brush textures.*

## Status

Everything below builds and the library code is unit-tested, but **the app has never been run on a device**, so
the screens have never actually been seen rendered and the pen has never touched real hardware.

| Area | State |
|---|---|
| My files: grid/list, folders, favorites, trash, rename/move/delete, sort, page thumbnails | written, untested on device |
| Notebook: left toolbar, pen panel (live sample of each pen), page overview, swipe to turn pages, add/delete pages | written, untested on device |
| Pens: all nine, 3 sizes, colours | written; widths for fineliner/ballpoint/highlighter fitted to real data, the rest estimated |
| Page templates: blank, lined, grid, dotted | done (tested on the JVM) |
| Settings: general, pens, display (e-ink refresh), storage, about | written, untested on device |
| Annotate PDFs: import, draw over, export flattened PDF | written, untested on device |
| Export a page to SVG / PNG / PDF | SVG tested; PNG/PDF untested on device |
| Pen input through the Onyx SDK | written against the SDK's real API; feel and refresh need tuning on the device |
| EPUB, handwriting search (OCR), sync | not started |

## Layout

- `rmformat/` – pure-Kotlin library, unit-tested on the JVM: the page store (`.rm` v6 line format, internal),
  pens and renderer, editing (strokes, erase, undo), templates, library operations (notebooks, folders, trash), export.
- `app/` – the Android app (Jetpack Compose; plain black-on-white, no animations, for e-ink).

Pages are stored in the open reverse-engineered reMarkable v6 line format (a Kotlin port based on
[rmscene](https://github.com/ricklupton/rmscene) and [rmc](https://github.com/ricklupton/rmc), MIT, © Rick Lupton),
inside the app's private folder in the tablet's file layout. That is an internal detail: the app is not meant to
read reMarkable files, and documents it creates have not been checked against a real reMarkable.

## Build and test

```bash
./gradlew :rmformat:test          # parser/renderer/library tests; PNG renders land in rmformat/build/render-snapshots
./gradlew :app:assembleDebug      # app/build/outputs/apk/debug/app-debug.apk
./gradlew -PrmOnly :rmformat:test # skip the Android module (JVM-only, faster)
```

Needs JDK 17+ and the Android SDK (platform 35). A GitHub Actions workflow builds the APK on every push.

## Notes

- Colours are saved with the classic pen-colour ids, so they work wherever that format is understood.
- The Onyx pen SDK is only published on `repo.boox.com` over plain HTTP. `settings.gradle.kts` limits that
  repository to the SDK's own groups, but artifacts from it are not integrity-checked in transit; vendor the `.aar`
  files into the repo if that matters to you.
- Annotating a PDF scales each page to fit 1404x1872, centred horizontally and top-aligned (`PdfPlacement`); only
  matters if annotated PDFs are ever exchanged with a reMarkable.
