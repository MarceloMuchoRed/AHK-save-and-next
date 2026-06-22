#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ahk-utils.ahk
#Include famous-lib.ahk

CoordMode "Mouse", "Client"

csvFile  := A_ScriptDir "\orders.csv"

poFieldX    := 370
poFieldY    := 165
productX    := 330
firstRowY   := 342
rowHeight   := 20

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
        Send order.po
        Send "{Tab}"
        WaitForChange()
        WaitForReady()
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

        Send "^s"
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
