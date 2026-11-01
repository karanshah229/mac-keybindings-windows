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
    if GetKeyState("Alt", "P")
        altTabOpen := true
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
!a::TermSend "^+a"         ; select all
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

; --- Chrome: Cmd+Shift+J = downloads -------------------------------------
#HotIf !altTabOpen && WinActive("ahk_exe chrome.exe")
!+j::Send "^j"

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

; --- Win + Alt: window management ----------------------------------------
#!Enter::Send "#{Up}"      ; maximize
#!Left::Send "#{Left}"     ; snap left
#!Right::Send "#{Right}"   ; snap right
#!Up::Send "#{Up}"         ; maximize
#!Down::Send "#{Down}"     ; restore / minimize
#!+Left::Send "#+{Left}"   ; move to monitor on the left
#!+Right::Send "#+{Right}" ; move to monitor on the right

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

ExplorerFileListFocused() {
    if !WinActive("ahk_class CabinetWClass")
        return false
    try return InStr(ControlGetClassNN(ControlGetFocus("A")), "DirectUIHWND") = 1
    return false
}
