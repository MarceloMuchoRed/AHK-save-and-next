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
saveEvery  := 15
saveSleep  := 6000  ; ms to wait after save for filter to reapply

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
        cols := StrSplit(A_LoopReadLine, ",")
        if (cols.Length < 10)
            continue
        products.Push(cols)
    }

    if (products.Length = 0) {
        MsgBox "No valid products found in products.csv."
        return
    }

    total := products.Length
    FileAppend "=== Products batch started " FormatTime(, "yyyy-MM-dd HH:mm:ss") " | " total " products ===`n", logFile

    Click FIRST_SKU_X, FIRST_SKU_Y
    Sleep 300

    loop products.Length {
        product    := products[A_Index]
        productIdx := A_Index

        while g_paused {
            ToolTip "Paused — press F15 to resume"
            Sleep 200
        }
        ToolTip

        ; Type each of the 10 columns and Tab to the next.
        ; After the 10th Tab, FAMOUS moves to the next empty row.
        loop 10 {
            Send Trim(product[A_Index])
            Sleep 100
            Send "{Tab}"
            Sleep 150
        }

        FileAppend FormatTime(, "yyyy-MM-dd HH:mm:ss") " | SKU " Trim(product[1]) " | OK`n", logFile
        ToolTip "Product " productIdx " of " total " (SKU " Trim(product[1]) ")"
        SetTimer () => ToolTip(), -1500

        ; Save every saveEvery rows, then reanchor to first visible empty row
        if (Mod(productIdx, saveEvery) = 0 && productIdx < total) {
            ToolTip "Saving after " productIdx " of " total " products..."
            FamSave()
            Sleep saveSleep
            Click FIRST_SKU_X, FIRST_SKU_Y
            Sleep 300
        }
    }

    ToolTip "Saving final batch..."
    FamSave()
    Sleep saveSleep

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
