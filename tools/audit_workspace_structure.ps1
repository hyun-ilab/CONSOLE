param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"

$resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
$rootItem = Get-Item -LiteralPath $resolvedRoot -Force

if (-not $rootItem.PSIsContainer) {
    throw "Root must be a workspace directory, not a file: $resolvedRoot"
}

$utf8Strict = [System.Text.UTF8Encoding]::new($false, $true)
$sha256 = [System.Security.Cryptography.SHA256]::Create()
$textExtensions = @(".md", ".txt", ".html", ".ps1", ".py", ".json")
$errors = New-Object System.Collections.Generic.List[string]

function Get-RelativePath {
    param([string]$Path)
    return $Path.Substring($rootItem.FullName.Length).TrimStart("\", "/")
}

function Add-Error {
    param([string]$Message)
    $errors.Add($Message) | Out-Null
}

$textRows = Get-ChildItem -LiteralPath $rootItem.FullName -Recurse -File -Force |
    Where-Object {
        $textExtensions -contains $_.Extension.ToLowerInvariant() -or
        $_.Name -eq ".editorconfig"
    } |
    Sort-Object FullName |
    ForEach-Object {
        $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
        $text = $utf8Strict.GetString($bytes)
        $hash = [BitConverter]::ToString($sha256.ComputeHash($bytes)).Replace("-", "").ToLowerInvariant()

        [PSCustomObject]@{
            Path = Get-RelativePath -Path $_.FullName
            Bytes = $bytes.Length
            Lines = ($text -split "`r?`n").Count
            Sha256 = $hash.Substring(0, 16)
        }
    }

$taskFiles = @(
    Get-ChildItem -LiteralPath (Join-Path $rootItem.FullName "10_projects") -Recurse -Filter "TASKS.md" -File -Force |
        ForEach-Object { Get-RelativePath -Path $_.FullName }
)

if ($taskFiles.Count -ne 1 -or $taskFiles[0] -ne "10_projects\console14\TASKS.md") {
    Add-Error "Expected exactly one active TASKS.md at 10_projects\console14\TASKS.md; found: $($taskFiles -join ', ')"
}

$markdownFiles = Get-ChildItem -LiteralPath $rootItem.FullName -Recurse -Filter "*.md" -File -Force |
    Where-Object { $_.FullName -notmatch "\\\.git\\" }

foreach ($file in $markdownFiles) {
    $relative = Get-RelativePath -Path $file.FullName
    $text = $utf8Strict.GetString([System.IO.File]::ReadAllBytes($file.FullName))

    if ($relative -notlike "10_projects\console14\TASKS.md" -and $text -match "(?m)^\s*-\s+\[[ xX]\]") {
        Add-Error "Markdown task checkbox outside active TASKS.md: $relative"
    }

    if ($text -match "console13/TASKS\.md") {
        Add-Error "Stale Console13 TASKS.md link: $relative"
    }

    if ($text -match "10_projects/\*\*/TASKS\.md") {
        Add-Error "Stale wildcard TASKS.md instruction instead of canonical command: $relative"
    }

    if ($text -match "Copied from Console13 in this session") {
        Add-Error "Session-relative copy wording remains: $relative"
    }

    if ($text -match "Current project hub:\s*`10_projects/console13") {
        Add-Error "Console13 still marked current project hub: $relative"
    }

    if ($relative -like "10_projects\console13\*.md") {
        $firstLine = ($text -split "`r?`n", 2)[0]
        if ($firstLine -ne "> ARCHIVE ONLY - current tasks are in [../console14/TASKS.md](../console14/TASKS.md).") {
            Add-Error "Missing first-line archive banner: $relative"
        }
    }

    if ($relative -like "10_projects\console13\*.md" -and $text -match "(?m)^\s*-\s+OPEN:") {
        Add-Error "Archive file still has live-looking OPEN marker: $relative"
    }
}

$summary = [PSCustomObject]@{
    FullReadTextFiles = $textRows.Count
    FullReadBytes = ($textRows | Measure-Object -Property Bytes -Sum).Sum
    ActiveTaskFiles = ($taskFiles -join "; ")
    ErrorCount = $errors.Count
}

if (-not $Quiet) {
    $summary | Format-List
    if ($errors.Count -gt 0) {
        $errors | ForEach-Object { "ERROR: $_" }
    }
}

if ($errors.Count -gt 0) {
    exit 1
}
