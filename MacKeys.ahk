#Requires AutoHotkey v2.0
#SingleInstance Force

; Mac-style keyboard for Windows.
;   Alt (left or right) = Cmd    Win = Option    Ctrl = Control
;   Win + Alt = window management
; Left to PowerToys on purpose:
;   Alt+Space        Command Palette (Spotlight)
;   Alt+` / Alt+Shift+`   cycle windows of the same app (AltWindowCycle)
;
; Precedence: app-specific rules come first in this file, then global special
; rules, then the generic "Cmd = Ctrl" rule built at the bottom. When several
; match, the one defined first wins.

GroupAdd "Browsers", "ahk_exe chrome.exe"
GroupAdd "Browsers", "ahk_exe msedge.exe"
GroupAdd "Browsers", "ahk_exe firefox.exe"
GroupAdd "Browsers", "ahk_exe brave.exe"

GroupAdd "Terminals", "ahk_exe WindowsTerminal.exe"
GroupAdd "Terminals", "ahk_class ConsoleWindowClass"
GroupAdd "Terminals", "ahk_exe mintty.exe"

; --- Tapping Alt or Win alone does nothing -------------------------------
; Sending an unassigned key while the modifier is down stops Alt from
; opening the menu bar and Win from opening Start. Combos still work.
; Not for Alt in Windows Terminal: it has no menu bar, and any key press
; (even this unassigned one) clears its text selection.
#HotIf !WinActive("ahk_exe WindowsTerminal.exe")
~*LAlt::
~*RAlt::Send "{Blind}{vkE8}"
#HotIf
~*LWin::
~*RWin::Send "{Blind}{vkE8}"

; --- Alt+Tab guard -------------------------------------------------------
; While the Alt+Tab switcher is open, every hotkey below is disabled so
; arrows and clicks reach the switcher untouched.
global altTabOpen := false

~*Tab:: {
    global altTabOpen
    if GetKeyState("Alt", "P") {
        altTabOpen := true
        SetTimer EndAltTab, 100
    }
}
; Backup for a missed Alt release (e.g. while a UAC prompt had the keyboard),
; which would leave every hotkey disabled: the switcher can only be open
; while Alt is really held.
EndAltTab() {
    global altTabOpen
    if !(DllCall("GetAsyncKeyState", "int", 0x12, "short") & 0x8000) {
        altTabOpen := false
        SetTimer , 0
    }
}
~*Esc:: {
    global altTabOpen
    altTabOpen := false
}
~*LAlt Up::
~*RAlt Up:: {
    global altTabOpen
    altTabOpen := false
}

; === App-specific ========================================================

; --- Windows Terminal (PowerShell and WSL) -------------------------------
; Line editing uses readline keys (Ctrl+A/E/U/W), which bash/zsh understand
; natively and PowerShell understands via MacKeys.ps1 (loaded from $PROFILE).
; TermSend keeps the selection intact (see TermSend below).
#HotIf !altTabOpen && WinActive("ahk_exe WindowsTerminal.exe")
!c::TermSend "^+c"         ; copy (never sends Ctrl+C / interrupt)
!v::TermSend "^+v"         ; paste
!a::TermSend "^{F11}"      ; select the command line (handler in MacKeys.ps1)
!t::TermSend "^+t"         ; new tab
!n::TermSend "^+n"         ; new window
!w::TermSend "^+w"         ; close pane/tab
!f::TermSend "^+f"         ; find
!k::TermSend "^{F12}"      ; clear screen and scrollback (handler in MacKeys.ps1)
!Left::TermSend "^a"       ; start of line
!Right::TermSend "^e"      ; end of line
!Up::TermSend "^+{Home}"   ; scroll to top
!Down::TermSend "^+{End}"  ; scroll to bottom
!Backspace::TermSend "^u"  ; delete to start of line
#Backspace::TermSend "^w"  ; delete previous word
!d::TermSend "!+="         ; iTerm Cmd+D: split pane right
!+d::TermSend "!+-"        ; iTerm Cmd+Shift+D: split pane down
![::TermSend "!{Left}"     ; iTerm Cmd+[: focus pane to the left
!]::TermSend "!{Right}"    ; iTerm Cmd+]: focus pane to the right
; Alt+1..9 (switch to tab) is created in the Generic section below.

