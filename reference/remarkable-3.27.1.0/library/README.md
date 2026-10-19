# Default library shipped on a new device (firmware 3.27.1.0)

Source: `/usr/share/remarkable/library/library.zip` (-> `default/`) and `/usr/share/remarkable/retail/library.zip`
(retail-demo set -> `retail/`; same document format). Extracted unmodified, in xochitl's on-disk layout
(`<uuid>.metadata`, `.content`, `.pagedata`, `.pdf`, `<uuid>/<page-uuid>.rm`).

## default/ (what a fresh device shows under "My files")
| Document | Type | Pages | Notes |
|---|---|---|---|
| Learn the basics (`8352580e-...`) | PDF + notebook layer | 9 | `fileType: pdf`, `formatVersion 2` (cPages CRDT page list), every page `template: Blank`. Page 1 is the PDF cover (no `.rm`); pages 2-9 each have a `.rm` v6 file with typed text + pen strokes (arrows, check boxes) laid over a 1620x2160 pt PDF (the PDF is the artwork; the on-page words are `RootTextBlock`). |
| Go further (`e49bb79e-...`) | PDF | 2 | old `formatVersion 1`, `pages` array, `.pagedata` = `Blank`,`Blank`. Page 1 cover with "Get started...Discover our online tutorials", page 2 card "Let's dive in" + QR code + remarkable.com/create. |
- Both: `tags: []`, `pageTags: []`, `parent: ""`, `type: DocumentType`, `lastOpenedPage: 0`, `pinned: false`, `new: false`.
  Metadata names: `visibleName` "Learn the basics" / "Go further".
- `extraMetadata` of "Learn the basics" is a full tool-state record: `LastPen: Ballpointv2`, `SecondaryPen: ShadingMarker`,
  `LastHighlighterv2Color: HighlighterGray`, `SecondaryHighlighterv2ColorCode: 4290702078` (ARGB), `LastEraserTool: EraseSection`, per-pen
  `Last<Pen>Color/Size` and `Secondary<Pen>Color/Size`. Useful reference for default tool state (sizes 1/2/3 = thin/medium/thick).
- `.rm` pages in Learn the basics: scene paper size **1620x2160** (Paper Pro geometry; the same library zip serves rM2 and Paper Pro), one layer
  named "Layer 1"/"Layer 2" (current layer unset), nested one-group-per-stroke trees, 1 glyph (highlight) item, a tombstone; pen ids seen:
  FINELINER_2, MECHANICAL_PENCIL_2, PENCIL_2, BALLPOINT_2, MARKER_2, PAINTBRUSH_2; colours BLACK, GRAY, CYAN, MAGENTA. rmscene (python) reads them but warns
  "newer format than supported" (extra trailing data); a few blocks have unread tails.
- 3 pro tips PDF (`fa097101`) lives only in `retail/` ("Read comfortably", 1404x4200 pt, one tall page: title "3 pro tips for organizing your paper tablet").

## retail/
Five demo docs: Connect the dots, Check off your to-dos, Getting started (4 pages), Highlight and annotate (1 page of a fake "Research and
development" annual report with MECHANICAL_PENCIL_2 highlights, ERASER and MARKER_2 strokes), Read comfortably (PDF). Pages 1404x1872,
tools: FINELINER_2, MARKER_2, BALLPOINT_2, PENCIL_2, MECHANICAL_PENCIL_2, SHADER (shading), HIGHLIGHTER_2, ERASER; colours BLACK, RED, GRAY, BLUE,
HIGHLIGHT. `.local` files (34 bytes) are xochitl local-sync markers.

## Files
- `manifest.json`: per document/page: id, paper size, pen and colour counts, glyph highlights.
- `guide_text.md`: all typed text recovered from the notebooks (the on-device guide wording).
- `pdf_pages/`: 60 dpi PNG renders of the three PDFs (`8352580e-1` = Learn the basics cover, `e49bb79e-1/2` = Go further, `fa097101-1` = 3 pro tips).
- Reading tip: `.rm` files are good v6 regression samples (real pens + text + glyph + tombstones) for `rmformat` tests.
