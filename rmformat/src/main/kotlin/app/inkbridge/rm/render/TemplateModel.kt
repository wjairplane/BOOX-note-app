package app.inkbridge.rm.render

import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.json.*

/**
 * A parsed reMarkable `.template` file: named constants and a tree of groups, paths and text.
 * Values are kept as [Expr]s and evaluated per page size by [TemplateRenderer]. Pure Kotlin.
 */
class TemplateDef(
    val name: String,
    val landscape: Boolean,
    val categories: List<String>,
    /** Constants in file order; they may refer to each other (and to the built-ins), in any order. */
    val constants: List<Pair<String, Expr>>,
    val items: List<TemplateItem>,
) {
    companion object {
        @OptIn(ExperimentalSerializationApi::class)
        private val lenient = Json { isLenient = true; allowTrailingComma = true; allowComments = true }

        /** Parse a template file's text. Tolerates trailing commas and comments; unknown keys and items are skipped. */
        fun parse(text: String): TemplateDef {
            val root = lenient.parseToJsonElement(text.removePrefix("﻿")).jsonObject
            val constants = ArrayList<Pair<String, Expr>>()
            (root["constants"] as? JsonArray)?.forEach { c ->
                (c as? JsonObject)?.forEach { (k, v) -> expr(v)?.let { constants += k to it } }
            }
            return TemplateDef(
                name = root.str("name") ?: "",
                landscape = root.str("orientation") == "landscape",
                categories = (root["categories"] as? JsonArray).orEmpty().mapNotNull { (it as? JsonPrimitive)?.contentOrNull },
                constants = constants,
                items = (root["items"] as? JsonArray).orEmpty().mapNotNull { item(it) },
            )
        }

        private fun JsonObject.str(k: String) = (this[k] as? JsonPrimitive)?.contentOrNull

        internal fun expr(v: JsonElement?): Expr? {
            val p = v as? JsonPrimitive ?: return null
            if (p is JsonNull) return null
            return if (p.isString) Expr.parse(p.content) else p.doubleOrNull?.let { Expr.const(it) }
        }

        private fun item(e: JsonElement): TemplateItem? {
            val o = e as? JsonObject ?: return null
            return when (o.str("type")) {
                "group" -> {
                    val bb = o["boundingBox"] as? JsonObject
                    val rep = o["repeat"] as? JsonObject
                    TemplateItem.Group(
                        x = expr(bb?.get("x")) ?: Expr.const(0.0),
                        y = expr(bb?.get("y")) ?: Expr.const(0.0),
                        width = expr(bb?.get("width")) ?: Expr.Var("parentWidth"),
                        height = expr(bb?.get("height")) ?: Expr.Var("parentHeight"),
                        rows = rep?.get("rows")?.let { Repeat.parse(it) } ?: Repeat.Count(Expr.const(1.0)),
                        columns = rep?.get("columns")?.let { Repeat.parse(it) } ?: Repeat.Count(Expr.const(1.0)),
                        children = (o["children"] as? JsonArray).orEmpty().mapNotNull { item(it) },
                    )
                }
                "path" -> TemplateItem.Path(
                    commands = pathData(o["data"] as? JsonArray ?: JsonArray(emptyList())),
                    strokeColor = o.str("strokeColor")?.let(::color),
                    strokeWidth = expr(o["strokeWidth"]),
                    fillColor = o.str("fillColor")?.let(::color),
                )
                "text" -> {
                    val pos = o["position"] as? JsonObject
                    TemplateItem.Text(
                        text = o.str("text") ?: "",
                        fontSize = expr(o["fontSize"]) ?: Expr.const(32.0),
                        x = expr(pos?.get("x")) ?: Expr.const(0.0),
                        y = expr(pos?.get("y")) ?: Expr.const(0.0),
                    )
                }
                else -> null
            }
        }

        /** `#rrggbb` or `#aarrggbb` (the firmware writes alpha first, as QML does) to an ARGB int. */
        internal fun color(s: String): Int? {
            val h = s.trim().removePrefix("#")
            return when (h.length) {
                6 -> h.toLongOrNull(16)?.let { (0xFF000000L or it).toInt() }
                8 -> h.toLongOrNull(16)?.toInt()
                else -> null
            }
        }

        /** Split `["M", 0, "x", "L", ...]` into commands with their argument expressions. A repeated argument group reuses the last command. */
        private fun pathData(a: JsonArray): List<PathCmd> {
            val out = ArrayList<PathCmd>()
            var cur: Char? = null
            var args = ArrayList<Expr>()
            fun flush() {
                val c = cur ?: return
                val n = arity(c)
                if (n == 0) { out += PathCmd(c, emptyList()); args = ArrayList(); return }
                var k = 0
                var first = true
                while (k + n <= args.size) {
                    // After the first group of a Move the SVG rule is that further pairs are Lines.
                    val letter = if (!first && c == 'M') 'L' else c
                    out += PathCmd(letter, args.subList(k, k + n).toList())
                    k += n; first = false
                }
                args = ArrayList()
            }
            for (el in a) {
                val p = el as? JsonPrimitive ?: continue
                val s = if (p.isString) p.content else null
                if (s != null && s.length == 1 && s[0].isUpperCase() && arity(s[0]) >= 0) {
                    flush(); cur = s[0]
                } else expr(p)?.let { args += it }
            }
            flush()
            return out
        }

        private fun arity(c: Char) = when (c) { 'M', 'L' -> 2; 'H', 'V' -> 1; 'C' -> 6; 'Q' -> 4; 'Z' -> 0; else -> -1 }
    }
}

class PathCmd(val letter: Char, val args: List<Expr>)

/** How a group repeats along one axis. */
sealed interface Repeat {
    /** A fixed number of cells, starting at the group's own box. */
    class Count(val n: Expr) : Repeat
    /** Cells in a direction until the page edge: [forward] (down / right), backward (up / left) or both ("infinite"). */
    class Fill(val forward: Boolean, val backward: Boolean) : Repeat

    companion object {
        internal fun parse(v: JsonElement): Repeat? {
            val p = v as? JsonPrimitive ?: return null
            if (p.isString) {
                when (p.content.trim().lowercase()) {
                    "down", "right" -> return Fill(forward = true, backward = false)
                    "up", "left" -> return Fill(forward = false, backward = true)
                    "infinite" -> return Fill(forward = true, backward = true)
                }
            }
            return TemplateDef.expr(p)?.let { Count(it) }
        }
    }
}

sealed interface TemplateItem {
    class Group(
        val x: Expr, val y: Expr, val width: Expr, val height: Expr,
        val rows: Repeat, val columns: Repeat, val children: List<TemplateItem>,
    ) : TemplateItem

    /** `strokeColor` null = the default rule colour; a transparent colour hides the outline. */
    class Path(val commands: List<PathCmd>, val strokeColor: Int?, val strokeWidth: Expr?, val fillColor: Int?) : TemplateItem

    /** [y] is the text baseline; [x] the left edge. */
    class Text(val text: String, val fontSize: Expr, val x: Expr, val y: Expr) : TemplateItem
}
