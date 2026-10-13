package app.inkbridge.rm

import app.inkbridge.rm.io.SceneStream
import app.inkbridge.rm.io.SceneItemBlock
import app.inkbridge.rm.io.UnreadableBlock
import app.inkbridge.rm.scene.*
import app.inkbridge.rm.text.TextDocument
import kotlinx.serialization.json.*
import org.junit.Assert.*
import org.junit.Test

/** Checks the Kotlin parser against output captured from the reference Python parser (rmscene). */
class GoldenParseTest {
    private fun res(name: String) =
        javaClass.getResourceAsStream("/rmscene/$name")?.readBytes() ?: error("missing resource $name")

    private val golden = Json.parseToJsonElement(String(res("golden.json"))).jsonObject

    private fun flatten(g: Group, out: MutableList<SceneItem>, depth: Int = 0) {
        for (c in g.childItems()) {
            out += c
            if (c is Group) flatten(c, out, depth + 1)
        }
    }

    @Test fun allSamplesMatchReferenceParser() {
        assertTrue(golden.size >= 13)
        for ((file, exp) in golden) {
            val bytes = res(file)
            val blocks = SceneStream.readBlocks(bytes)
            assertTrue("$file: unreadable blocks: " + blocks.filterIsInstance<UnreadableBlock>().map { it.error },
                blocks.none { it is UnreadableBlock })
            assertEquals("$file block count", exp.jsonObject["blocks"]!!.jsonArray.size, blocks.size)

            val tree = SceneTree.build(blocks)
            val items = mutableListOf<SceneItem>().also { flatten(tree.root, it) }
            val want = exp.jsonObject["items"]!!.jsonArray
            assertEquals("$file item count", want.size, items.size)
            for ((i, w) in want.withIndex()) {
                val o = w.jsonObject
                val got = items[i]
                val ctx = "$file item $i"
                when (o["kind"]!!.jsonPrimitive.content) {
                    "group" -> {
                        assertTrue(ctx, got is Group)
                        assertEquals(ctx, o["label"]!!.jsonPrimitive.content, (got as Group).label.value)
                    }
                    "line" -> {
                        got as Line
                        assertEquals(ctx, o["tool"]!!.jsonPrimitive.int, got.tool)
                        assertEquals(ctx, o["color"]!!.jsonPrimitive.int, got.color)
                        assertEquals(ctx, o["n"]!!.jsonPrimitive.int, got.points.size)
                        assertEquals(ctx, o["thickness"]!!.jsonPrimitive.double, got.thicknessScale, 1e-9)
                        val rgba = o["rgba"]!!.let { if (it is JsonNull) null else it.jsonArray.map { v -> v.jsonPrimitive.int } }
                        assertEquals(ctx, rgba, got.colorRgba?.toList())
                        val p0 = o["p0"]!!.let { if (it is JsonNull) null else it.jsonArray }
                        if (p0 != null) {
                            val p = got.points[0]
                            assertEquals(ctx, p0[0].jsonPrimitive.double, p.x.toDouble(), 1e-4)
                            assertEquals(ctx, p0[1].jsonPrimitive.double, p.y.toDouble(), 1e-4)
                            // v1 files hold floats; the reference keeps fractions, we truncate to ints.
                            assertEquals(ctx, p0[2].jsonPrimitive.double, p.speed.toDouble(), 1.0)
                            assertEquals(ctx, p0[3].jsonPrimitive.double, p.direction.toDouble(), 1.0)
                            assertEquals(ctx, p0[4].jsonPrimitive.double, p.width.toDouble(), 1.0)
                            assertEquals(ctx, p0[5].jsonPrimitive.double, p.pressure.toDouble(), 1.0)
                        }
                    }
                    "glyph" -> {
                        got as GlyphRange
                        assertEquals(ctx, o["text"]!!.jsonPrimitive.content, got.text)
                        assertEquals(ctx, o["color"]!!.jsonPrimitive.int, got.color)
                        assertEquals(ctx, o["rects"]!!.jsonPrimitive.int, got.rectangles.size)
                    }
                    else -> fail("$ctx: unknown golden kind")
                }
            }

            val wantText = exp.jsonObject["text"]!!.let { if (it is JsonNull) null else it.jsonArray }
            val rt = tree.rootText
            if (wantText == null) {
                assertNull("$file: unexpected text", rt)
            } else {
                val doc = TextDocument.from(rt!!)
                assertEquals("$file paragraphs", wantText.size, doc.paragraphs.size)
                for ((i, p) in wantText.withIndex()) {
                    assertEquals("$file para $i text", p.jsonObject["text"]!!.jsonPrimitive.content, doc.paragraphs[i].toString())
                    assertEquals("$file para $i style", p.jsonObject["style"]!!.jsonPrimitive.int, doc.paragraphs[i].style.code)
                }
            }
        }
    }

    @Test fun rejectsNonRmFile() {
        try {
            SceneStream.readBlocks("this is not an rm file at all, not even close.......".toByteArray())
            fail("expected failure")
        } catch (e: IllegalArgumentException) {
            assertTrue(e.message!!.contains("v6"))
        }
    }

    @Test fun lineBlocksAreSceneItemBlocks() {
        val blocks = SceneStream.readBlocks(res("Lines_v2.rm"))
        val lineBlocks = blocks.filterIsInstance<SceneItemBlock>().filter { it.blockType == SceneItemBlock.LINE }
        assertEquals(11, lineBlocks.size)
        // One of them is a deleted stroke (no payload); the other ten carry points.
        assertEquals(10, lineBlocks.count { it.value is Line })
    }
}
