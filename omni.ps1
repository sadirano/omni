#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [Alias("a")]
    [string]$Alias,
    
    [Alias("d")]
    [string]$Destination,
    
    [switch]$e,
    [switch]$n,
    [switch]$y,
    [switch]$sg,
    [switch]$sga,
    [switch]$ff,
    [switch]$f,
    [switch]$r,
    
    [Parameter(Position=1)]
    [Alias("x")]
    [string]$OptionExtras,

    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$ExtraArgs,
    
    [Alias("s")]
    [string]$Subdir,
    
    [switch]$Help
)

function Measure-Block {
    param(
        [string]$Name,
        [scriptblock]$Script
    )

    if (-not $Script:BenchmarkEnabled) {
        return & $Script
    }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        return & $Script
    }
    finally {
        $sw.Stop()
        Write-Host ("[BENCH] {0} took {1} ms" -f $Name, $sw.Elapsed.TotalMilliseconds)
    }
}

# ------------------------------------------------------------
# Initialization
# ------------------------------------------------------------
$script:omni = Join-Path $env:USERPROFILE ".omni"
$script:aliasFile = Join-Path $script:omni ".env"

# ------------------------------------------------------------
# Alias Management
# ------------------------------------------------------------
function Register-Alias {
    param([string]$Alias, [string]$Destination)

    Measure-Block "Register-Alias" {
        if (Test-Path $aliasFile) {
            $existingAliases = Get-Content $aliasFile
            if ($existingAliases -match "^$Alias=") {
                Write-Warning "Alias '$Alias' already exists. Updating destination."
                $existingAliases -replace "^$Alias=.*", "$Alias=$Destination" | Set-Content $aliasFile
            } else {
                "$Alias=$Destination" | Out-File -FilePath $aliasFile -Append
            }
        } else {
            "$Alias=$Destination" | Out-File -FilePath $aliasFile
        }
    }
}

function Resolve-Destination {
    param ([string]$Alias)

    Measure-Block "Resolve-Destination" {
        if (Test-Path $aliasFile) {
            foreach ($line in [System.IO.File]::ReadLines($aliasFile)) {
                if ($line.StartsWith("$Alias=")) {
                    return $line.Substring($Alias.Length + 1)
                }
            }
        }

        $destination = Read-Host "Destination"
        "$Alias=$destination" | Out-File -FilePath $aliasFile -Append
        return $destination
    }
}

function Search-Content {
    param(
        [string] $rg,
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Extras
    )

    $results = & $rg --ignore-case --color=always --line-number --no-heading @Extras |
        fzf --ansi --multi `
            --color 'hl:-1:underline,hl+:-1:underline:reverse' `
            --delimiter ':' `
            --preview "bat --color=always {1} --highlight-line {2}" `
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'

    if (-not $results) { return }

    $nvimArgs = @()

    foreach ($result in $results -split "`n") {

        # Safe split (file:line:content)
        $filePath, $lineNumber, $null = $result -split ":", 3

        if (-not $filePath -or -not $lineNumber) {
            Write-Warning "Skipping invalid line: $result"
            continue
        }

        switch ($env:EDITOR) {
            "nvim" {
                $nvimArgs += "+$lineNumber"
                $nvimArgs += "--"
                $nvimArgs += "$filePath"
            }
            "code" {
                code -g "$filePath`:$lineNumber"
            }
            default {
                nvim "+$lineNumber" -- "$filePath"
            }
        }
    }

    if ($env:EDITOR -eq "nvim" -and $nvimArgs.Count -gt 0) {
        nvim @nvimArgs
    }
}

function Search-Files {
    param([string]$query)

    Measure-Block "Search-Files" {
        $currentDir = (Get-Location).Path
        es -p -path $currentDir $query |
            fzf --bind "enter:become($env:EDITOR {}),ctrl-e:become(start explorer {})"
    }
}

function Perform-Action {
    param(
      [string]$effectiveOption, 
      [Parameter(ValueFromRemainingArguments = $true)]
      [string[]]$OptionExtras
    )

    Measure-Block "Perform-Action:$effectiveOption" {
        switch ($effectiveOption) {
            "e" { Start-Process explorer.exe -ArgumentList "." }
            "n" { & $env:EDITOR "." }
            "y" { (Get-Location).Path | Out-String | Set-Clipboard }
            "sg" { Search-Content rg $OptionExtras }
            "sga" { Search-Content rga $OptionExtras }
            "ff" { Search-Files $OptionExtras }
            "f" { & $env:EDITOR $OptionExtras }
            "r" { Start-Process $OptionExtras -ArgumentList $ExtraArgs }
            default { & cmd.exe }
        }
    }
}

# ------------------------------------------------------------
# Main Logic
# ------------------------------------------------------------
if (!$Alias) {
    & $env:EDITOR $aliasFile
    exit 0
}
else {
    $destination = Resolve-Destination -Alias $Alias

    if ($Subdir) {
        $destination = Join-Path $destination $Subdir
    }

    if (-not (Test-Path $destination)) {
        New-Item -ItemType Directory -Path $destination | Out-Null
    }

    Set-Location $destination

    if ($e) { $effectiveOption = "e" }
    elseif ($n) { $effectiveOption = "n" }
    elseif ($y) { $effectiveOption = "y" }
    elseif ($sg) { $effectiveOption = "sg" }
    elseif ($sga) { $effectiveOption = "sga" }
    elseif ($ff) { $effectiveOption = "ff" }
    elseif ($f) { $effectiveOption = "f" }
    elseif ($r) { $effectiveOption = "r" }
    else { $effectiveOption = "default" }

    Perform-Action -effectiveOption $effectiveOption -OptionExtras $OptionExtras
}
