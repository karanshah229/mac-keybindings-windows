# Mac/Linux commands for PowerShell 7. Loaded from Shell.ps1.

# --- GNU tools from Git for Windows -------------------------------------
# The real tools with all their flags (tail -f, grep -r, find . -name ...).
# WSL's tools only work inside WSL, so they aren't on the Windows PATH.
# find and diff replace Windows' unrelated find.exe and PowerShell's
# Compare-Object alias.
$gitBin = "$env:ProgramFiles\Git\usr\bin"
foreach ($n in 'grep', 'head', 'tail', 'wc', 'less', 'sed', 'awk', 'cut', 'tr', 'uniq', 'column',
               'touch', 'du', 'df', 'file', 'basename', 'dirname', 'realpath', 'unzip', 'gzip',
               'md5sum', 'sha256sum', 'base64', 'env', 'date', 'diff') {
    if (Test-Path "$gitBin\$n.exe") { Set-Alias -Name $n -Value "$gitBin\$n.exe" -Force }
}
Remove-Variable gitBin, n

# xargs and find -exec start other commands, so the GNU tools go on PATH
# for that run only. Not for good: Windows' own find.exe and sort.exe, which
# scripts rely on, would lose to them.
function Invoke-GnuTool($name, $arguments, $pipeline) {
    $gitBin = "$env:ProgramFiles\Git\usr\bin"
    $path = $env:PATH
    $env:PATH = "$gitBin;$path"
    try {
        if ($null -ne $pipeline) { $pipeline | & "$gitBin\$name.exe" @arguments }
        else { & "$gitBin\$name.exe" @arguments }
    }
    finally { $env:PATH = $path }
}
function xargs { Invoke-GnuTool xargs $args $(if ($MyInvocation.ExpectingInput) { , @($input) }) }
function find { Invoke-GnuTool find $args $(if ($MyInvocation.ExpectingInput) { , @($input) }) }

# --- winget tools under their usual names --------------------------------
# wget: GNU wget2 (the winget wget package fails its checksum check).
# btop / top / htop: btop4win.
if (Get-Command wget2 -CommandType Application -ErrorAction SilentlyContinue) { Set-Alias -Name wget -Value wget2 }
if (Get-Command btop4win -CommandType Application -ErrorAction SilentlyContinue) {
    Set-Alias -Name btop -Value btop4win
    Set-Alias -Name top -Value btop4win
    Set-Alias -Name htop -Value btop4win
}

# --- rm / ls / kill: PowerShell's versions, plus Unix flags -------------
# They keep PowerShell's objects and icons, and also take the flags Mac
# habits reach for. Any PowerShell-style parameter (-Recurse, -Filter ...)
# is passed through unchanged.
foreach ($a in 'rm', 'ls', 'kill') { Remove-Item "Alias:$a" -Force -ErrorAction SilentlyContinue }
Remove-Variable a

# rm [-rfiv] path...   -r: folders too   -f: no error for missing paths
function rm {
    $recurse = $force = $confirm = $verbose = $false
    $paths = @()
    foreach ($a in $args) {
        if ("$a" -cmatch '^-[rRfiv]+$') {
            $recurse = $recurse -or "$a" -cmatch '[rR]'
            $force = $force -or "$a" -cmatch 'f'
            $confirm = $confirm -or "$a" -cmatch 'i'
            $verbose = $verbose -or "$a" -cmatch 'v'
        }
        elseif ("$a".StartsWith('-')) { if ($MyInvocation.ExpectingInput) { $input | Remove-Item @args } else { Remove-Item @args }; return }
        else { $paths += $a }
    }
    $flags = @{ Recurse = $recurse; Force = $force; Confirm = $confirm; Verbose = $verbose }
    if ($MyInvocation.ExpectingInput) { $input | Remove-Item @flags; return }
    foreach ($p in $paths) {
        if (-not (Test-Path $p)) {
            if (-not $force) { Write-Error "rm: cannot remove '$p': No such file or directory" }
        }
        elseif (-not $recurse -and (Test-Path $p -PathType Container)) {
            Write-Error "rm: cannot remove '$p': Is a directory"
        }
        else { Remove-Item $p @flags }
    }
}

# ls [-laAhR1tSr] [path...]   -a: hidden files   -R: subfolders
# -t: newest first   -S: largest first   -r: reverse the order
function ls {
    $gci = @{}
    $sort = $null
    $reverse = $false
    $rest = @()
    foreach ($a in $args) {
        if ("$a" -cmatch '^-[laAhR1tSr]+$') {
            if ("$a" -cmatch '[aA]') { $gci.Force = $true }
            if ("$a" -cmatch 'R') { $gci.Recurse = $true }
            if ("$a" -cmatch 't') { $sort = 'LastWriteTime' }
            if ("$a" -cmatch 'S') { $sort = 'Length' }
            if ("$a" -cmatch 'r') { $reverse = $true }
        }
        else { $rest += $a }
    }
    if ($sort) { Get-ChildItem @rest @gci | Sort-Object $sort -Descending:(-not $reverse) }
    elseif ($reverse) { Get-ChildItem @rest @gci | Sort-Object Name -Descending }
    else { Get-ChildItem @rest @gci }
}

