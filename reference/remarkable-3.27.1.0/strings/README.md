# reMarkable 3.27.1.0 UI strings

Regenerate: `python3 -I tools/firmware/qm_dump.py [ROOTFS] [OUTDIR] [QMLDIR]` (defaults point at the scratchpad rootfs and this dir).

Files
- `en.json`, `de.json`, `es.json`, `fr.json`: `{context: {source[ " || " comment]: text}}`. Plural messages (source contains `%n`) have a list of forms (de/es/fr: 2; en: one entry per plural form, all equal to the source). Key suffix ` || x` is the translator disambiguation comment (e.g. `Ebooks || filter`).
- `en.json` is the UNION of source texts of all four .qm files, because `reMarkable_en.qm` itself omits ~840 messages (English is the source language; its translations are null strings). It has 1763 messages in 322 contexts.
- `qml_strings.json`: every qsTr/qsTranslate/QT_TR_NOOP call site in the carved QML (`file`, `line`, `kind`, `context`, `text`). Carved files have hash names so the original qsTr context (file name) is unknown; `qm_contexts` lists candidate contexts found by looking the text up in the .qm tables, `in_qm` is false for the few strings built from concatenated literals. No qsTrId usage exists.

.qm format (Qt lrelease): 16-byte magic; sections `tag(1) len(4 BE)`: 0x42 hash table (hash,offset pairs), 0x69 messages, 0x2f contexts (absent), 0x88 numerus rules, 0xa7 language. Message records: tag 3 translation (UTF-16BE, repeated per plural form, length 0xFFFFFFFF = null), 6 source (UTF-8), 7 context, 8 comment, 1 end. The hash/offset section is redundant for a full dump and is not used.
