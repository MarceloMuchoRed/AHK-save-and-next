#Requires AutoHotkey v2.0

; Returns false and shows a msgbox if the window doesn't exist
WinCheck(title) {
    if WinExist(title)
        return true
    MsgBox title " not found! Is it open?"
    return false
}

; Returns false and shows a msgbox if the file doesn't exist
FileCheck(path) {
    if FileExist(path)
        return true
    MsgBox "File not found: " path
    return false
}

; Activate, maximize, and wait for a window to be active
WinFocus(title, timeout := 3) {
    WinActivate title
    WinMaximize title
    WinWaitActive title, , timeout
}
