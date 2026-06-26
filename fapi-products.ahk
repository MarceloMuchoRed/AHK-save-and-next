#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ahk-utils.ahk
#Include famous-lib.ahk

CoordMode "Mouse", "Client"
CoordMode "Pixel", "Client"

csvFile  := A_ScriptDir "\products.csv"
logFile  := A_ScriptDir "\products.log"

; ── Coords of the first SKU cell in the product list (client coords) ─────────
FIRST_SKU_X := 345   ; TODO: fill in
FIRST_SKU_Y := 244   ; TODO: fill in

; ── How many rows to add before saving ───────────────────────────────────────
saveEvery := 30

; ── Resume: set to the row number to start from (1 = beginning) ──────────────
startRow  := 1

g_paused := false

F13:: {
    global g_paused

    if !WinCheck(FAM_WIN)
        return
    if !FileCheck(csvFile)
        return

    WinFocus(FAM_WIN)

    products := []
    loop read csvFile {
        if (Trim(A_LoopReadLine) = "")
            continue
        cols := ParseCSVLine(A_LoopReadLine)
        if (cols.Length < 10)
            continue
        products.Push(cols)
    }

    if (products.Length = 0) {
        MsgBox "No valid products found in products.csv."
        return
    }

    if (startRow > 1) {
        trimmed := []
        loop products.Length {
            if (A_Index >= startRow)
                trimmed.Push(products[A_Index])
        }
        products := trimmed
    }

    if (products.Length = 0) {
        MsgBox "startRow (" startRow ") is beyond the end of the file."
        return
    }

    total    := products.Length
    FileAppend "=== Products batch started " FormatTime(, "yyyy-MM-dd HH:mm:ss") " | row " startRow " | " total " remaining ===`n", logFile

    Click FIRST_SKU_X, FIRST_SKU_Y
    Sleep 300

    loop products.Length {
        product    := products[A_Index]
        productIdx := A_Index + startRow - 1

        while g_paused {
            ToolTip "Paused — press F15 to resume"
            Sleep 200
        }
        ToolTip

        ; Type each of the 10 CSV columns, verify each one, then today's date as 11th.
        ; After the 11th Tab, FAMOUS moves to the next empty row.
        mismatch := false
        loop 10 {
            colIdx   := A_Index
            expected := Trim(product[colIdx])
            TypeSlow(expected)
            Sleep 400
            try {
                actual := Trim(ControlGetText(ControlGetFocus(FAM_WIN), FAM_WIN))
                if (actual != expected) {
                    mismatch := true
                    FileAppend FormatTime(, "yyyy-MM-dd HH:mm:ss") " | row " productIdx " | SKU " Trim(product[1]) " | MISMATCH col " colIdx " expected '" expected "' got '" actual "'`n", logFile
                    ToolTip
                    MsgBox "Mismatch on row " productIdx " column " colIdx ":`nExpected: " expected "`nActual:   " actual "`n`nFix it manually then click OK to continue, or F14 to exit."
                    mismatch := false
                }
            }
            Send "{Tab}"
            Sleep 150
        }
        TypeSlow(FormatTime(, "MM/dd/yyyy"))
        Sleep 50
        Send "{Tab}"
        Sleep 150

        FileAppend FormatTime(, "yyyy-MM-dd HH:mm:ss") " | row " productIdx " | SKU " Trim(product[1]) " | OK`n", logFile
        ToolTip "Row " productIdx " of " (total + startRow - 1) " (SKU " Trim(product[1]) ")"
        SetTimer () => ToolTip(), -1500

        ; Save every saveEvery rows, then reanchor to first visible empty row
        if (Mod(productIdx, saveEvery) = 0 && A_Index < products.Length) {
            ToolTip "Saving after " productIdx " of " total " products..."
            FamSave()
            Sleep 10000
            if WinExist("Application Message") {
                ToolTip
                MsgBox "Application Message detected after row " productIdx ". Handle it manually, then click OK to resume from the next product, or F14 to exit."
                WinActivate FAM_WIN
                WinWaitActive FAM_WIN, , 5
                WinMaximize FAM_WIN
            }
            Click FIRST_SKU_X, FIRST_SKU_Y
            Sleep 300
        }
    }

    ToolTip "Saving final batch..."
    FamSave()
    Sleep 10000
    if WinExist("Application Message") {
        ToolTip
        MsgBox "Application Message detected on final save. Handle it manually, then click OK."
    }

    FileAppend "=== Batch done " FormatTime(, "yyyy-MM-dd HH:mm:ss") " ===`n`n", logFile
    MsgBox "Done — " total " products added."
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
