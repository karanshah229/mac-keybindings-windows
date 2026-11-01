# PowerShell side of MacKeys.ahk: readline-style line editing in Windows Terminal.
# Loaded from $PROFILE with:  . "$HOME\AutoHotkey\MacKeys.ps1"
if ($Host.Name -ne 'ConsoleHost') { return }

Set-PSReadLineKeyHandler -Chord Ctrl+a -Function BeginningOfLine
Set-PSReadLineKeyHandler -Chord Ctrl+e -Function EndOfLine
Set-PSReadLineKeyHandler -Chord Ctrl+k -Function KillLine
Set-PSReadLineKeyHandler -Chord Ctrl+u -Function BackwardKillLine
Set-PSReadLineKeyHandler -Chord Ctrl+w -Function BackwardKillWord

# Cmd+K: MacKeys.ahk sends Ctrl+F12 for Alt+K. Running Clear-Host as a command
# clears screen and scrollback and lets PowerShell redraw the prompt cleanly.
Set-PSReadLineKeyHandler -Chord Ctrl+F12 -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('Clear-Host')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}
# Keep those Clear-Host runs out of history; otherwise defer to the default
# handler (PowerShell 7 uses it to keep secrets out of saved history).
$defaultHistoryHandler = (Get-PSReadLineOption).AddToHistoryHandler
Set-PSReadLineOption -AddToHistoryHandler {
    param($line)
    if ($line -eq 'Clear-Host') { return $false }
    if ($defaultHistoryHandler) { return $defaultHistoryHandler.Invoke($line) }
    $true
}.GetNewClosure()
