# reMarkable 2 icon set (firmware 3.27.1.0)

Extracted from `/usr/bin/xochitl` in `remarkable-production-image-3.27.1.0-rm2-public.swu`
(SHA-256 `40f4b69ff4b546a9177b44e0f1b00e0e7bdc1b9694398b00b4fbca6301181ac2`, from the official
`remarkable-software` S3 bucket listed in codexctl's `version-ids.json`).

`icons/` holds the 259 SVGs embedded in the binary's Qt resources, under their real resource names
(`ballpoint.svg`, `undo.svg`, `toolbar_hide.svg`, ...). They are 48x48, single-colour, plain `<path>` fills.
They are reMarkable's assets, kept here for personal use only.

The subset the app uses is converted to `app/src/main/res/drawable/rm_*.xml` by
`tools/svg_to_vector.py`; run it again to regenerate.

## What else was extracted from xochitl

- `fonts/remarkable/`: the UI fonts, stored raw in the binary: reMarkable Sans (Light, Regular, Medium, Bold, ExtraBold, with italics)
  and reMarkable Serif Small (Regular, Bold, with italics). `fonts/icon-fonts/` holds the icon/symbol fonts (icomoon, reMarkableSymbols,
  Material Icons, Noto Emoji), `fonts/rootfs-*` the system fonts from `/usr/share/fonts` in the root filesystem.
- `ui/tokens/`: the Ark design tokens (zstd-compressed QML in xochitl): `iconButtonLarge.qml`, `toolbar.qml`, `rM-paper-tablet.json.qml`
  (typography, controlsHeight, iconSize), and so on. `ui/qml/Values.qml` holds the layout constants (sidebar width, create menu, foldout
  widths). `ui/qml/WritingToolMenu.qml` is the pen menu.

Key numbers (reMarkable pixels, 1404 x 1872 screen): toolbar button 112 with a 48 glyph; foldout width 480 (pen) / 376 (eraser),
2 px black border and dividers, 32 padding, 112-high rows; buttons 80 high; labels 25 Medium, body 28, caption 22, page title 48
reMarkable Serif Small. The app sets `1 dp = 1 reMarkable px` (`RmDensity` in `Theme.kt`) so these values are used as they are.

`tools/firmware/` has the scripts used: `newc.py` (unpack the .swu cpio), `carve.py` (carve SVG/PNG), `rcc3.py`/`rcc4.py` (match Qt
resource names to data), `flat.py` (flatten token QML).
