#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ahk-utils.ahk
#Include famous-lib.ahk

CoordMode "Mouse", "Client"
CoordMode "Pixel", "Client"

csvFile  := A_ScriptDir "\orders.csv"

poFieldX    := 370
poFieldY    := 165
productX    := 330
firstRowY   := 342
rowHeight   := 20
orderLoadMs := 1500  ; tune this up if orders aren't fully loaded before products are clicked

F13:: {
    if !WinCheck(FAM_WIN)
        return
    if !FileCheck(csvFile)
        return

    WinFocus(FAM_WIN)

    orders := []
    loop read csvFile {
        cols := StrSplit(A_LoopReadLine, ",")
        if (cols.Length >= 2)
            orders.Push({po: Trim(cols[1]), count: Integer(Trim(cols[2]))})
    }

    total := orders.Length

    loop orders.Length {
        order := orders[A_Index]

        WinActivate FAM_WIN
        Click poFieldX, poFieldY
        Sleep 200
        Send "^a"
        Send order.po
        Send "{Enter}"
        Sleep orderLoadMs
        DismissNoteWarning()

        loop order.count {
            rowY := firstRowY + (A_Index - 1) * rowHeight
            Click productX, rowY
            WaitForChange()
            Send "{Tab}"
            Sleep 150
            Send "{Tab}"
            Sleep 150
        }

        FamSave()
        WaitForReady()
        DismissGLWarning()

        ToolTip "Order " A_Index " of " total " done (PO " order.po ")"
        SetTimer () => ToolTip(), -2000
    }

    MsgBox "Done — " total " orders processed."
}

F14:: {
    ToolTip
    MsgBox "Stopped."
}

; ── Debug: F15 toggles logging status bar control text + pixel color to file ──
debugLogging := false
debugFile    := A_ScriptDir "\debug-status.txt"

F15:: {
    global debugLogging
    debugLogging := !debugLogging
    ToolTip debugLogging ? "Debug logging ON" : "Debug logging OFF"
    SetTimer () => ToolTip(), -2000

    if debugLogging {
        if FileExist(debugFile)
            FileDelete debugFile
        SetTimer LogStatus, 50
    } else {
        SetTimer LogStatus, 0
    }
}

LogStatus() {
    global debugFile
    try {
        text    := ControlGetText("FNHELP1", FAM_WIN)
        color   := PixelGetColor(STATUS_X, STATUS_Y)
        focused := ControlGetFocus(FAM_WIN)
        FileAppend A_TickCount " | text: " text " | color: " color " | focus: " focused "`n", debugFile
    }
}
