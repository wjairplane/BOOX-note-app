package app.inkbridge.rm.render

/**
 * The expression language of the firmware's `.template` files: numbers, identifiers (constants and the
 * built-ins templateWidth, templateHeight, textWidth, parentWidth, parentHeight), `+ - * / %`, comparisons,
 * `&&`, `||`, `!`, parentheses and the `cond ? a : b` operator. Booleans are 1 / 0.
 *
 * Parsing is separate from evaluation so a template is parsed once and evaluated per page size.
 * Pure Kotlin; no Android dependencies.
 */
sealed interface Expr {
    fun eval(env: Env): Double

    /** Variable lookup. Unknown names evaluate to 0 (the firmware is equally forgiving). */
    fun interface Env { fun get(name: String): Double? }

    class Num(val value: Double) : Expr { override fun eval(env: Env) = value }
    class Var(val name: String) : Expr { override fun eval(env: Env) = env.get(name) ?: 0.0 }
    class Neg(val e: Expr) : Expr { override fun eval(env: Env) = -e.eval(env) }
    class Not(val e: Expr) : Expr { override fun eval(env: Env) = if (e.eval(env) == 0.0) 1.0 else 0.0 }
    class Bin(val op: String, val a: Expr, val b: Expr) : Expr {
        override fun eval(env: Env): Double {
            // Short-circuit like C so `x != 0 && y / x > 1` is safe.
            if (op == "&&") return if (a.eval(env) != 0.0 && b.eval(env) != 0.0) 1.0 else 0.0
            if (op == "||") return if (a.eval(env) != 0.0 || b.eval(env) != 0.0) 1.0 else 0.0
            val x = a.eval(env)
            val y = b.eval(env)
            fun bool(v: Boolean) = if (v) 1.0 else 0.0
            val r = when (op) {
                "+" -> x + y
                "-" -> x - y
                "*" -> x * y
                "/" -> if (y == 0.0) 0.0 else x / y
                "%" -> if (y == 0.0) 0.0 else x % y
                "<" -> bool(x < y)
                ">" -> bool(x > y)
                "<=" -> bool(x <= y)
                ">=" -> bool(x >= y)
                "==" -> bool(x == y)
                "!=" -> bool(x != y)
                else -> 0.0
            }
            return if (r.isNaN() || r.isInfinite()) 0.0 else r
        }
    }
    class Cond(val c: Expr, val a: Expr, val b: Expr) : Expr {
        override fun eval(env: Env) = if (c.eval(env) != 0.0) a.eval(env) else b.eval(env)
    }

    class ParseException(message: String) : IllegalArgumentException(message)

    companion object {
        fun parse(src: String): Expr = Parser(src).parseAll()

        fun const(v: Double): Expr = Num(v)

        /** Names an expression refers to (used to order constants). */
        fun variables(e: Expr, out: MutableSet<String> = mutableSetOf()): Set<String> {
            when (e) {
                is Var -> out += e.name
                is Neg -> variables(e.e, out)
                is Not -> variables(e.e, out)
                is Bin -> { variables(e.a, out); variables(e.b, out) }
                is Cond -> { variables(e.c, out); variables(e.a, out); variables(e.b, out) }
                is Num -> Unit
            }
            return out
        }
    }

    private class Parser(private val s: String) {
        private var i = 0

        fun parseAll(): Expr {
            val e = ternary()
            skipWs()
            if (i != s.length) throw ParseException("Unexpected '${s[i]}' at $i in \"$s\"")
            return e
        }

        private fun skipWs() { while (i < s.length && s[i].isWhitespace()) i++ }
        private fun peek(t: String): Boolean { skipWs(); return s.startsWith(t, i) }
        private fun eat(t: String): Boolean { if (peek(t)) { i += t.length; return true }; return false }

        private fun ternary(): Expr {
            val c = or()
            if (eat("?")) {
                val a = ternary()
                if (!eat(":")) throw ParseException("Expected ':' at $i in \"$s\"")
                val b = ternary()
                return Cond(c, a, b)
            }
            return c
        }

        private fun or(): Expr { var l = and(); while (eat("||")) l = Bin("||", l, and()); return l }
        private fun and(): Expr { var l = equality(); while (eat("&&")) l = Bin("&&", l, equality()); return l }

        private fun equality(): Expr {
            var l = relational()
            while (true) {
                l = when {
                    eat("==") -> Bin("==", l, relational())
                    eat("!=") -> Bin("!=", l, relational())
                    else -> return l
                }
            }
        }

        private fun relational(): Expr {
            var l = additive()
            while (true) {
                l = when {
                    eat("<=") -> Bin("<=", l, additive())
                    eat(">=") -> Bin(">=", l, additive())
                    eat("<") -> Bin("<", l, additive())
                    eat(">") -> Bin(">", l, additive())
                    else -> return l
                }
            }
        }

        private fun additive(): Expr {
            var l = multiplicative()
            while (true) {
                l = when {
                    eat("+") -> Bin("+", l, multiplicative())
                    eat("-") -> Bin("-", l, multiplicative())
                    else -> return l
                }
            }
        }

        private fun multiplicative(): Expr {
            var l = unary()
            while (true) {
                l = when {
                    eat("*") -> Bin("*", l, unary())
                    eat("/") -> Bin("/", l, unary())
                    eat("%") -> Bin("%", l, unary())
                    else -> return l
                }
            }
        }

        private fun unary(): Expr = when {
            eat("-") -> Neg(unary())
            eat("+") -> unary()
            peek("!") && !peek("!=") -> { eat("!"); Not(unary()) }
            else -> primary()
        }

        private fun primary(): Expr {
            skipWs()
            if (i >= s.length) throw ParseException("Unexpected end of \"$s\"")
            val c = s[i]
            if (c == '(') {
                i++
                val e = ternary()
                if (!eat(")")) throw ParseException("Expected ')' at $i in \"$s\"")
                return e
            }
            if (c.isDigit() || c == '.') {
                val start = i
                while (i < s.length && (s[i].isDigit() || s[i] == '.')) i++
                if (i < s.length && (s[i] == 'e' || s[i] == 'E') && i + 1 < s.length && (s[i + 1].isDigit() || s[i + 1] == '-' || s[i + 1] == '+')) {
                    i += 2
                    while (i < s.length && s[i].isDigit()) i++
                }
                return Num(s.substring(start, i).toDoubleOrNull() ?: throw ParseException("Bad number at $start in \"$s\""))
            }
            if (c.isLetter() || c == '_') {
                val start = i
                while (i < s.length && (s[i].isLetterOrDigit() || s[i] == '_')) i++
                return Var(s.substring(start, i))
            }
            throw ParseException("Unexpected '$c' at $i in \"$s\"")
        }
    }
}
