# USB web interface (http://10.11.99.1)

Static SPA from `/usr/share/remarkable/webui/`: `index.html` (mounts `#root`, loads `/assets/index.js` + `/assets/index.css`), `reMarkableSans.woff2`,
`reMarkableSerif.woff2`, `favicon-32x32.png`, `rm_logo.svg`. The bundle is a minified React build (Tailwind-style utility classes, `responsive-body-sm/md` type variants, `neutral-light-4/5` greys; Sanity CDN image helper).
The CSS also references reMarkableSans/Serif variable fonts (weights 300-800) from cdn.sanity.io; the offline static fallbacks are the two woff2 files.

## HTTP API used by the page (all on the device, same-origin, 30 s timeout)
- `GET /documents/` and `GET /documents/<folder-id>` -> JSON array of entries with fields `ID`, `Parent`, `VissibleName` (sic, typo is the real key),
  `Type` (`DocumentType` / `CollectionType`), `fileType` (`pdf`, `epub`, `notebook`; shown capitalised in the table), modified date ("N years/months/... ago" text).
- `POST /upload` multipart form field `file`; success = HTTP 201. Import button accepts multiple files (`<input type=file multiple>`).
- `GET /download/<id>/<format>` (default `pdf`); filename from `Content-Disposition`. Export button downloads selected documents.
- `GET /log.txt` ("Download logs" footer link).
- Errors: "Get documents failed (n)", "Upload failed (n)", "File download failed (n)"; timeout/abort = NoConnectionError screen.

## UI strings
Title bar `reMarkable`; breadcrumb root "My files"; buttons "Import", "Export", "Refresh", "Sync with Connect"; empty states "The library folder is empty." and
"Import files to view them here."; error "Not able to connect to the device, check the usb connection", "Something went wrong", "Something went wrong!", "Not Found";
footer links "Privacy policy" (support.remarkable.com), "Support", "Download logs", "remarkable.com". Table columns: file icon (epub / pdf glyph), name, type,
relative modified time; folders as a folder icon + name; multi-select for export.