# kill [-9] pid...   -9 (KILL): force   other signals just stop the process
function kill {
    $force = $false
    $ids = @()
    foreach ($a in $args) {
        if ("$a" -match '^-(9|KILL|SIGKILL)$') { $force = $true }
        elseif ("$a" -cmatch '^-(\d+|[A-Z]+)$') { }    # -15, -TERM, -SIGINT ...
        elseif ("$a" -match '^\d+$') { $ids += [int]"$a" }
        else { Stop-Process @args; return }
    }
    Stop-Process -Id $ids -Force:$force
}

# pkill [-9] pattern   stops processes whose name matches the pattern
function pkill {
    $force = $args -contains '-9'
    foreach ($p in $args | Where-Object { $_ -ne '-9' }) {
        Get-Process | Where-Object Name -Match $p | Stop-Process -Force:$force
    }
}

# --- Mac commands --------------------------------------------------------
# open [file | folder | url ...]   default app, Explorer or browser; no
# argument opens the current folder
function open {
    $targets = if ($args) { $args } else { @('.') }
    foreach ($t in $targets) {
        if (Test-Path "$t") { Invoke-Item "$t" } else { Start-Process "$t" }
    }
}

# ... | pbcopy   copies to the clipboard;   pbpaste   prints the clipboard
function pbcopy { $input | Set-Clipboard }
function pbpaste { Get-Clipboard }

# export NAME=value ...   unset NAME ...   (this session's environment)
function export {
    foreach ($a in $args) {
        $name, $value = "$a" -split '=', 2
        if ($null -ne $value) { Set-Item "env:$name" $value }
    }
}
function unset { foreach ($a in $args) { Remove-Item "env:$a" -ErrorAction SilentlyContinue } }

# which [-a] name...   the path of a program, or what an alias/function is
function which {
    $all = $args -contains '-a'
    foreach ($n in $args | Where-Object { $_ -ne '-a' }) {
        $found = @(Get-Command $n -All:$all -ErrorAction SilentlyContinue)
        if (-not $all) { $found = $found | Select-Object -First 1 }
        if (-not $found) { Write-Error "which: no $n" }
        foreach ($c in $found) {
            switch ($c.CommandType) {
                'Alias' { "${n}: aliased to $($c.Definition)" }
                'Application' { $c.Source }
                default { "${n}: PowerShell $("$($c.CommandType)".ToLower())" }
            }
        }
    }
}

# watch [-n seconds] command   re-runs the command until Ctrl+C
function watch {
    $interval = 2
    $words = @($args)
    if ("$($words[0])" -match '^-n(\d+(\.\d+)?)?$') {
        if ($Matches[1]) { $interval = [double]$Matches[1]; $words = $words[1..($words.Count - 1)] }
        else { $interval = [double]$words[1]; $words = $words[2..($words.Count - 1)] }
    }
    $command = $words -join ' '
    while ($true) {
        $output = Invoke-Expression $command 2>&1 | Out-String -Width $Host.UI.RawUI.WindowSize.Width
        Clear-Host
        "Every ${interval}s: $command    $(Get-Date -Format T)`n"
        $output
        Start-Sleep -Seconds $interval
    }
}

# ln [-sf] target [link]   -s: symbolic link   -f: replace an existing link
# Symbolic links need Developer Mode or an Administrator shell; without
# them, ln -s to a folder makes a junction instead, which needs neither.
function ln {
    $symbolic = $force = $false
    $rest = @()
    foreach ($a in $args) {
        if ("$a" -cmatch '^-[sfvn]+$') {
            $symbolic = $symbolic -or "$a" -cmatch 's'
            $force = $force -or "$a" -cmatch 'f'
        }
        else { $rest += "$a" }
    }
    $target = $rest[0]
    $link = if ($rest.Count -gt 1) { $rest[1] } else { Split-Path $target -Leaf }
    if (Test-Path $link -PathType Container) {
        if ($force -and (Get-Item $link).LinkType) { Remove-Item $link -Force }
        else { $link = Join-Path $link (Split-Path $target -Leaf) }
    }
    # Hard links and junctions need the target's full path; symbolic links
    # keep it as given, so a relative link stays relative.
    $fullTarget = (Resolve-Path $target -ErrorAction Stop).Path
    try {
        if ($symbolic) { New-Item -ItemType SymbolicLink -Path $link -Target $target -Force:$force -ErrorAction Stop | Out-Null }
        else { New-Item -ItemType HardLink -Path $link -Target $fullTarget -Force:$force -ErrorAction Stop | Out-Null }
    }
    catch {
        if ($symbolic -and (Test-Path $target -PathType Container)) {
            New-Item -ItemType Junction -Path $link -Target $fullTarget -Force:$force | Out-Null
        }
        elseif ($symbolic) {
            Write-Error "ln: symbolic links to files need Developer Mode (Settings > System > For developers) or an Administrator shell"
        }
        else { throw }
    }
}
