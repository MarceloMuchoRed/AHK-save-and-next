#Requires AutoHotkey v2.0

; ── FAMOUS window titles ─────────────────────────────────────────────────────
FAM_WIN  := "FAMOUS"
FAM_WARN := "Warning"

; ── Status bar pixel (client coords, hover over "Ready" text to get these) ───
STATUS_X     := 27
STATUS_Y     := 1006
STATUS_READY := "0xC5E6E6"

; ── Crash / ready helpers ────────────────────────────────────────────────────
WaitIfCrashed() {
    if WinExist(FAM_WIN " (Not Responding)") {
        ToolTip "FAMOUS not responding — paused, waiting to recover..."
        loop {
            Sleep 2000
            if !WinExist(FAM_WIN " (Not Responding)")
                break
        }
        ToolTip
        Sleep 500
    }
}

WaitForOrderLoad(po) {
    loop {
        WaitIfCrashed()
        try {
            focused := ControlGetFocus(FAM_WIN)
            if (ControlGetText("FNHELP1", FAM_WIN) = "Ready" && ControlGetText(focused, FAM_WIN) = po)
                break
        }
        Sleep 10
    }
}

WaitForReady() {
    loop {
        WaitIfCrashed()
        try {
            if (ControlGetText("FNHELP1", FAM_WIN) = "Ready")
                break
        }
        Sleep 50
    }
}

WaitForChange(timeoutMs := 0) {
    deadline := A_TickCount + timeoutMs
    loop {
        WaitIfCrashed()
        try {
            if (ControlGetText("FNHELP1", FAM_WIN) != "Ready")
                break
        }
        if (timeoutMs > 0 && A_TickCount >= deadline)
            break
        Sleep 10
    }
}

; ── Warning dismissers ────────────────────────────────────────────────────────
; Dismisses the note warning that appears when opening an order with a note (Alt+O)
DismissNoteWarning() {
    if WinExist(FAM_WARN) {
        WinActivate FAM_WARN
        WinWaitActive FAM_WARN, , 2
        Send "!o"
        Sleep 250
        WinActivate FAM_WIN
    }
}

; Dismisses the GL date warning that appears when navigating old orders (Alt+Y)
DismissGLWarning() {
    if WinExist(FAM_WARN) {
        WinActivate FAM_WARN
        WinWaitActive FAM_WARN, , 2
        Send "!y"
        Sleep 250
        WinActivate FAM_WIN
    }
}

; ── FAMOUS keyboard shortcuts ─────────────────────────────────────────────────
FamSave()   => Send("^s")
FamFirst()  => Send("{F5}")
FamPrev()   => Send("{F6}")
FamNext()   => Send("{F7}")
FamLast()   => Send("{F8}")
FamSearch() => Send("^+l")
FamNew()    => Send("^n")