; --- File Explorer file list: Finder behaviour ---------------------------
#HotIf !altTabOpen && ExplorerFileListFocused()
!Up::Send "!{Up}"          ; enclosing folder
!Down::Send "{Enter}"      ; open selection
!Backspace::Send "{Delete}"    ; move to Recycle Bin

; --- Browsers and File Explorer: Cmd+[ / Cmd+] = back / forward ----------
#HotIf !altTabOpen && (WinActive("ahk_group Browsers") || WinActive("ahk_class CabinetWClass"))
![::Send "!{Left}"
!]::Send "!{Right}"

; Cmd+Left / Cmd+Right = back / forward too, except while typing in a text
; field or in Word / Excel / PowerPoint on the web, where they go to the start
; / end of the line. Checked when the key is pressed rather than in #HotIf,
; where UI Automation calls are unreliable.
!Left::Send TextFieldFocused() || OfficeWebApp() ? "{Home}" : "!{Left}"
!Right::Send TextFieldFocused() || OfficeWebApp() ? "{End}" : "!{Right}"

; --- Chrome: Cmd+Shift+J = downloads -------------------------------------
#HotIf !altTabOpen && WinActive("ahk_exe chrome.exe")
!+j::Send "^j"

; --- Excel (desktop and on the web) --------------------------------------
; New line in a cell is Alt+Enter here, not the Ctrl+Enter (fill selection)
; that Cmd+Enter would otherwise become. Option+Enter does it too, as on a Mac.
; Excel has no Ctrl+Backspace / Ctrl+Delete word delete, so Option+Backspace /
; Option+Delete select the word first, then delete it.
; In a browser the tab is checked when the key is pressed (see OfficeWebApp).
#HotIf !altTabOpen && WinActive("ahk_exe EXCEL.EXE")
!Enter::Send "!{Enter}"
#Enter::Send "!{Enter}"
#Backspace::Send "^+{Left}{Backspace}"
#Delete::Send "^+{Right}{Delete}"
#HotIf !altTabOpen && WinActive("ahk_group Browsers")
!Enter::Send OfficeWebApp() = "Excel" ? "!{Enter}" : "^{Enter}"
#Enter::Send OfficeWebApp() = "Excel" ? "!{Enter}" : "#{Enter}"
#Backspace::Send OfficeWebApp() = "Excel" ? "^+{Left}{Backspace}" : "^{Backspace}"
#Delete::Send OfficeWebApp() = "Excel" ? "^+{Right}{Delete}" : "^{Delete}"

; --- Microsoft Teams -----------------------------------------------------
; Cmd+E (search) is File Explorer here. Enter = new line / Cmd+Enter = send
; is Teams' own setting: Settings > Chats and channels > "press Enter to".
#HotIf !altTabOpen && WinActive("ahk_exe ms-teams.exe")
!+f::Send "^e"             ; search

; --- Claude desktop app: Enter = new line, Cmd+Enter = send -------------
; Only in the prompt box, and not while its / or @ suggestion menu is open,
; so Enter still picks a suggestion and confirms dialogs. The app has no
; setting for this.
#HotIf !altTabOpen && WinActive("ahk_exe claude.exe")
$Enter::Send ClaudePromptFocused() ? "+{Enter}" : "{Enter}"
!Enter::Send ClaudePromptFocused() ? "{Enter}" : "^{Enter}"

; --- VS Code: Option shortcuts -------------------------------------------
#HotIf !altTabOpen && WinActive("ahk_exe Code.exe")
#Up::Send "!{Up}"          ; move line up
#Down::Send "!{Down}"      ; move line down
#+Up::Send "!+{Up}"        ; copy line up
#+Down::Send "!+{Down}"    ; copy line down
#LButton::Send "!{Click}"  ; add a cursor

; --- Control + A / E / K: line editing outside terminals -----------------
; Terminals get these keys untouched (readline handles them).
#HotIf !altTabOpen && !WinActive("ahk_group Terminals")
^a::Send "{Home}"          ; start of line
^e::Send "{End}"           ; end of line
^k::Send "+{End}{Delete}"  ; delete to end of line

; === Global ==============================================================
#HotIf !altTabOpen

; --- Mouse ---------------------------------------------------------------
!LButton::Send "^{Click}"
!+LButton::Send "^+{Click}"

