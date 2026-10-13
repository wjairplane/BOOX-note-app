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
| Android viewer (import folder, browse, open pages) | builds; **not yet run on a device** |
| PDF/EPUB overlay, pen input, saving, export, OCR, sync | not started |

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
