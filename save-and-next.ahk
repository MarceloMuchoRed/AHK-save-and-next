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

    ; Read CSV
    orders := []
    loop read csvFile {
        cols := StrSplit(A_LoopReadLine, ",")
        if (cols.Length >= 2)
            orders.Push({po: Trim(cols[1]), count: Integer(Trim(cols[2]))})
    }

    total := orders.Length

    loop orders.Length {
        order := orders[A_Index]

        ; Type PO number
        WinActivate winTitle
        Click poFieldX, poFieldY
        Sleep 200
        Send order.po
        Send "{Tab}"               ; load the order
        Sleep 1000                 ; wait for order to load

        ; Process each product
        loop order.count {
            rowY := firstRowY + (A_Index - 1) * rowHeight
            Click productX, rowY
            Sleep 300
            Send "{Tab}"
            Sleep 150
            Send "{Tab}"
            Sleep 150
        }

        ; Save
        Send "^s"
        Sleep 500

        ToolTip "Order " A_Index " of " total " done (PO " order.po ")"
        SetTimer () => ToolTip(), -2000
        Sleep 300
    }

    MsgBox "Done — " total " orders processed."
}

F14:: {
    ToolTip
    MsgBox "Stopped."
}