package app.inkbridge

import app.inkbridge.ToolbarPosition.*
import app.inkbridge.ui.ToolbarZones
import org.junit.Assert.*
import org.junit.Test

class ToolbarZonesTest {
    private val w = 1404f; private val h = 1872f
    @Test fun nothingNearTheCorner() = assertNull(ToolbarZones.target(LEFT, 100f, 100f, w, h))
    @Test fun edgeStripsWin() {
        assertEquals(RIGHT, ToolbarZones.target(LEFT, w - 50f, 900f, w, h))
        assertEquals(BOTTOM, ToolbarZones.target(LEFT, 700f, h - 50f, w, h))
        assertEquals(TOP, ToolbarZones.target(LEFT, 700f, 100f, w, h))
        assertEquals(LEFT, ToolbarZones.target(TOP, 50f, 900f, w, h))
    }
    @Test fun neverTheCurrentEdgeStrip() = assertNotEquals(LEFT, ToolbarZones.target(LEFT, 60f, 900f, w, h))
    @Test fun anglesPickBetweenZones() {
        // Seen from a left toolbar's corner: a shallow angle is the "close" beam (Top), the middle goes across (Right), a steep one is the wide beam (Bottom).
        assertEquals(TOP, ToolbarZones.target(LEFT, 800f, 200f, w, h))
        assertEquals(RIGHT, ToolbarZones.target(LEFT, 600f, 200f, w, h))
        assertEquals(RIGHT, ToolbarZones.target(LEFT, 700f, 700f, w, h))
        assertEquals(BOTTOM, ToolbarZones.target(LEFT, 300f, 900f, w, h))
    }
}
