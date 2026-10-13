# InkBridge

Android notes app for the BOOX Note Air5 C that reads (and later writes) handwritten notebooks in the
reMarkable 2 `.rm` v6 format, so the same notebooks work on both devices.

*Not affiliated with or endorsed by reMarkable AS. The file format was studied for interoperability only.*

## Status

| Step | State |
|---|---|
| `.rm` v6 parser (Kotlin) | done, checked against the reference Python parser on 13 sample pages |
| `.rm` v6 writer | done, re-serialises sample pages byte-identically; not yet tested on a real reMarkable |
| Page renderer | done (strokes, pens, colours, layers, typed text); needs calibration against real 3.28 files |
| Library (folder tree from `.metadata`, pages from `.content`) | done, tested on a synthetic folder |
| Page editing: add strokes, erase, undo/redo, save to `.rm` | done and tested on the JVM (edits are appended blocks / tombstones; old bytes stay untouched) |
| Android app (import folder, browse, open pages, draw, erase, save) | builds; **not yet run on a device**; pen feel untested |
| Pen input via the Onyx SDK (`TouchHelper`) | written against the SDK's real API; needs on-device tuning |
| Export a page to SVG, PNG and PDF | done (SVG tested on the JVM; PNG/PDF untested on a device) |
| PDF/EPUB overlay, OCR, sync | not started |

## Layout

- `rmformat/` – pure-Kotlin library (no Android dependency): parser, writer, renderer, library scanner. Unit-tested on the JVM.
- `app/` – the Android app (Jetpack Compose, e-ink friendly black-on-white UI).

## Build and test

```bash
./gradlew :rmformat:test          # parser/renderer tests; PNG renders land in rmformat/build/render-snapshots
./gradlew :app:assembleDebug      # app/build/outputs/apk/debug/app-debug.apk
./gradlew -PrmOnly :rmformat:test # skip the Android module (JVM-only, faster)
```

Needs JDK 17+ and the Android SDK (platform 35). The GitHub Actions workflow builds the APK on every push;
download it from the run's artifacts and sideload it.

## Writing

Pick a pen (fineliner, ballpoint, pencil, highlighter) or the eraser and draw. Strokes are written into the
page's `.rm` file in the app's own copy of the notebook; the first time a page is overwritten its previous
version is kept as `<page>.rm.orig`. Pages save when you leave them or tap Save. Nothing is ever written back
to the reMarkable or to the folder you imported from.

Colours are saved with the classic pen-colour ids, so they open on every firmware (a reMarkable 2 shows them
as grey shades). Pen widths and speed values are fitted to real sample pages, not copied from reMarkable code.

The Onyx pen SDK is only published on `repo.boox.com` over plain HTTP. `settings.gradle.kts` limits that
repository to the SDK's own groups, but artifacts from it are not integrity-checked in transit; if that matters
to you, vendor the SDK's `.aar` files into the repo instead.

## Using it

1. Copy a notebook off the reMarkable (SSH/SCP into `/home/root/.local/share/remarkable/xochitl/`): the
   `<uuid>.metadata`, `<uuid>.content` files and the `<uuid>/` folder of `.rm` pages.
2. Put them in a folder on the BOOX, open the app and tap **Import folder**. The app copies them into its
   own storage and never writes to the original.

Always test on **copies**; never write into the tablet's `xochitl` folder directly.

## Credits

The v6 format handling is a Kotlin port based on the open-source [rmscene](https://github.com/ricklupton/rmscene)
and [rmc](https://github.com/ricklupton/rmc) (MIT, © Rick Lupton). Sample pages in
`rmformat/src/test/resources/rmscene/` come from rmscene's test data; its licence is included alongside.
