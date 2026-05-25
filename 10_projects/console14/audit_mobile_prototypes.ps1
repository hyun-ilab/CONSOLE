param(
    [string]$Root = $PSScriptRoot
)

$resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
$files = Get-ChildItem -LiteralPath $resolvedRoot -Filter "prototype_mobile_*.html" -File | Sort-Object Name
$sharedCss = Join-Path $resolvedRoot "mobile_onehanded_shared.css"
$sharedJs = Join-Path $resolvedRoot "mobile_onehanded_shared.js"
$spec = Join-Path $resolvedRoot "SPEC.md"
$failures = @()

if (-not (Test-Path -LiteralPath $sharedCss -PathType Leaf)) {
    $failures += "Missing mobile_onehanded_shared.css"
}

if (-not (Test-Path -LiteralPath $sharedJs -PathType Leaf)) {
    $failures += "Missing mobile_onehanded_shared.js"
}

if ($files.Count -ne 6) {
    $failures += "Expected 6 prototype_mobile_*.html files, found $($files.Count)"
}

foreach ($file in $files) {
    $text = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    $relative = $file.FullName.Substring($resolvedRoot.Length).TrimStart("\", "/")

    foreach ($needle in @(
        "mobile_onehanded_shared.css",
        "mobile_onehanded_shared.js",
        "CONSOLE_MOBILE_PROTOTYPE",
        "id=""sentence""",
        "id=""field""",
        "id=""toneRail"""
    )) {
        if ($text -notlike "*$needle*") {
            $failures += "$relative missing $needle"
        }
    }

    if ($text -match "file://|fonts\.googleapis|fonts\.gstatic|https?://") {
        $failures += "$relative contains a blocked or external browser dependency"
    }
}

$sharedText = ""
if (Test-Path -LiteralPath $sharedCss -PathType Leaf) {
    $sharedText += Get-Content -LiteralPath $sharedCss -Raw -Encoding UTF8
}
if (Test-Path -LiteralPath $sharedJs -PathType Leaf) {
    $sharedText += Get-Content -LiteralPath $sharedJs -Raw -Encoding UTF8
}

foreach ($needle in @("overflow-x: hidden")) {
    if ($sharedText -notlike "*$needle*") {
        $failures += "Shared mobile prototype assets missing structural guard: $needle"
    }
}

if (Test-Path -LiteralPath $spec -PathType Leaf) {
    $specText = Get-Content -LiteralPath $spec -Raw -Encoding UTF8
    foreach ($needle in @("tools/start_static_server.ps1", "DOM readiness", "audit_mobile_prototypes.ps1")) {
        if ($specText -notlike "*$needle*") {
            $failures += "SPEC.md missing browser QA rule: $needle"
        }
    }
} else {
    $failures += "Missing SPEC.md browser QA route"
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

[PSCustomObject]@{
    Status = "OK"
    PrototypeCount = $files.Count
    SharedCss = (Test-Path -LiteralPath $sharedCss -PathType Leaf)
    SharedJs = (Test-Path -LiteralPath $sharedJs -PathType Leaf)
}
