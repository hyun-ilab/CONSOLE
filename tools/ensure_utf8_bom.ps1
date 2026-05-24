param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [switch]$CheckOnly
)

$utf8Bom = [System.Text.UTF8Encoding]::new($true)
$utf8Strict = [System.Text.UTF8Encoding]::new($false, $true)
$extensions = @(".md", ".txt")
$results = @()

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
        $extensions -contains $_.Extension.ToLowerInvariant() -and
        $_.FullName -notmatch "\\\.git\\"
    } |
    ForEach-Object {
        $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
        $hasBom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
        $text = $utf8Strict.GetString($bytes)

        if (-not $hasBom -and -not $CheckOnly) {
            [System.IO.File]::WriteAllText($_.FullName, $text, $utf8Bom)
            $hasBom = $true
        }

        $results += [PSCustomObject]@{
            Path = $_.FullName.Substring($basePath.Length).TrimStart("\", "/")
            Utf8Bom = $hasBom
            Bytes = (Get-Item -LiteralPath $_.FullName).Length
        }
    }

$results | Sort-Object Path | Format-Table -AutoSize

if ($CheckOnly -and ($results | Where-Object { -not $_.Utf8Bom })) {
    exit 1
}
