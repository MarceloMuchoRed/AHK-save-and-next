#Requires AutoHotkey v2.0
#SingleInstance Force

; Press F16 while FAMOUS is saving to see current cursor handle.
; Press F16 when FAMOUS is idle to compare.
; If the handles differ between saving and idle, WaitForCursorNormal will work.

F16:: {
    hWait     := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32514, "Ptr")
    hAppStart := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32650, "Ptr")

    ci := Buffer(16 + A_PtrSize)
    NumPut "UInt", ci.Size, ci, 0
    DllCall("GetCursorInfo", "Ptr", ci)
    hCurrent := NumGet(ci, 8, "Ptr")

    MsgBox "Current cursor : " hCurrent
        . "`nWait cursor    : " hWait
        . "`nAppStart cursor: " hAppStart
        . "`n`nMatch wait?     " (hCurrent = hWait ? "YES" : "no")
        . "`nMatch appstart? " (hCurrent = hAppStart ? "YES" : "no")
}

F17:: ExitApp
