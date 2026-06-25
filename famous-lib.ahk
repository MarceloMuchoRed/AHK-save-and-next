#Requires AutoHotkey v2.0

; ── FAMOUS window titles ─────────────────────────────────────────────────────
FAM_WIN  := "FAMOUS"
FAM_WARN := "Warning"

; ── Status bar pixel (client coords, hover over "Ready" text to get these) ───
STATUS_X     := 27
STATUS_Y     := 1006
STATUS_READY := "0xC5E6E6"

; ── PO field coords (client coords) ──────────────────────────────────────────
PO_FIELD_X := 370
PO_FIELD_Y := 165

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

; Returns true when order is loaded, false if 30s timeout is hit
WaitForOrderLoad(po, timeoutMs := 30000) {
    deadline := A_TickCount + timeoutMs
    loop {
        WaitIfCrashed()
        DismissNoteWarning()
        try {
            focused := ControlGetFocus(FAM_WIN)
            if (ControlGetText("FNHELP1", FAM_WIN) = "Ready" && ControlGetText(focused, FAM_WIN) = po)
                return true
        }
        if (A_TickCount >= deadline)
            return false
        Sleep 10
    }
}

WaitForReady() {
    lastCheck := A_TickCount
    loop {
        WaitIfCrashed()
        try {
            if (ControlGetText("FNHELP1", FAM_WIN) = "Ready")
                break
        }
        if (A_TickCount - lastCheck > 2000) {
            if WinExist(FAM_WARN) {
                WinActivate FAM_WARN
                WinWaitActive FAM_WARN, , 2
                Send "{Enter}"
                Sleep 250
                WinActivate FAM_WIN
                WinWaitActive FAM_WIN, , 3
            }
            lastCheck := A_TickCount
        }
        Sleep 50
    }
}

; Returns true if status changed from Ready, false if timeout
WaitForChange(timeoutMs := 3000) {
    deadline := A_TickCount + timeoutMs
    loop {
        WaitIfCrashed()
        try {
            if (ControlGetText("FNHELP1", FAM_WIN) != "Ready")
                return true
        }
        if (A_TickCount >= deadline)
            return false
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

; Dismisses the GL date warning that appears when saving old orders (Enter)
DismissGLWarning() {
    if WinExist(FAM_WARN) {
        WinActivate FAM_WARN
        WinWaitActive FAM_WARN, , 2
        Send "{Enter}"
        Sleep 250
        WinActivate FAM_WIN
        WinWaitActive FAM_WIN, , 3
    }
}

; ── UI helpers ───────────────────────────────────────────────────────────────
ClickPoField() {
    Click PO_FIELD_X, PO_FIELD_Y
}

; Sweep mouse around the PO field area to clear product description from status bar
ClearStatusBar() {
    for coord in [[360, 160], [415, 160], [415, 175], [360, 175], [PO_FIELD_X, PO_FIELD_Y]] {
        MouseMove coord[1], coord[2], 5
        Sleep 50
    }
}

; Waits until the cursor is no longer a wait/busy cursor (e.g. after save)
WaitForCursorNormal() {
    hWait     := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32514, "Ptr")
    hAppStart := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32650, "Ptr")
    loop {
        if (DllCall("GetCursor", "Ptr") != hWait
         && DllCall("GetCursor", "Ptr") != hAppStart)
            break
        Sleep 100
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
