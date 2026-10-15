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
