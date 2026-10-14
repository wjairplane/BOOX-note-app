package app.inkbridge

import android.content.Context
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import app.inkbridge.rm.edit.PenTool
import app.inkbridge.rm.render.PageTemplate
import app.inkbridge.rm.scene.PenColorId

enum class SortBy(val label: String) { MODIFIED("Last modified"), NAME("Name") }

/** Where the notebook toolbar sits (the tablet's default is the top edge). */
enum class ToolbarPosition(val label: String) { TOP("Top"), BOTTOM("Bottom"), LEFT("Left"), RIGHT("Right") }

/** One of the two quick-switch writing tools: a pen with its own colour and thickness. */
data class ToolSlot(val tool: PenTool, val colorId: Int, val thickness: Int) {
    fun encode() = "${tool.name},$colorId,$thickness"

    companion object {
        fun decode(s: String?, fallback: ToolSlot): ToolSlot = runCatching {
            val (t, c, th) = s!!.split(",")
            ToolSlot(PenTool.valueOf(t).takeIf { it.isPen } ?: fallback.tool, c.toInt(), th.toInt().coerceIn(1, 3))
        }.getOrDefault(fallback)
    }
}

/** App settings, persisted in SharedPreferences and observable from Compose. */
class Prefs(context: Context) {
    private val sp = context.getSharedPreferences("settings", Context.MODE_PRIVATE)

    private var _grid by mutableStateOf(sp.getBoolean("grid", true))
    var gridView: Boolean get() = _grid; set(v) { _grid = v; sp.edit().putBoolean("grid", v).apply() }

    private var _sort by mutableStateOf(runCatching { SortBy.valueOf(sp.getString("sort", "MODIFIED")!!) }.getOrDefault(SortBy.MODIFIED))
    var sortBy: SortBy get() = _sort; set(v) { _sort = v; sp.edit().putString("sort", v.name).apply() }

    private var _rev by mutableStateOf(sp.getBoolean("sortReversed", false))
    /** Reverse the sort order (oldest first / Z to A). */
    var sortReversed: Boolean get() = _rev; set(v) { _rev = v; sp.edit().putBoolean("sortReversed", v).apply() }

    private var _template by mutableStateOf(PageTemplate.fromId(sp.getString("template", "lines")))
    var defaultTemplate: PageTemplate get() = _template; set(v) { _template = v; sp.edit().putString("template", v.id).apply() }

    private var _slotA by mutableStateOf(ToolSlot.decode(sp.getString("slotA", null), ToolSlot(PenTool.FINELINER, PenColorId.BLACK, 2)))
    private var _slotB by mutableStateOf(ToolSlot.decode(sp.getString("slotB", null), ToolSlot(PenTool.HIGHLIGHTER, PenColorId.YELLOW, 2)))

    /** The two writing-tool slots on the toolbar (index 0 or 1). They remember their pen, colour and thickness. */
    fun slot(i: Int): ToolSlot = if (i == 0) _slotA else _slotB
    fun setSlot(i: Int, v: ToolSlot) {
        if (i == 0) _slotA = v else _slotB = v
        sp.edit().putString(if (i == 0) "slotA" else "slotB", v.encode()).apply()
    }

    private var _tbPos by mutableStateOf(runCatching { ToolbarPosition.valueOf(sp.getString("toolbar", "LEFT")!!) }.getOrDefault(ToolbarPosition.LEFT))
    var toolbarPosition: ToolbarPosition get() = _tbPos; set(v) { _tbPos = v; sp.edit().putString("toolbar", v.name).apply() }

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
