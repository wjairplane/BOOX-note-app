package app.inkbridge.rm.text

import app.inkbridge.rm.scene.*

/** Run of characters sharing formatting. */
class CrdtStr(val s: StringBuilder = StringBuilder(), val ids: MutableList<CrdtId> = mutableListOf(), val bold: Boolean, val italic: Boolean) {
    override fun toString() = s.toString()
}

class Paragraph(val spans: List<CrdtStr>, val startId: CrdtId, val style: ParagraphStyle) {
    override fun toString() = spans.joinToString("")
}

/** Typed text decoded into paragraphs. Port of rmscene's `TextDocument.from_scene_item`. */
class TextDocument(val paragraphs: List<Paragraph>) {
    companion object {
        /** Split multi-character items into one item per character with implicit sequential ids. */
        internal fun expand(item: CrdtSequenceItem<TextValue>): List<CrdtSequenceItem<TextValue>> {
            val v = item.value
            val chars: List<String> = when {
                item.deletedLength > 0 -> List(item.deletedLength) { "" }
                v is TextValue.Format -> return listOf(item)
                v is TextValue.Chars -> codePointsOf(v.s)
                else -> return emptyList()
            }
            if (chars.isEmpty()) return emptyList()
            val deleted = if (item.deletedLength > 0) 1 else 0
            val out = ArrayList<CrdtSequenceItem<TextValue>>(chars.size)
            var id = item.itemId
            var left = item.leftId
            for ((i, c) in chars.withIndex()) {
                val right = if (i == chars.lastIndex) item.rightId else CrdtId(id.author, id.counter + 1)
                out += CrdtSequenceItem(id, left, right, deleted, TextValue.Chars(c))
                left = id
                id = CrdtId(id.author, id.counter + 1)
            }
            return out
        }

        private fun codePointsOf(s: String): List<String> {
            // The device counts ids in UTF-16 code units? Observed files only use BMP text;
            // one id per Kotlin Char keeps ids aligned with the file for those.
            return s.map { it.toString() }
        }

        /** All items of [text] split into one item per character, in file order. */
        internal fun expandAll(text: Text): List<CrdtSequenceItem<TextValue>> = text.items.sequenceItems.flatMap { expand(it) }

        fun from(text: Text): TextDocument {
            val expanded = CrdtSequence(text.items.sequenceItems.flatMap { expand(it) })
            val keys = expanded.keys().toMutableList()
            var bold = false
            var italic = false
            val paragraphs = ArrayList<Paragraph>()

            fun parseParagraph(): Paragraph {
                var startId = CrdtId.END_MARKER
                if (keys.isNotEmpty() && (expanded[keys[0]] as? TextValue.Chars)?.s == "\n") startId = keys.removeAt(0)
                val spans = ArrayList<CrdtStr>()
                while (keys.isNotEmpty()) {
                    val k = keys[0]
                    when (val v = expanded[k]) {
                        is TextValue.Format -> when (v.code) {
                            1 -> bold = true
                            2 -> bold = false
                            3 -> italic = true
                            4 -> italic = false
                        }
                        is TextValue.Chars -> {
                            if (v.s == "\n") break
                            if (v.s.isNotEmpty()) {
                                val last = spans.lastOrNull()
                                val span = if (last != null && last.bold == bold && last.italic == italic) last
                                else CrdtStr(bold = bold, italic = italic).also { spans += it }
                                span.s.append(v.s)
                                span.ids += k
                            }
                        }
                    }
                    keys.removeAt(0)
                }
                val style = text.styles[startId]?.value ?: ParagraphStyle.PLAIN
                return Paragraph(spans, startId, style)
            }

            while (keys.isNotEmpty()) paragraphs += parseParagraph()
            return TextDocument(paragraphs)
        }
    }
}
