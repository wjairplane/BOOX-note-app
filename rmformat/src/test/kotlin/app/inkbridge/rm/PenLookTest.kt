package app.inkbridge.rm

import app.inkbridge.rm.edit.PenSpec
import app.inkbridge.rm.edit.PenTool
import app.inkbridge.rm.render.PenLook
import org.junit.Assert.*
import org.junit.Test

class PenLookTest {
    @Test fun everyPenHasAPositiveWidthAndPartialOrFullCoverage() {
        for (t in PenTool.PENS) for (th in 1..3) {
            val l = PenLook.of(PenSpec(t, thickness = th))
            println("LOOK ${t.name} t$th width=${"%.1f".format(l.width)} coverage=${"%.2f".format(l.coverage)}")
            assertTrue("$t $th width ${l.width}", l.width >= 1f && l.width < 80f)
            assertTrue(l.coverage in 0.15f..1f)
        }
    }

    @Test fun aThickerSettingNeverMakesAFinelinerNarrower() {
        val w = (1..3).map { PenLook.of(PenSpec(PenTool.FINELINER, thickness = it)).width }
        assertTrue(w.zipWithNext().all { (a, b) -> b >= a })
    }
}
