#Requires AutoHotkey v2.0
#SingleInstance Force

winTitle    := "FAMOUS"
warnTitle   := "Warning"

running := false

DismissWarning(key) {
    global warnTitle, winTitle
    if WinExist(warnTitle) {
        WinActivate warnTitle
        WinWaitActive warnTitle, , 2
        Send key
        Sleep 250
        WinActivate winTitle
    }
}

WaitIfCrashed() {
    global winTitle
    if WinExist(winTitle " (Not Responding)") {
        ToolTip "FAMOUS not responding — paused, waiting to recover..."
        loop {
            Sleep 2000
            if !WinExist(winTitle " (Not Responding)")
                break
        }
        ToolTip
        Sleep 500
    }
}

WaitForReady(waitMs, key) {
    Sleep waitMs
    WaitIfCrashed()
    DismissWarning(key)
    if (ControlGetText("FNHELP1", winTitle) != "Ready") {
        loop {
            WaitIfCrashed()
            DismissWarning(key)
            if (ControlGetText("FNHELP1", winTitle) = "Ready")
                break
            Sleep 50
        }
    }
    DismissWarning(key)
}

F13:: {
    global running

    result := InputBox("How many loops?", "Save and Next", "w200 h100", "300")
    if (result.Result = "Cancel")
        return
    loops := Integer(result.Value)
    if (loops < 1) {
        MsgBox "Please enter a number greater than 0."
        return
    }

    running := true

    if !WinExist(winTitle) {
        MsgBox "Window not found! Is FAMOUS open?"
        running := false
        return
    }

    WinActivate winTitle
    WinMaximize winTitle
    WinWaitActive winTitle, , 3

    loop loops {
        if !running
            break

        WinActivate winTitle
        Send "^s"
        WaitForReady(350, "!y")   ; handles GL date warning during/after save
        ToolTip "Order " A_Index " of " loops " done"
        SetTimer () => ToolTip(), -500

        if (A_Index = loops)
            break

        Send "{F7}"
        WaitForReady(350, "!o")    ; handles notes warning during/after next
    }

    running := false
    MsgBox "Done — " loops " loops completed."
}

F14:: {
    global running
    running := false
    MsgBox "Stopped."
}

