# PowerShell side of MacKeys.ahk: readline-style line editing in Windows Terminal.
# Loaded from $PROFILE with:  . "$HOME\AutoHotkey\MacKeys.ps1"
if ($Host.Name -ne 'ConsoleHost') { return }

Set-PSReadLineKeyHandler -Chord Ctrl+a -Function BeginningOfLine
Set-PSReadLineKeyHandler -Chord Ctrl+e -Function EndOfLine
Set-PSReadLineKeyHandler -Chord Ctrl+k -Function KillLine
Set-PSReadLineKeyHandler -Chord Ctrl+u -Function BackwardKillLine
Set-PSReadLineKeyHandler -Chord Ctrl+w -Function BackwardKillWord

# Cmd+A: MacKeys.ahk sends Ctrl+F11 for Alt+A. Selects the command line like a
# text field, so Backspace or typing replaces it.
Set-PSReadLineKeyHandler -Chord Ctrl+F11 -Function SelectAll
# Cmd+C (Ctrl+Shift+C) is Terminal's copy, which passes the key through when
# nothing is selected on screen: then copy the command-line selection, if any.
Set-PSReadLineKeyHandler -Chord Ctrl+Shift+c -ScriptBlock {
    $start = $length = 0
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$start, [ref]$length)
    if ($length -gt 0) { [Microsoft.PowerShell.PSConsoleReadLine]::Copy() }
}

# Cmd+K: MacKeys.ahk sends Ctrl+F12 for Alt+K. Clears screen and scrollback,
# then redraws the prompt on the top row with what you had typed still there.
# Passing the row to InvokePrompt resets PSReadLine's idea of where the prompt
# is, so it stays in sync with the cleared screen. UTF-8 output, as oh-my-posh
# uses for its own redraws, keeps the prompt's symbols intact.
Set-PSReadLineKeyHandler -Chord Ctrl+F12 -ScriptBlock {
    $esc = [char]27
    $encoding = [Console]::OutputEncoding
    try {
        [Console]::OutputEncoding = [Text.Encoding]::UTF8
        [Console]::Write("$esc[2J$esc[3J$esc[H")
        [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt($null, [Console]::CursorTop)
    }
    finally { [Console]::OutputEncoding = $encoding }
}
