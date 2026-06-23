#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ahk-utils.ahk
#Include famous-lib.ahk

CoordMode "Mouse", "Client"
CoordMode "Pixel", "Client"

csvFile  := A_ScriptDir "\orders.csv"
logFile  := A_ScriptDir "\batch.log"

productX    := 330
firstRowY   := 342
rowHeight   := 18

g_paused := false

F13:: {
    global g_paused

    if !WinCheck(FAM_WIN)
        return
    if !FileCheck(csvFile)
        return

    WinFocus(FAM_WIN)

    ; ── Parse and validate CSV ────────────────────────────────────────────────
    orders  := []
    skipped := 0
    loop read csvFile {
        if (Trim(A_LoopReadLine) = "")
            continue
        cols := StrSplit(A_LoopReadLine, ",")
        try {
            cnt := Integer(Trim(cols[2]))
            if (cols.Length < 2 || cnt < 1)
                throw Error()
            orders.Push({po: Trim(cols[1]), count: cnt})
        } catch {
            skipped++
        }
    }

    if (skipped > 0)
        MsgBox skipped " row(s) skipped — missing or invalid product count."

    if (orders.Length = 0) {
        MsgBox "No valid orders found in CSV."
        return
    }

    total := orders.Length
    FileAppend "=== Batch started " FormatTime(, "yyyy-MM-dd HH:mm:ss") " | " total " orders ===`n", logFile

    ; ── Main loop ─────────────────────────────────────────────────────────────
    loop orders.Length {
        order     := orders[A_Index]
        startTime := A_TickCount

        ; Pause check
        while g_paused {
            ToolTip "Paused — press F15 to resume"
            Sleep 200
        }
        ToolTip

        WinActivate FAM_WIN
        WinWaitActive FAM_WIN, , 10
        WinMaximize FAM_WIN
        ClickPoField()
        Sleep 150
        Send "^a"
        Send order.po
        Send "{Enter}"

        if !WaitForOrderLoad(order.po) {
            msg := "TIMEOUT loading PO " order.po " — skipped"
            ToolTip msg
            FileAppend FormatTime(, "yyyy-MM-dd HH:mm:ss") " | PO " order.po " | " order.count " rows | SKIPPED (load timeout)`n", logFile
            Sleep 2000
            ToolTip
            continue
        }

        Sleep 300
        DismissNoteWarning()

        loop order.count {
            rowY := firstRowY + (A_Index - 1) * rowHeight
            loop {
                Click productX, rowY
                if WaitForChange(3000)
                    break
                ; click didn't register — retry
            }
            Send "{Tab}"
            Sleep 300
            Send "{Tab}"
            Sleep 300
        }

        ; Sleep 200
        ; Click 380, 255
        ; Sleep 200
        ; Send "NONBOB"
        ; Sleep 100

        ClearStatusBar()
        FamSave()
        Sleep 500
        DismissGLWarning()
        WaitForReady()

        elapsed := A_TickCount - startTime
        FileAppend FormatTime(, "yyyy-MM-dd HH:mm:ss") " | PO " order.po " | " order.count " rows | " Round(elapsed / 1000, 1) "s | OK`n", logFile

        ToolTip "Order " A_Index " of " total " done (PO " order.po ")"
        SetTimer () => ToolTip(), -2000
    }

    FileAppend "=== Batch done " FormatTime(, "yyyy-MM-dd HH:mm:ss") " ===`n`n", logFile
    MsgBox "Done — " total " orders processed."
}

F14:: {
    ToolTip
    ExitApp
}

F15:: {
    global g_paused
    g_paused := !g_paused
    if !g_paused
        ToolTip
}
