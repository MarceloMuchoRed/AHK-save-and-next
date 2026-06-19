#Requires AutoHotkey v2.0
#SingleInstance Force

CoordMode "Mouse", "Client"

winTitle := "FAMOUS"
csvFile  := A_ScriptDir "\orders.csv"

poFieldX    := 408
poFieldY    := 30
productX    := 330
firstRowY   := 342
rowHeight   := 20

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

WaitForReady() {
    global winTitle
    loop {
        WaitIfCrashed()
        try {
            if (ControlGetText("FNHELP1", winTitle) = "Ready")
                break
        }
        Sleep 50
    }
}

WaitForChange() {
    global winTitle
    loop {
        WaitIfCrashed()
        try {
            if (ControlGetText("FNHELP1", winTitle) != "Ready")
                break
        }
        Sleep 50
    }
}

F13:: {
    if !WinExist(winTitle) {
        MsgBox "Window not found! Is FAMOUS open?"
        return
    }

    if !FileExist(csvFile) {
        MsgBox "orders.csv not found in script folder!"
        return
    }

    WinActivate winTitle
    WinMaximize winTitle
    WinWaitActive winTitle, , 3

    orders := []
    loop read csvFile {
        cols := StrSplit(A_LoopReadLine, ",")
        if (cols.Length >= 2)
            orders.Push({po: Trim(cols[1]), count: Integer(Trim(cols[2]))})
    }

    total := orders.Length

    loop orders.Length {
        order := orders[A_Index]

        WinActivate winTitle
        Click poFieldX, poFieldY
        Sleep 200
        Send order.po
        Send "{Tab}"
        WaitForChange()
        WaitForReady()

        loop order.count {
            rowY := firstRowY + (A_Index - 1) * rowHeight
            Click productX, rowY
            WaitForChange()
            Send "{Tab}"
            Sleep 150
            Send "{Tab}"
            Sleep 150
        }

        Send "^s"
        WaitForReady()

        ToolTip "Order " A_Index " of " total " done (PO " order.po ")"
        SetTimer () => ToolTip(), -2000
    }

    MsgBox "Done — " total " orders processed."
}

F14:: {
    ToolTip
    MsgBox "Stopped."
}