; --- Cmd + arrows / Backspace: line and document ------------------------
!Left::Send "{Home}"
!Right::Send "{End}"
!Up::Send "^{Home}"
!Down::Send "^{End}"
!+Left::Send "+{Home}"
!+Right::Send "+{End}"
!+Up::Send "^+{Home}"
!+Down::Send "^+{End}"
!Backspace::Send "+{Home}{Backspace}"   ; delete to start of line

; --- Cmd shortcuts that are not simply Ctrl ------------------------------
!q::QuitApp()              ; quit app (all its windows)
!h::HideApp()              ; hide app (minimize all its windows)
!m::WinMinimize "A"        ; minimize
!g::Send "{F3}"            ; find next
!+g::Send "+{F3}"          ; find previous
!+z::Send "^y"             ; redo
!+[::Send "^{PgUp}"        ; previous tab
!+]::Send "^{PgDn}"        ; next tab
!+3::Send "#{PrintScreen}" ; screenshot: full screen (saved)
!+4::Run "ms-screenclip:"  ; screenshot: region (Snipping Tool)
!+x::Run "ms-screenclip:"  ; screenshot: region (your existing shortcut)
!e::Send "#e"              ; File Explorer (your existing shortcut)
!+c::Run '"' A_ProgramFiles '\Ditto\Ditto.exe" /Open', A_ProgramFiles '\Ditto'   ; Ditto clipboard history popup

; --- Cmd + Ctrl / Cmd + Option combos ------------------------------------
!^f::Send "{F11}"          ; Cmd+Ctrl+F: full screen
!^q::DllCall "LockWorkStation"    ; Cmd+Ctrl+Q: lock screen
!^Space::Send "#."         ; Cmd+Ctrl+Space: emoji picker
#!Esc::Send "^+{Esc}"      ; Cmd+Option+Esc: Task Manager (Force Quit)
#!i::Send "^+i"            ; Cmd+Option+I: developer tools
#!f::Send "^h"             ; Cmd+Option+F: find and replace

; --- Control: desktops (Spaces) and Task View (Mission Control) ----------
^Left::Send "^#{Left}"     ; previous desktop
^Right::Send "^#{Right}"   ; next desktop
^Up::Send "#{Tab}"         ; Task View

; --- Option (Win): word-level editing ------------------------------------
#Left::Send "^{Left}"
#Right::Send "^{Right}"
#+Left::Send "^+{Left}"
#+Right::Send "^+{Right}"
#Up::Send "{PgUp}"
#Down::Send "{PgDn}"
#Backspace::Send "^{Backspace}"   ; delete previous word
#Delete::Send "^{Delete}"         ; delete next word

; --- Win + Alt: window management (Rectangle) ----------------------------
; Windows are moved directly: sending Win+arrows while Alt is held only
; worked some of the time.
#!Enter::MaximizeWindow()
#!Left::SnapWindow("left")       ; left half
#!Right::SnapWindow("right")     ; right half
#!Up::SnapWindow("top")          ; top half
#!Down::SnapWindow("bottom")     ; bottom half
#!Backspace::RestoreWindow()     ; back to the size before snapping / maximizing
#!+Left::MoveToMonitor(-1)       ; previous monitor
#!+Right::MoveToMonitor(1)       ; next monitor

#HotIf

; === Generic: Cmd = Ctrl =================================================
; Alt + key -> Ctrl + key, and Alt + Shift + key -> Ctrl + Shift + key, for
; every letter, digit and symbol not handled above.

; Windows Terminal first, so it wins over the generic rule: Cmd+1..9 = tab 1..9
HotIf (*) => !altTabOpen && WinActive("ahk_exe WindowsTerminal.exe")
Loop 9
    Hotkey "!" A_Index, (hk) => TermSend("^!" SubStr(hk, 2))
HotIf

HotIf NotSwitching
for key in StrSplit("abcdefghijklmnopqrstuvwxyz0123456789")
    MapCmdToCtrl(key)
