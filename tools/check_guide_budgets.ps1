param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [switch]$Quiet
)

$utf8Strict = [System.Text.UTF8Encoding]::new($false, $true)

function Get-RuleForGuideFile {
    param([string]$RelativePath, [string]$Name)

    if ($RelativePath -eq "README.md") {
        return [PSCustomObject]@{ Rule = "root-readme"; MaxLines = 90; MaxChars = 4500 }
    }

    if ($Name -eq "README.md") {
        return [PSCustomObject]@{ Rule = "nested-readme"; MaxLines = 55; MaxChars = 3000 }
    }

    if ($Name -eq "AGENTS.md") {
        return [PSCustomObject]@{ Rule = "agents"; MaxLines = 90; MaxChars = 5000 }
    }

    if ($Name -eq "MEMORY.md") {
        return [PSCustomObject]@{ Rule = "memory"; MaxLines = 140; MaxChars = 7500 }
    }

    if ($Name -match "(?i)(GUIDE|INDEX|CATALOG|PROMPT|TEMPLATE|START_HERE|STATUS|DECISIONS).*\.md$") {
        return [PSCustomObject]@{ Rule = "guide-like"; MaxLines = 80; MaxChars = 5000 }
    }

    return $null
}

$rows = @()

$resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
$rootItem = Get-Item -LiteralPath $resolvedRoot -Force

if ($rootItem.PSIsContainer) {
    $basePath = $rootItem.FullName
    $targetFiles = Get-ChildItem -LiteralPath $rootItem.FullName -Recurse -File -Force
} else {
    $basePath = Split-Path -Parent $rootItem.FullName
    $targetFiles = @($rootItem)
}

$targetFiles |
    Where-Object {
        $_.Extension.ToLowerInvariant() -eq ".md" -and
        $_.FullName -notmatch "\\\.git\\" -and
        $_.FullName -notmatch "\\\.netlify\\"
    } |
    ForEach-Object {
        $relative = $_.FullName.Substring($basePath.Length).TrimStart("\", "/")
        $rule = Get-RuleForGuideFile -RelativePath $relative -Name $_.Name

        if ($null -eq $rule) {
            return
        }

        $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
        $text = $utf8Strict.GetString($bytes)
        $lineCount = ($text -split "`r?`n").Count
        $charCount = $text.Length
        $overLines = $lineCount -gt $rule.MaxLines
        $overChars = $charCount -gt $rule.MaxChars

        $rows += [PSCustomObject]@{
            Path = $relative
            Rule = $rule.Rule
            Lines = $lineCount
            MaxLines = $rule.MaxLines
            Chars = $charCount
            MaxChars = $rule.MaxChars
            Status = if ($overLines -or $overChars) { "OVER" } else { "OK" }
        }
    }

$rows = $rows | Sort-Object Status, Path

if (-not $Quiet) {
    $rows | Format-Table -AutoSize
}

if ($rows | Where-Object { $_.Status -eq "OVER" }) {
    exit 1
}
