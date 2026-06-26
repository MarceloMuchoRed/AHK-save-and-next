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

; Send text one character at a time with a small delay so dropdowns can keep up
TypeSlow(text, delay := 15) {
    loop StrLen(text) {
        SendText SubStr(text, A_Index, 1)
        Sleep delay
    }
}

; Normalize Unicode to NFC (precomposed) so ñ == ñ regardless of source encoding
NormalizeStr(str) {
    reqLen := DllCall("NormalizeString", "Int", 1, "WStr", str, "Int", -1, "Ptr", 0, "Int", 0)
    buf := Buffer(reqLen * 2)
    DllCall("NormalizeString", "Int", 1, "WStr", str, "Int", -1, "Ptr", buf, "Int", reqLen)
    return StrGet(buf, "UTF-16")
}

; Proper CSV line parser — handles quoted fields and commas inside values
ParseCSVLine(line) {
    fields    := []
    current   := ""
    inQuotes  := false
    i         := 1
    len       := StrLen(line)
    while i <= len {
        char := SubStr(line, i, 1)
        if (char = '"') {
            if (inQuotes && SubStr(line, i + 1, 1) = '"') {
                current .= '"'
                i += 2
                continue
            }
            inQuotes := !inQuotes
        } else if (char = "," && !inQuotes) {
            fields.Push(current)
            current := ""
        } else {
            current .= char
        }
        i++
    }
    fields.Push(current)
    return fields
}