for key in ["-", "=", "[", "]", ";", "'", ",", ".", "/", "\", "Enter"]
    MapCmdToCtrl(key)
HotIf

NotSwitching(*) => !altTabOpen

MapCmdToCtrl(key) {
    Hotkey "!" key, (*) => Send("^{" key "}")
    Hotkey "!+" key, (*) => Send("^+{" key "}")
}

; === Helpers =============================================================

; Send without the menu-mask key Send normally adds when it releases Alt/Win:
; Windows Terminal treats that key as input and drops the text selection.
TermSend(keys) {
    A_MenuMaskKey := ""
    try Send keys
    finally A_MenuMaskKey := "vkE8"
}

QuitApp() {
    for w in ActiveAppWindows()
        WinClose w
}

HideApp() {
    for w in ActiveAppWindows()
        WinMinimize w
}

; Top-level windows of the active app: just the active window for Explorer
; (it also owns the taskbar and desktop), nothing on the desktop/taskbar.
ActiveAppWindows() {
    hwnd := WinExist("A")
    if !hwnd || WinActive("ahk_class Progman") || WinActive("ahk_class WorkerW") || WinActive("ahk_class Shell_TrayWnd")
        return []
    exe := WinGetProcessName(hwnd)
    if exe = "explorer.exe"
        return [hwnd]
    wins := []
    for w in WinGetList("ahk_exe " exe)
        if IsAppWindow(w)
            wins.Push(w)
    return wins
}

IsAppWindow(hwnd) {
    if WinGetTitle(hwnd) = "" || (WinGetExStyle(hwnd) & 0x80)   ; WS_EX_TOOLWINDOW
        return false
    return !DllCall("GetWindow", "Ptr", hwnd, "UInt", 4, "Ptr")  ; skip owned dialogs
}

; --- Window management ---------------------------------------------------
; Coordinates are physical pixels (per-monitor DPI aware), so mixed-scaling
; monitors line up. savedRects remembers each window's size before its first
; snap, for RestoreWindow; lastSnaps remembers each window's last snap, so
; pressing the same half again moves it to the monitor in that direction,
; like Rectangle.
global savedRects := Map()
global lastSnaps := Map()

ArrangeableWindow() {
    hwnd := WinExist("A")
    if !hwnd || WinActive("ahk_class Progman") || WinActive("ahk_class WorkerW") || WinActive("ahk_class Shell_TrayWnd")
        return 0
    return hwnd
}

MaximizeWindow() {
    if hwnd := ArrangeableWindow()
        WinMaximize hwnd
}

SnapWindow(side) {
    if !hwnd := ArrangeableWindow()
        return
    old := DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")
    if WinGetMinMax(hwnd)
        WinRestore hwnd
    if !savedRects.Has(hwnd)
        savedRects[hwnd] := FrameRect(hwnd)
    ; Same half again, and the window hasn't moved since: the opposite half of
    ; the monitor in that direction (if there is one).
    mon := WindowMonitor(hwnd)
    if lastSnaps.Has(hwnd) && lastSnaps[hwnd].side = side && SameRect(FrameRect(hwnd), lastSnaps[hwnd].rect)
        && (next := AdjacentMonitor(mon, side)) {
        mon := next
        side := Map("left", "right", "right", "left", "top", "bottom", "bottom", "top")[side]
    }
    MonitorGetWorkArea mon, &l, &t, &r, &b
    w := r - l, h := b - t, halfW := w // 2, halfH := h // 2
    switch side {
        case "left":   rect := [l, t, halfW, h]
        case "right":  rect := [l + halfW, t, w - halfW, h]
        case "top":    rect := [l, t, w, halfH]
        case "bottom": rect := [l, t + halfH, w, h - halfH]
    }
    MoveFrame(hwnd, rect*)
    if !SameRect(FrameRect(hwnd), rect, 0)  ; again, if a monitor change made the app rescale itself
        MoveFrame(hwnd, rect*)
    lastSnaps[hwnd] := {side: side, rect: FrameRect(hwnd)}
    DllCall "SetThreadDpiAwarenessContext", "ptr", old, "ptr"
}

; Monitor touching the given side ("left", "right", "top", "bottom") of
; monitor mon, or 0. If several touch it, the one sharing the longest edge.
AdjacentMonitor(mon, side) {
    MonitorGet mon, &l, &t, &r, &b
    best := 0, bestOverlap := 0
    Loop MonitorGetCount() {
        if A_Index = mon
            continue
        MonitorGet A_Index, &l2, &t2, &r2, &b2
        switch side {
            case "left":   touching := Abs(r2 - l) <= 2, overlap := Min(b, b2) - Max(t, t2)
            case "right":  touching := Abs(l2 - r) <= 2, overlap := Min(b, b2) - Max(t, t2)
            case "top":    touching := Abs(b2 - t) <= 2, overlap := Min(r, r2) - Max(l, l2)
            case "bottom": touching := Abs(t2 - b) <= 2, overlap := Min(r, r2) - Max(l, l2)
        }
        if touching && overlap > bestOverlap
            best := A_Index, bestOverlap := overlap
    }
    return best
}

SameRect(a, b, tolerance := 2) {
    loop 4
        if Abs(a[A_Index] - b[A_Index]) > tolerance
            return false
    return true
}

RestoreWindow() {
    if !hwnd := ArrangeableWindow()
        return
    if WinGetMinMax(hwnd) = 1 {
        WinRestore hwnd
    } else if savedRects.Has(hwnd) {
        old := DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")
        rect := savedRects.Delete(hwnd)
        MoveFrame(hwnd, rect*)
        DllCall "SetThreadDpiAwarenessContext", "ptr", old, "ptr"
    }
}

; Moves the window to the next/previous monitor (ordered top to bottom, then
; left to right, wrapping around), keeping its relative position and size.
MoveToMonitor(step) {
    if !(hwnd := ArrangeableWindow()) || MonitorGetCount() < 2
        return
    old := DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")
    order := []
    Loop MonitorGetCount() {
        MonitorGet A_Index, &l, &t
        order.Push({n: A_Index, key: (t + 100000) * 1000000 + (l + 100000)})
    }
    Loop order.Length - 1 {     ; insertion sort by position
        i := A_Index + 1
        while i > 1 && order[i - 1].key > order[i].key
            tmp := order[i], order[i] := order[i - 1], order[i - 1] := tmp, i--
    }
    cur := WindowMonitor(hwnd)
    for i, m in order
        if m.n = cur
            pos := i
    target := order[Mod(pos - 1 + step + order.Length, order.Length) + 1].n
    maximized := WinGetMinMax(hwnd) = 1
    if maximized
        WinRestore hwnd
    MonitorGetWorkArea cur, &l1, &t1, &r1, &b1
    MonitorGetWorkArea target, &l2, &t2, &r2, &b2
    x := 0, y := 0, w := 0, h := 0
    FrameRect(hwnd, &x, &y, &w, &h)
    sx := (r2 - l2) / (r1 - l1), sy := (b2 - t2) / (b1 - t1)
    MoveFrame hwnd, Round(l2 + (x - l1) * sx), Round(t2 + (y - t1) * sy), Round(w * sx), Round(h * sy)
    if maximized
        WinMaximize hwnd
    DllCall "SetThreadDpiAwarenessContext", "ptr", old, "ptr"
}

; Monitor containing the centre of the window.
WindowMonitor(hwnd) {
    FrameRect(hwnd, &x, &y, &w, &h)
    cx := x + w // 2, cy := y + h // 2
    Loop MonitorGetCount() {
        MonitorGet A_Index, &l, &t, &r, &b
        if cx >= l && cx < r && cy >= t && cy < b
            return A_Index
    }
    return MonitorGetPrimary()
}

; Visible frame of a window, without the invisible resize borders Windows
; adds around it. Returns [x, y, w, h] and also sets the output variables.
FrameRect(hwnd, &x := 0, &y := 0, &w := 0, &h := 0) {
    rect := Buffer(16)
    if DllCall("dwmapi\DwmGetWindowAttribute", "ptr", hwnd, "uint", 9, "ptr", rect, "uint", 16) = 0 {  ; DWMWA_EXTENDED_FRAME_BOUNDS
        x := NumGet(rect, 0, "int"), y := NumGet(rect, 4, "int")
        w := NumGet(rect, 8, "int") - x, h := NumGet(rect, 12, "int") - y
    } else {
        WinGetPos &x, &y, &w, &h, hwnd
    }
    return [x, y, w, h]
}

; Moves a window so its visible frame is exactly x, y, w, h.
MoveFrame(hwnd, x, y, w, h) {
    if WinGetMinMax(hwnd)
        WinRestore hwnd
    WinGetPos &wx, &wy, &ww, &wh, hwnd
    FrameRect(hwnd, &fx, &fy, &fw, &fh)
    WinMove x - (fx - wx), y - (fy - wy), w + (ww - fw), h + (wh - fh), hwnd
}

; "Word", "Excel" or "PowerPoint" when the active browser tab is that Office
; app on the web, else "". Neither the tab title (just the file name on
; SharePoint) nor the address (the same doc.aspx for all three) says which,
; so the page is checked for the app's frame via UI Automation. Results are
; remembered by window and tab title; "not Office" only for 10 seconds, in
; case the page was still loading.
OfficeWebApp() {
    static apps := Map("WacFrame_Word_0", "Word", "WacFrame_Excel_0", "Excel",
        "m_excelWebRenderer_ewaCtl_m_ewa", "Excel", "WacFrame_PowerPoint_0", "PowerPoint")
    static seen := Map()
    if !hwnd := WinActive("ahk_group Browsers")
        return ""
    key := hwnd "|" WinGetTitle(hwnd)
    if !seen.Has(key) || seen[key].app = "" && A_TickCount - seen[key].time > 10000 {
        id := UiaFindId(hwnd, apps)
        seen[key] := {app: id = "" ? "" : apps[id], time: A_TickCount}
    }
    return seen[key].app
}

; The first AutomationId (an HTML id in a browser) of ids, a Map keyed by id,
; found in the window, or "". One search for all of them.
UiaFindId(hwnd, ids) {
    try {
        ComCall 6, Uia(), "ptr", hwnd, "ptr*", &root := 0     ; IUIAutomation::ElementFromHandle
        root := ComValue(13, root)
        cond := 0
        for id in ids {
            v := Buffer(24, 0)                                 ; VARIANT (BSTR) id
            NumPut "ushort", 8, v
            NumPut "ptr", DllCall("OleAut32\SysAllocString", "wstr", id, "ptr"), v, 8
            ComCall 23, Uia(), "int", 30011, "ptr", v, "ptr*", &c := 0   ; CreatePropertyCondition(AutomationId)
            DllCall "OleAut32\VariantClear", "ptr", v
            c := ComValue(13, c)
            if cond {
                ComCall 28, Uia(), "ptr", cond, "ptr", c, "ptr*", &both := 0   ; CreateOrCondition
                c := ComValue(13, both)
            }
            cond := c
        }
        ComCall 5, root, "int", 4, "ptr", cond, "ptr*", &el := 0   ; FindFirst(TreeScope_Descendants)
        if el
            return UiaProperty(ComValue(13, el), 30011)
    }
    return ""
}

; True while typing in the Claude app's prompt box (a ProseMirror editor) with
; no suggestion menu open (aria expanded=true while it is).
ClaudePromptFocused() {
    try {
        el := FocusedElement()
        return InStr(UiaProperty(el, 30012), "ProseMirror") && !InStr(UiaProperty(el, 30102), "expanded=true")
    }
    return false
}

; True while typing in a text field. Chrome and Edge don't report their caret
; to CaretGetPos, so the focused element is also checked via UI Automation:
; an Edit control, or anything with an editable value (e.g. contenteditable).
TextFieldFocused() {
    if CaretGetPos()
        return true
    try {
        el := FocusedElement()
        if UiaProperty(el, 30003) = 50004   ; ControlType = Edit
            return true
        return UiaProperty(el, 30043) && !UiaProperty(el, 30046)   ; ValuePattern, not read-only
    }
    return false
}

FocusedElement() {
    ComCall 8, Uia(), "ptr*", &p := 0     ; IUIAutomation::GetFocusedElement
    return ComValue(13, p)
}

Uia() {
    static uia := ComObject("{ff48dba4-60ef-4201-aa87-54103eef594e}", "{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}")
    return uia
}

UiaProperty(el, id) {
    v := Buffer(24, 0)
    ComCall 10, el, "int", id, "ptr", v     ; IUIAutomationElement::GetCurrentPropertyValue
    vt := NumGet(v, 0, "ushort")
    val := vt = 3 ? NumGet(v, 8, "int") : vt = 11 ? NumGet(v, 8, "short") != 0 : vt = 8 && NumGet(v, 8, "ptr") ? StrGet(NumGet(v, 8, "ptr")) : ""
    DllCall "OleAut32\VariantClear", "ptr", v
    return val
}

ExplorerFileListFocused() {
    if !WinActive("ahk_class CabinetWClass")
        return false
    try return InStr(ControlGetClassNN(ControlGetFocus("A")), "DirectUIHWND") = 1
    return false
}
