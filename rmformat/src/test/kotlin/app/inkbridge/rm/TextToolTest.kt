package app.inkbridge.rm

import app.inkbridge.rm.edit.PageEditor
import app.inkbridge.rm.io.RootTextBlock
import app.inkbridge.rm.io.SceneStream
import app.inkbridge.rm.io.SceneWriter
import app.inkbridge.rm.scene.*
import app.inkbridge.rm.text.*
import org.junit.Assert.*
import org.junit.Test
import java.io.File

class TextToolTest {
    private fun res(name: String) = javaClass.getResourceAsStream("/rmscene/$name")!!.readBytes()

    private fun reload(e: PageEditor) = PageEditor.fromBytes(e.toBytes())

    @Test fun readsStylesAndFormattingOfARealPage() {
        val tree = SceneStream.readTree(res("Bold_Heading_Bullet_Normal.rm"))
        val c = TextContent.from(tree.rootText)
        assertTrue(c.text.isNotEmpty())
        assertTrue(c.paragraphs.size >= 3)
        assertTrue(c.paragraphs.any { it.style == ParagraphStyle.HEADING })
        assertTrue(c.paragraphs.any { it.style == ParagraphStyle.BULLET })
        assertTrue(c.paragraphs.any { it.style == ParagraphStyle.BOLD })
    }

    @Test fun reopeningTextWithoutEditsKeepsItsContent() {
        val tree = SceneStream.readTree(res("Bold_Heading_Bullet_Normal.rm"))
        val before = TextContent.from(tree.rootText)
        val after = TextContent.from(TextBuffer.open(tree.rootText, 1, 1000).toText())
        assertEquals(before.text, after.text)
        assertEquals(before.paragraphs.map { it.style }, after.paragraphs.map { it.style })
        assertArrayEquals(before.bold, after.bold)
        assertArrayEquals(before.italic, after.italic)
    }

    @Test fun typingMakesTextThatSurvivesSaveAndLoad() {
        val e = PageEditor.blank()
        assertNull(e.rootText)
        assertTrue(e.editText { it.insert(0, "Hello world") })
        val again = reload(e)
        assertEquals("Hello world", TextContent.from(again.rootText).text)
        assertEquals(-468.0, again.rootText!!.posX, 0.01)
        assertEquals(936f, again.rootText!!.width, 0f)
        assertEquals(234.0, again.rootText!!.posY, 0.01)
    }

    @Test fun enterSplitsParagraphsAndDeleteJoinsThemAgain() {
        val e = PageEditor.blank()
        e.editText { it.insert(0, "ab") }
        e.editText { it.insert(1, "\n") }
        var c = TextContent.from(e.rootText)
        assertEquals("a\nb", c.text)
        assertEquals(2, c.paragraphs.size)
        e.editText { it.delete(1, 2) }
        c = TextContent.from(reload(e).rootText)
        assertEquals("ab", c.text)
        assertEquals(1, c.paragraphs.size)
    }

    @Test fun enterAtTheStartKeepsAnEmptyFirstParagraph() {
        val e = PageEditor.blank()
        e.editText { it.insert(0, "x") }
        e.editText { it.insert(0, "\n") }
        val c = TextContent.from(reload(e).rootText)
        assertEquals("\nx", c.text)
        assertEquals(2, c.paragraphs.size)
        assertEquals(0, c.paragraphs[0].length)
    }

    @Test fun paragraphStylesBoldAndItalicRoundTrip() {
        val e = PageEditor.blank()
        e.editText { it.insert(0, "Title\nsome body text") }
        e.editText { it.setParagraphStyle(0, ParagraphStyle.HEADING) }
        e.editText { it.setFormat(11, 15, bold = true, italic = null) }
        e.editText { it.setFormat(16, 20, bold = null, italic = true) }
        val c = TextContent.from(reload(e).rootText)
        assertEquals("Title\nsome body text", c.text)
        assertEquals(ParagraphStyle.HEADING, c.paragraphs[0].style)
        assertEquals(ParagraphStyle.HEADING.code, reload(e).rootText!!.styles[CrdtId.END_MARKER]!!.value.code)
        assertEquals(listOf(11, 12, 13, 14), c.bold.indices.filter { c.bold[it] })
        assertEquals(listOf(16, 17, 18, 19), c.italic.indices.filter { c.italic[it] })
        // Clearing bold again leaves no bold characters.
        e.editText { it.setFormat(0, 20, bold = false, italic = false) }
        val d = TextContent.from(reload(e).rootText)
        assertTrue(d.bold.none { it }); assertTrue(d.italic.none { it })
    }

