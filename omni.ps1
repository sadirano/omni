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
    [switch]$ff,
    [switch]$f,
    [switch]$r,
    
    [Parameter(Position=1)]
    [Alias("x")]
    [string]$OptionExtras,
    
    [Alias("s")]
    [string]$Subdir,
    
    [switch]$Help
)

# Set up the omni directory and alias file
$omni = Join-Path $env:USERPROFILE ".omni"
if (-not (Test-Path $omni)) {
    New-Item -ItemType Directory -Path $omni | Out-Null
}
$aliasFile = Join-Path $omni ".env"

# Enforce single switch usage
$switchCount = ($e, $n, $y, $sg, $ff, $f, $r).Where({ $_ }).Count
if ($switchCount -gt 1) {
    Write-Error "Only one option switch can be specified at a time."
    exit 1
}

# Check for required external commands
$requiredCommands = @("nvim", "rg", "fzf")
foreach ($cmd in $requiredCommands) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Error "$cmd is not installed or not found in the PATH."
        exit 1
    }
}

# Function to register an alias
function Register-Alias {
    param([string]$Alias, [string]$Destination)
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


function Resolve-Destination {
    param ([string]$Alias)
    
    # Check if the alias file exists
    if (Test-Path $aliasFile) {
        $entries = Get-Content $aliasFile
        $entry = $entries | Where-Object { $_ -match "^$Alias=" }
        
        # If an exact match is found, return the destination
        if ($entry) {
            return $entry -replace "^$Alias=", ""
        } else {
            # No exact match, so find close matches
            $existingAliases = $entries | ForEach-Object { ($_ -split '=')[0] }
            $distances = @{}
            foreach ($existing in $existingAliases) {
                $distances[$existing] = Get-LevenshteinDistance $Alias $existing
            }
            
            # Get the top 3 closest matches
            $closest = $distances.GetEnumerator() | Sort-Object Value | Select-Object -First 3
            $suggestions = $closest | ForEach-Object { $_.Key }
            
            # Display the error and suggestions
            Write-Warning "No matching alias found for '$Alias'."
            if ($suggestions) {
                Write-Host "Did you mean one of these? $($suggestions -join ', ')"
            }
            
            # Pause for user input
            Read-Host "Press Enter to continue..."
            exit 1
        }
    } else {
        Write-Error "Alias file not found."
        Read-Host "Press Enter to continue..."
        exit 1
    }
}

function Get-LevenshteinDistance {
    param (
        [string]$str1,
        [string]$str2
    )
    $len1 = $str1.Length
    $len2 = $str2.Length

    # Initialize a jagged array
    $matrix = New-Object 'int[][]' ($len1 + 1)
    for ($i = 0; $i -le $len1; $i++) {
        $matrix[$i] = New-Object 'int[]' ($len2 + 1)
        $matrix[$i][0] = $i
    }
    for ($j = 0; $j -le $len2; $j++) {
        $matrix[0][$j] = $j
    }

    # Fill the matrix
    for ($i = 1; $i -le $len1; $i++) {
        for ($j = 1; $j -le $len2; $j++) {
            $cost = if ($str1[$i - 1] -eq $str2[$j - 1]) { 0 } else { 1 }
            $matrix[$i][$j] = [Math]::Min(
                [Math]::Min($matrix[$i - 1][$j] + 1, $matrix[$i][$j - 1] + 1),
                $matrix[$i - 1][$j - 1] + $cost
            )
        }
    }
    return $matrix[$len1][$len2]
}

function Search-Content {
  $result = rg --ignore-case --color=always --line-number --no-heading @Args |
    fzf --ansi `
    --color 'hl:-1:underline,hl+:-1:underline:reverse' `
    --delimiter ':' `
    --preview "bat --color=always {1} --highlight-line {2}" `
    --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'
  if ($result) {
    $parts = $result -split ':'
    for ($i = 0; $i -lt $parts.Length; $i++) {
      if ($parts[$i] -match '^\d+$') {
        $filePath = $parts[0..($i-1)] -join ':'
        $lineNumber = $parts[$i]
        break
      }
    }
    if ($filePath -and $lineNumber) {
      & ($env:EDITOR).Trim("`"'") $filePath +$lineNumber
    } else {
      Write-Error "Failed to parse file path and line number from: $result"
    }
  }
}

# Function to search files
function Search-Files {
    param([string]$query)
    $currentDir = (Get-Location).Path
    es -p -path $currentDir $query | fzf --bind 'enter:become(nvim {}),ctrl-e:become(start explorer {})'
}

# Function to perform the specified action
function Perform-Action {
    param([string]$effectiveOption, [string]$OptionExtras)
    switch ($effectiveOption) {
        "e" { Start-Process explorer.exe -ArgumentList "." }
        "n" { & nvim "." }
        "y" { (Get-Location).Path | Out-String | Set-Clipboard }
        "sg" { Search-Content $OptionExtras }
        "ff" { Search-Files $OptionExtras }
        "f" { & nvim $OptionExtras }
        "r" { Invoke-Expression $OptionExtras }
        default { & cmd.exe }
    }
}

# Main logic
if ($Help) {
    Get-Content "$PSScriptRoot\omni-help.md"
    exit
} elseif ($Alias -and $Destination) {
    Register-Alias -Alias $Alias -Destination $Destination
} else {
    $destination = Resolve-Destination -Alias $Alias
    if ($Subdir) {
        $destination = Join-Path $destination $Subdir
    }
    if (-not (Test-Path $destination)) {
        New-Item -ItemType Directory -Path $destination | Out-Null
    }
    Set-Location $destination

    # Determine effective option
    if ($e) { $effectiveOption = "e" }
    elseif ($n) { $effectiveOption = "n" }
    elseif ($y) { $effectiveOption = "y" }
    elseif ($sg) { $effectiveOption = "sg" }
    elseif ($ff) { $effectiveOption = "ff" }
    elseif ($f) { $effectiveOption = "f" }
    elseif ($r) { $effectiveOption = "r" }
    else { $effectiveOption = "default" }

    Perform-Action -effectiveOption $effectiveOption -OptionExtras $OptionExtras
}
