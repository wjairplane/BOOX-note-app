package app.inkbridge

import app.inkbridge.ui.middleEllipsis
import org.junit.Assert.assertEquals
import org.junit.Test

class MiddleEllipsisTest {
    @Test fun shortNamesAreUntouched() {
        assertEquals("Journal", middleEllipsis("Journal"))
        assertEquals("Meeting notes", middleEllipsis("Meeting notes"))
    }

    @Test fun longNamesKeepTheirStartAndEnd() {
        assertEquals("FY27 bud…erview", middleEllipsis("FY27 budget overview"))
    }

    @Test fun spacesNextToTheEllipsisAreTrimmed() {
        assertEquals("Project…name", middleEllipsis("Project plan with a long name", 8, 5))
    }
}

class NearestEdgeTest {
    @Test fun snapsToTheClosestEdge() {
        val n = { x: Float, y: Float -> app.inkbridge.ui.nearestEdge(x, y, 700f, 900f) }
        assertEquals(app.inkbridge.ToolbarPosition.LEFT, n(30f, 400f))
        assertEquals(app.inkbridge.ToolbarPosition.RIGHT, n(680f, 300f))
        assertEquals(app.inkbridge.ToolbarPosition.TOP, n(350f, 20f))
        assertEquals(app.inkbridge.ToolbarPosition.BOTTOM, n(350f, 890f))
    }
}
