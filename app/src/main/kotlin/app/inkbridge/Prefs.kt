package app.inkbridge

import android.content.Context
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import app.inkbridge.rm.edit.PenTool
import app.inkbridge.rm.render.PageTemplate
import app.inkbridge.rm.scene.PenColorId

enum class SortBy(val label: String) { MODIFIED("Last modified"), NAME("Name") }

/** App settings, persisted in SharedPreferences and observable from Compose. */
class Prefs(context: Context) {
    private val sp = context.getSharedPreferences("settings", Context.MODE_PRIVATE)

    private var _grid by mutableStateOf(sp.getBoolean("grid", true))
    var gridView: Boolean get() = _grid; set(v) { _grid = v; sp.edit().putBoolean("grid", v).apply() }

    private var _sort by mutableStateOf(runCatching { SortBy.valueOf(sp.getString("sort", "MODIFIED")!!) }.getOrDefault(SortBy.MODIFIED))
    var sortBy: SortBy get() = _sort; set(v) { _sort = v; sp.edit().putString("sort", v.name).apply() }

    private var _template by mutableStateOf(PageTemplate.fromId(sp.getString("template", "lines")))
    var defaultTemplate: PageTemplate get() = _template; set(v) { _template = v; sp.edit().putString("template", v.id).apply() }

    private var _pen by mutableStateOf(runCatching { PenTool.valueOf(sp.getString("pen", "FINELINER")!!) }.getOrDefault(PenTool.FINELINER))
    /** The pen selected when a notebook opens. */
    var defaultPen: PenTool get() = _pen; set(v) { _pen = v; sp.edit().putString("pen", v.name).apply() }

    private var _color by mutableStateOf(sp.getInt("color", PenColorId.BLACK))
    var defaultColor: Int get() = _color; set(v) { _color = v; sp.edit().putInt("color", v).apply() }

    private var _hl by mutableStateOf(sp.getInt("hlColor", PenColorId.YELLOW))
    var highlighterColor: Int get() = _hl; set(v) { _hl = v; sp.edit().putInt("hlColor", v).apply() }

    private var _thickness by mutableStateOf(sp.getInt("thickness", 2))
    var defaultThickness: Int get() = _thickness; set(v) { _thickness = v; sp.edit().putInt("thickness", v).apply() }

    private var _swipe by mutableStateOf(sp.getBoolean("swipe", true))
    /** Swipe a finger left/right to turn pages. */
    var swipeToTurn: Boolean get() = _swipe; set(v) { _swipe = v; sp.edit().putBoolean("swipe", v).apply() }

    private var _finger by mutableStateOf(sp.getBoolean("finger", false))
    /** Let a finger draw too (off by default, so a resting palm or hand can't leave marks). */
    var fingerDrawing: Boolean get() = _finger; set(v) { _finger = v; sp.edit().putBoolean("finger", v).apply() }

    private var _refresh by mutableStateOf(sp.getInt("refresh", 0))
    /** Full e-ink refresh after this many strokes (0 = never automatically). */
    var refreshEveryStrokes: Int get() = _refresh; set(v) { _refresh = v; sp.edit().putInt("refresh", v).apply() }
}