    @Test fun enterAfterATitleStartsBodyTextAndAListContinues() {
        val e = PageEditor.blank()
        e.editText { it.insert(0, "T") }
        e.editText { it.setParagraphStyle(0, ParagraphStyle.HEADING) }
        e.editText { it.insert(1, "\nitem") }
        e.editText { it.setParagraphStyle(1, ParagraphStyle.BULLET) }
        e.editText { it.insert(5, "\nnext") }
        val c = TextContent.from(reload(e).rootText)
        assertEquals(listOf(ParagraphStyle.HEADING, ParagraphStyle.BULLET, ParagraphStyle.BULLET), c.paragraphs.map { it.style })
    }

    @Test fun typingIsOneUndoStepWhenMerged() {
        val e = PageEditor.blank()
        e.editText(merge = true) { it.insert(0, "a") }
        e.editText(merge = true) { it.insert(1, "b") }
        e.editText(merge = true) { it.insert(2, "c") }
        assertEquals("abc", TextContent.from(e.rootText).text)
        assertTrue(e.undo())
        assertNull(e.rootText)
        assertFalse(e.undo())
        assertTrue(e.redo())
        assertEquals("abc", TextContent.from(e.rootText).text)
    }

    @Test fun idsOfNewTextNeverCollideWithExistingOnes() {
        val e = PageEditor.fromBytes(res("Bold_Heading_Bullet_Normal.rm"))
        val before = TextContent.from(e.rootText)
        e.editText { it.insert(before.length, "!!!") }
        e.editText { it.insert(0, "??") }
        val c = TextContent.from(e.rootText)
        assertEquals(c.length, c.ids.toSet().size)
        assertTrue(c.text.startsWith("??") && c.text.endsWith("!!!"))
        assertEquals(c.text, TextContent.from(reload(e).rootText).text)
    }

    @Test fun otherBlocksAreKeptByteForByte() {
        val bytes = res("Bold_Heading_Bullet_Normal.rm")
        val e = PageEditor.fromBytes(bytes)
        assertArrayEquals(bytes, e.toBytes())
        val others = { b: ByteArray -> SceneStream.readBlocks(b).filter { it !is RootTextBlock } }
        e.editText { it.insert(0, "x") }
        val wasBlocks = others(bytes)
        val nowBlocks = others(e.toBytes())
        assertEquals(wasBlocks.size, nowBlocks.size)
        assertArrayEquals(SceneWriter.write(wasBlocks.filter { it !is app.inkbridge.rm.io.PageInfoBlock }), SceneWriter.write(nowBlocks.filter { it !is app.inkbridge.rm.io.PageInfoBlock }))
    }

    @Test fun layoutWrapsLongParagraphsAndPlacesTheCaret() {
        val e = PageEditor.blank()
        val words = List(60) { "word$it" }.joinToString(" ")
        e.editText { it.insert(0, words) }
        val layout = e.renderer.textLayout!!
        assertTrue("wrapped", layout.lines.size > 3)
        for (l in layout.lines) assertTrue("fits ${l.right} <= ${layout.right + 1}", l.runs.lastOrNull()?.let { r -> r.x + TextMetrics.width(r.text.trimEnd(), l.size, r.bold, r.italic, l.font) <= layout.right + 1f } ?: true)
        // Every offset maps to a caret on some line and back to itself.
        for (o in listOf(0, 5, 100, words.length)) {
            val cr = layout.caret(o)
            assertEquals(o, layout.offsetAt(cr.x + 0.5f, (cr.top + cr.bottom) / 2))
        }
        assertTrue(layout.lines.zipWithNext().all { (a, b) -> b.baseline > a.baseline })
    }

    @Test fun svgExportHasTheTextInItsFont() {
        val e = PageEditor.blank()
        e.editText { it.insert(0, "Hello & <world>\nsecond") }
        e.editText { it.setParagraphStyle(0, ParagraphStyle.HEADING) }
        e.editText { it.setFormat(8, 15, bold = null, italic = true) }
        val svg = app.inkbridge.rm.export.PageExport.svg(e.renderer)
        assertTrue(svg, svg.contains("Hello &amp;"))
        assertTrue(svg.contains("font-family=\"reMarkable Sans"))
        assertTrue(svg.contains("font-style=\"italic\""))
        assertTrue(svg.contains("reMarkable Serif Small"))
    }

