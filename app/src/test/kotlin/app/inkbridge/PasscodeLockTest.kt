package app.inkbridge

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class PasscodeLockTest {
    private class Memory : PasscodeStorage {
        override var hash: String? = null
        override var salt: String? = null
        override var length = 6
        override var failedAttempts = 0
        override var lockedUntil = 0L
        override fun clear() { hash = null; salt = null; length = 6; failedAttempts = 0; lockedUntil = 0L }
    }

    private var time = 1_000_000L
    private val storage = Memory()
    private val lock = PasscodeLock(storage) { time }

    private fun wrong(n: Int, code: String = "999999") = repeat(n) { assertFalse(lock.verify(code)) }

    @Test fun noPasscodeMeansOpen() {
        assertFalse(lock.hasPasscode)
        assertTrue(lock.verify("anything"))
        assertEquals(PinState.OPEN, lock.state)
    }

    @Test fun setAcceptsFourSixAndEightDigits() {
        for (code in listOf("1234", "123456", "12345678")) {
            lock.reset()
            assertTrue(lock.set(null, code))
            assertEquals(code.length, lock.passcodeLength)
            assertTrue(lock.verify(code))
        }
    }

    @Test fun setRejectsOtherLengthsAndNonDigits() {
        for (code in listOf("", "123", "12345", "1234567", "123456789", "12a456", "１２３４５６")) assertFalse(code, lock.set(null, code))
        assertFalse(lock.hasPasscode)
    }

    @Test fun passcodeIsStoredOnlyAsAHash() {
        assertTrue(lock.set(null, "482916"))
        assertFalse(storage.hash!!.contains("482916"))
        assertFalse(storage.salt!!.contains("482916"))
        assertEquals(64, storage.hash!!.length)
    }

    @Test fun sameCodeGetsADifferentSaltAndHashEachTime() {
        lock.set(null, "135790"); val first = storage.hash; val salt = storage.salt
        lock.reset(); lock.set(null, "135790")
        assertNotEquals(salt, storage.salt)
        assertNotEquals(first, storage.hash)
    }

    @Test fun changingNeedsTheCurrentCode() {
        assertTrue(lock.set(null, "1111"))
        assertFalse(lock.set(null, "2222"))
        assertFalse(lock.set("0000", "2222"))
        assertTrue(lock.set("1111", "22222222"))
        assertEquals(8, lock.passcodeLength)
        assertFalse(lock.verify("1111"))
        assertTrue(lock.verify("22222222"))
    }

    @Test fun removingNeedsTheCurrentCode() {
        lock.set(null, "123456")
        assertFalse(lock.remove("654321"))
        assertTrue(lock.hasPasscode)
        assertTrue(lock.remove("123456"))
        assertFalse(lock.hasPasscode)
        assertNull(storage.hash)
    }

    @Test fun fiveWrongEntriesDoNotLockOut() {
        lock.set(null, "123456")
        wrong(5)
        assertEquals(PinState.OPEN, lock.state)
        assertEquals(0L, lock.lockRemainingMs())
        assertTrue(lock.verify("123456"))
    }

    @Test fun lockoutStepsAreOneFiveFifteenAndSixtyMinutes() {
        lock.set(null, "123456")
        wrong(5)
        for ((i, minutes) in listOf(1, 5, 15, 60).withIndex()) {
            assertFalse(lock.verify("000000"))
            assertEquals(6 + i, lock.failedAttempts)
            assertEquals(PinState.TIMED_OUT, lock.state)
            assertEquals(minutes * 60_000L, lock.lockRemainingMs())
            assertEquals(minutes * 60_000L, lock.lockTotalMs())
            time += minutes * 60_000L
            assertEquals(0L, lock.lockRemainingMs())
        }
    }

    @Test fun entriesDuringATimeoutAreRefusedEvenIfRightAndNotCounted() {
        lock.set(null, "123456")
        wrong(6)
        assertFalse(lock.verify("123456"))
        assertEquals(6, lock.failedAttempts)
        time += 59_999
        assertFalse(lock.verify("123456"))
        time += 1
        assertTrue(lock.verify("123456"))
        assertEquals(0, lock.failedAttempts)
    }

    @Test fun afterTheSixtyMinuteStepTheNextEntryIsTheFinalTry() {
        lock.set(null, "123456")
        wrong(5)
        for (m in listOf(1, 5, 15)) { wrong(1); time += m * 60_000L }
        assertEquals(PinState.OPEN, lock.state)
        wrong(1) // the 9th wrong entry: 60 minutes
        assertEquals(PinState.TIMED_OUT, lock.state)
        time += 60 * 60_000L
        assertEquals(PinState.FINAL_TRY, lock.state)
        assertTrue(lock.verify("123456")) // the final try can still succeed
        assertEquals(PinState.OPEN, lock.state)
    }

    @Test fun aWrongFinalTryLocksTheDeviceForGood() {
        lock.set(null, "123456")
        wrong(5)
        for (m in listOf(1, 5, 15, 60)) { wrong(1); time += m * 60_000L }
        assertEquals(PinState.FINAL_TRY, lock.state)
        wrong(1)
        assertEquals(PinState.LOCKED, lock.state)
        time += 24 * 3_600_000L
        assertEquals(PinState.LOCKED, lock.state)
        assertFalse(lock.verify("123456"))
    }

    @Test fun resetClearsEverything() {
        lock.set(null, "123456")
        wrong(5)
        for (m in listOf(1, 5, 15, 60)) { wrong(1); time += m * 60_000L }
        wrong(1)
        assertEquals(PinState.LOCKED, lock.state)
        lock.reset()
        assertFalse(lock.hasPasscode)
        assertEquals(PinState.OPEN, lock.state)
        assertEquals(0, lock.failedAttempts)
    }

    @Test fun wrongOldCodeWhileChangingCountsAsAFailedAttempt() {
        lock.set(null, "123456")
        assertFalse(lock.set("000000", "654321"))
        assertEquals(1, lock.failedAttempts)
        assertTrue(lock.set("123456", "654321"))
        assertEquals(0, lock.failedAttempts)
    }

    @Test fun counterAndLockoutSurviveANewInstanceOnTheSameStorage() {
        lock.set(null, "123456")
        wrong(6)
        val again = PasscodeLock(storage) { time }
        assertEquals(PinState.TIMED_OUT, again.state)
        assertEquals(6, again.failedAttempts)
    }

    @Test fun appLockStartsLockedOnlyWithAPasscode() {
        assertFalse(AppLock(lock) { 0L }.locked)
        lock.set(null, "123456")
        assertTrue(AppLock(lock) { 0L }.locked)
    }

    @Test fun appLockLocksAfterAWhileInTheBackgroundButNotAfterAShortTrip() {
        lock.set(null, "123456")
        var now = 0L
        val app = AppLock(lock) { now }
        app.unlock()
        app.onStop(); now += AppLock.BACKGROUND_GRACE_MS; app.onStart()
        assertFalse(app.locked)
        app.onStop(); now += AppLock.BACKGROUND_GRACE_MS + 1; app.onStart()
        assertTrue(app.locked)
        app.unlock()
        app.onScreenOff()
        assertTrue(app.locked)
    }

    @Test fun appLockDoesNothingWithoutAPasscode() {
        var now = 0L
        val app = AppLock(lock) { now }
        app.onStop(); now += 10 * AppLock.BACKGROUND_GRACE_MS; app.onStart(); app.onScreenOff()
        assertFalse(app.locked)
    }
}
