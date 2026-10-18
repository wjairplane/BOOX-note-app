package app.inkbridge

import android.content.Context
import java.security.MessageDigest
import java.security.SecureRandom
import javax.crypto.SecretKeyFactory
import javax.crypto.spec.PBEKeySpec

/** Where the passcode's hash and its attempt counters live (SharedPreferences on the device, memory in tests). */
interface PasscodeStorage {
    var hash: String?
    var salt: String?
    var length: Int
    var failedAttempts: Int
    /** Wall-clock time (ms) until which entering a passcode is refused; 0 = not locked out. */
    var lockedUntil: Long
    fun clear()
}

class PrefsPasscodeStorage(context: Context) : PasscodeStorage {
    private val sp = context.getSharedPreferences("security", Context.MODE_PRIVATE)
    override var hash: String? get() = sp.getString("hash", null); set(v) { sp.edit().putString("hash", v).apply() }
    override var salt: String? get() = sp.getString("salt", null); set(v) { sp.edit().putString("salt", v).apply() }
    override var length: Int get() = sp.getInt("length", 6); set(v) { sp.edit().putInt("length", v).apply() }
    override var failedAttempts: Int get() = sp.getInt("attempts", 0); set(v) { sp.edit().putInt("attempts", v).apply() }
    override var lockedUntil: Long get() = sp.getLong("lockedUntil", 0L); set(v) { sp.edit().putLong("lockedUntil", v).apply() }
    override fun clear() { sp.edit().clear().apply() }
}

/** The state the unlock screen reflects (the firmware's PasscodeHandler `pinLockedState`). */
enum class PinState { OPEN, TIMED_OUT, FINAL_TRY, LOCKED }

/**
 * The passcode of the firmware's Security settings: 4, 6 or 8 digits, stored only as a salted PBKDF2 hash. After the 6th wrong entry in
 * a row the passcode is refused for 1, 5, 15 and 60 minutes (entries 6 to 9); the entry after that is the final try, and a wrong
 * final try leaves the device locked until it is reset (which erases it). A right entry clears the count.
 */
class PasscodeLock(private val storage: PasscodeStorage, private val now: () -> Long = System::currentTimeMillis) {
    val hasPasscode: Boolean get() = storage.hash != null
    val passcodeLength: Int get() = if (hasPasscode) storage.length else DEFAULT_LENGTH
    val failedAttempts: Int get() = storage.failedAttempts

    /** Milliseconds left of the current time-out (0 when there is none). */
    fun lockRemainingMs(): Long = (storage.lockedUntil - now()).coerceAtLeast(0L)

    /** Length of the time-out the last wrong entry started (for the progress bar), 0 when none applies. */
    fun lockTotalMs(): Long = LOCKOUT_MS.getOrElse(storage.failedAttempts - FIRST_LOCKOUT_ATTEMPT) { 0L }

    val state: PinState
        get() = when {
            storage.failedAttempts >= MAX_ATTEMPTS -> PinState.LOCKED
            lockRemainingMs() > 0 -> PinState.TIMED_OUT
            storage.failedAttempts == MAX_ATTEMPTS - 1 -> PinState.FINAL_TRY
            else -> PinState.OPEN
        }

    /** Check an entry against the stored passcode. Entries made during a time-out or after the lock-out are refused and not counted. */
    fun verify(code: String): Boolean {
        val hash = storage.hash ?: return true
        if (state == PinState.TIMED_OUT || state == PinState.LOCKED) return false
        if (matches(code, hash, storage.salt)) {
            storage.failedAttempts = 0; storage.lockedUntil = 0L
            return true
        }
        val n = storage.failedAttempts + 1
        storage.failedAttempts = n
        storage.lockedUntil = LOCKOUT_MS.getOrNull(n - FIRST_LOCKOUT_ATTEMPT)?.let { now() + it } ?: 0L
        return false
    }

    /** Set (or change) the passcode. Changing needs the current one; returns false if it is wrong or [code] is not 4, 6 or 8 digits. */
    fun set(current: String?, code: String): Boolean {
        if (code.length !in LENGTHS || !code.all { it in '0'..'9' }) return false
        if (hasPasscode && !(current != null && verify(current))) return false
        val salt = ByteArray(16).also { SecureRandom().nextBytes(it) }
        storage.salt = salt.toHex()
        storage.hash = hash(code, salt).toHex()
        storage.length = code.length
        storage.failedAttempts = 0; storage.lockedUntil = 0L
        return true
    }

    /** Turn the passcode off; needs the current one. */
    fun remove(code: String): Boolean {
        if (!hasPasscode) return true
        if (!verify(code)) return false
        storage.clear()
        return true
    }

    /** Forget the passcode and its counters without asking (after the device has been reset). */
    fun reset() = storage.clear()

    private fun matches(code: String, hashHex: String, saltHex: String?): Boolean {
        val salt = saltHex?.fromHex() ?: return false
        return MessageDigest.isEqual(hash(code, salt), hashHex.fromHex())
    }

    companion object {
        val LENGTHS = listOf(4, 6, 8)
        const val DEFAULT_LENGTH = 6
        /** The wrong entry (1-based) from which time-outs begin, and the entries after which the device is locked for good. */
        const val FIRST_LOCKOUT_ATTEMPT = 6
        const val MAX_ATTEMPTS = 10
        /** Time-out after the 6th, 7th, 8th and 9th wrong entry: 1, 5, 15 and 60 minutes. */
        val LOCKOUT_MS = listOf(60_000L, 300_000L, 900_000L, 3_600_000L)

        private const val ITERATIONS = 60_000

        private fun hash(code: String, salt: ByteArray): ByteArray =
            SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(PBEKeySpec(code.toCharArray(), salt, ITERATIONS, 256)).encoded

        private fun ByteArray.toHex() = joinToString("") { "%02x".format(it) }
        private fun String.fromHex() = ByteArray(length / 2) { substring(it * 2, it * 2 + 2).toInt(16).toByte() }
    }
}
