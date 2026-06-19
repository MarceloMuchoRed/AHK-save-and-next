#Requires AutoHotkey v2.0
#SingleInstance Force

winTitle    := "FAMOUS"
warnTitle   := "Warning"
loops       := 3

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

WaitForReady(waitMs, key) {
    Sleep waitMs
    DismissWarning(key)
    if (ControlGetText("FNHELP1", winTitle) != "Ready") {
        loop {
            DismissWarning(key)
            if (ControlGetText("FNHELP1", winTitle) = "Ready")
                break
            Sleep 50
        }
    }
    DismissWarning(key)  ; one final check after Ready returns
}

F13:: {
    global running
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

; prueba 2