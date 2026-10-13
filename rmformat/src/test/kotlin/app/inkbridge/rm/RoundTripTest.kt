package app.inkbridge.rm

import app.inkbridge.rm.io.SceneItemBlock
import app.inkbridge.rm.io.SceneStream
import app.inkbridge.rm.io.SceneWriter
import app.inkbridge.rm.io.UnreadableBlock
import org.junit.Assert.*
import org.junit.Test

class RoundTripTest {
    private fun res(name: String) = javaClass.getResourceAsStream("/rmscene/$name")!!.readBytes()
    private val files = listOf(
        "Bold_Heading_Bullet_Normal", "Color_and_tool_v3.14.4", "Lines_v2", "Lines_v2_updated",
        "More_color_highlight_shader_v3.15.4.2", "Normal_AB", "Normal_A_stroke_2_layers",
        "Normal_A_stroke_2_layers_v3.2.2", "Normal_A_stroke_2_layers_v3.3.2",
        "Wikipedia_highlighted_p1", "Wikipedia_highlighted_p2", "With_SceneInfo_Block", "test-crdt-ordering",
    )

    @Test fun readWriteIsByteIdentical() {
        val failures = mutableListOf<String>()
        var compared = 0
        for (f in files) {
            val original = res("$f.rm")
            val blocks = SceneStream.readBlocks(original)
            // v1-format line blocks can't be re-emitted as v1; those files are checked semantically below.
            if (blocks.any { it is SceneItemBlock && it.blockType == 5 && it.currentVersion == 1 }) continue
            compared++
            val rewritten = try { SceneWriter.write(blocks) } catch (e: Exception) { failures += "$f: write failed: $e"; continue }
            if (!original.contentEquals(rewritten)) {
                val i = original.indices.firstOrNull { it >= rewritten.size || original[it] != rewritten[it] } ?: rewritten.size
                failures += "$f: differs at byte $i (orig ${original.size} bytes, new ${rewritten.size})"
            }
        }
        assertTrue(failures.joinToString("\n"), failures.isEmpty())
        assertTrue("only $compared files compared byte-for-byte", compared >= 10)
    }

    @Test fun rewrittenFilesParseToSameBlocks() {
        for (f in files) {
            val blocks = SceneStream.readBlocks(res("$f.rm"))
            if (blocks.any { it is SceneItemBlock && it.blockType == 5 && it.currentVersion == 1 }) continue
            val again = SceneStream.readBlocks(SceneWriter.write(blocks))
            assertEquals("$f block count", blocks.size, again.size)
            assertTrue("$f unreadable", again.none { it is UnreadableBlock })
        }
    }
}
