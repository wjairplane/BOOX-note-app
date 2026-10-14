# reMarkable 2 icon set (firmware 3.27.1.0)

Extracted from `/usr/bin/xochitl` in `remarkable-production-image-3.27.1.0-rm2-public.swu`
(SHA-256 `40f4b69ff4b546a9177b44e0f1b00e0e7bdc1b9694398b00b4fbca6301181ac2`, from the official
`remarkable-software` S3 bucket listed in codexctl's `version-ids.json`).

`icons/` holds the 259 SVGs embedded in the binary's Qt resources, under their real resource names
(`ballpoint.svg`, `undo.svg`, `toolbar_hide.svg`, ...). They are 48x48, single-colour, plain `<path>` fills.
They are reMarkable's assets, kept here for personal use only.

The subset the app uses is converted to `app/src/main/res/drawable/rm_*.xml` by
`tools/svg_to_vector.py`; run it again to regenerate.