    @Test fun theColumnSetsTheWidthAndRelaysOutAsOneUndoStep() {
        val e = PageEditor.blank()
        e.editText { it.insert(0, List(150) { "word" }.joinToString(" ")) }
        val medium = e.renderer.textLayout!!
        assertEquals(TextColumn.MEDIUM, TextColumn.ofWidth(e.rootText!!.width))
        e.editText { it.setColumn(TextColumn.NARROW) }
        assertEquals(740f, e.rootText!!.width, 0f)
        assertEquals(-370.0, e.rootText!!.posX, 0.0)
        assertEquals(234.0, e.rootText!!.posY, 0.0)
        assertTrue(e.renderer.textLayout!!.lines.size > medium.lines.size)
        val wide = PageEditor.fromBytes(e.toBytes()).also { it.editText { b -> b.setColumn(TextColumn.WIDE) } }
        assertEquals(1152f, wide.rootText!!.width, 0f)
        assertTrue(wide.renderer.textLayout!!.lines.size < medium.lines.size)
        assertTrue(e.undo())
        assertEquals(936f, e.rootText!!.width, 0f)
        assertNull(TextColumn.ofWidth(1000f))
    }

    @Test fun stylesUseTheFirmwareFontsSizesAndMargins() {
        val e = PageEditor.blank()
        e.editText { it.insert(0, "T\nS\nbody\nitem\nnum\ndone") }
        e.editText { b ->
            b.setParagraphStyle(0, ParagraphStyle.HEADING); b.setParagraphStyle(1, ParagraphStyle.BOLD)
            b.setParagraphStyle(3, ParagraphStyle.BULLET); b.setParagraphStyle(4, ParagraphStyle.NUMBERED); b.setParagraphStyle(5, ParagraphStyle.CHECKBOX_CHECKED)
        }
        val l = e.renderer.textLayout!!.lines
        assertEquals(TextFont.RM_SERIF, l[0].font); assertEquals(64f, l[0].size, 0f)
        assertEquals(TextFont.RM_SANS_MEDIUM, l[1].font); assertEquals(36f, l[1].size, 0f)
        assertEquals(TextFont.RM_SANS, l[2].font); assertEquals(32f, l[2].size, 0f)
        // Block top margins 88 / 40 / 24 between the previous line's bottom and this line's top.
        assertEquals(234f + 4f + 88f, l[0].top, 0.01f)
        assertEquals(l[0].bottom + 40f, l[1].top, 0.01f)
        assertEquals(l[1].bottom + 24f, l[2].top, 0.01f)
        // Body lines are 1.18 x 32 high with 0.2 x that as a gap.
        assertEquals(l[2].bottom + 0.2f * l[2].height + 24f, l[3].top, 0.01f)
        // Lists: text at 48 from the box, bullets at +20, numbers right-aligned at +29, check boxes struck through.
        assertEquals(-468f + 4f + 48f, l[3].left, 0.01f)
        assertEquals(-468f + 4f + 20f, l[3].markerX, 0.01f)
        assertEquals(-468f + 4f + 29f, l[4].markerX, 0.01f)
        assertEquals(2, l[5].checkbox)
    }

    @Test fun everyShippedPageWithTextLaysOut() {
        val dir = File(System.getenv("RM_LIBRARY") ?: "../reference/remarkable-3.27.1.0/library")
        if (!dir.isDirectory) return
        var pages = 0
        dir.walkTopDown().filter { it.extension == "rm" }.forEach { f ->
            val tree = runCatching { SceneStream.readTree(f.readBytes()) }.getOrNull() ?: return@forEach
            val t = tree.rootText ?: return@forEach
            val c = TextContent.from(t)
            assertTrue(f.name, TextLayout.of(t).lines.isNotEmpty() || c.length == 0)
            // Reading and writing the page again keeps the text.
            val back = PageEditor.fromBytes(f.readBytes())
            assertEquals(c.text, TextContent.from(back.rootText).text)
            assertEquals(c.text, TextContent.from(TextBuffer.open(t, 1, 100000).toText()).text)
            pages++
        }
        println("pages with text: $pages")
    }
}
