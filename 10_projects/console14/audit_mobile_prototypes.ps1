param(
    [string]$Root = $PSScriptRoot
)

$ErrorActionPreference = "Stop"

$resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
$files = Get-ChildItem -LiteralPath $resolvedRoot -Filter "prototype_mobile_*.html" -File | Sort-Object Name
$sharedCss = Join-Path $resolvedRoot "mobile_onehanded_shared.css"
$sharedJs = Join-Path $resolvedRoot "mobile_onehanded_shared.js"
$selector = Join-Path $resolvedRoot "mobile_prototypes.html"
$readme = Join-Path $resolvedRoot "README.md"
$spec = Join-Path $resolvedRoot "SPEC.md"
$failures = @()

function Read-Utf8Text {
    param([string]$Path)
    $utf8Strict = [System.Text.UTF8Encoding]::new($false, $true)
    return $utf8Strict.GetString([System.IO.File]::ReadAllBytes($Path))
}

function Require-Text {
    param(
        [string]$Text,
        [string]$Needle,
        [string]$Label
    )
    if (-not $Text.Contains($Needle)) {
        $script:failures += "$Label missing $Needle"
    }
}

if (-not (Test-Path -LiteralPath $sharedCss -PathType Leaf)) {
    $failures += "Missing mobile_onehanded_shared.css"
}

if (-not (Test-Path -LiteralPath $sharedJs -PathType Leaf)) {
    $failures += "Missing mobile_onehanded_shared.js"
}

if ($files.Count -ne 6) {
    $failures += "Expected 6 prototype_mobile_*.html files, found $($files.Count)"
}

if (-not (Test-Path -LiteralPath $selector -PathType Leaf)) {
    $failures += "Missing mobile_prototypes.html selector"
}

foreach ($file in $files) {
    $text = Read-Utf8Text -Path $file.FullName
    $relative = $file.FullName.Substring($resolvedRoot.Length).TrimStart("\", "/")

    foreach ($needle in @(
        "mobile_onehanded_shared.css",
        "mobile_onehanded_shared.js",
        "CONSOLE_MOBILE_PROTOTYPE",
        "id=""sentence""",
        "id=""field""",
        "id=""toneRail""",
        "mobile_prototypes.html",
        "Console14 role: mobile UX-only layout candidate",
        "simplified sentence engine",
        "not final route or feature-equal to canonical prototype.html"
    )) {
        Require-Text -Text $text -Needle $needle -Label $relative
    }

    if ($text -match "file://|fonts\.googleapis|fonts\.gstatic|https?://") {
        $failures += "$relative contains a blocked or external browser dependency"
    }
}

if (Test-Path -LiteralPath $selector -PathType Leaf) {
    $selectorText = Read-Utf8Text -Path $selector
    foreach ($file in $files) {
        if ($selectorText -notlike "*$($file.Name)*") {
            $failures += "mobile_prototypes.html missing link to $($file.Name)"
        }
    }
    foreach ($needle in @(
        "Console14 role: mobile UX-only layout selector",
        "UX candidate",
        "simplified sentence engine",
        "canonical remains prototype.html",
        "selector is not the final route"
    )) {
        Require-Text -Text $selectorText -Needle $needle -Label "mobile_prototypes.html"
    }
}

$sharedText = ""
if (Test-Path -LiteralPath $sharedCss -PathType Leaf) {
    $sharedText += Read-Utf8Text -Path $sharedCss
}
if (Test-Path -LiteralPath $sharedJs -PathType Leaf) {
    $sharedText += Read-Utf8Text -Path $sharedJs
}

foreach ($needle in @("overflow-x: hidden")) {
    if ($sharedText -notlike "*$needle*") {
        $failures += "Shared mobile prototype assets missing structural guard: $needle"
    }
}

if (Test-Path -LiteralPath $readme -PathType Leaf) {
    $readmeText = Read-Utf8Text -Path $readme
    foreach ($needle in @(
        "six UX-only layout candidates",
        "simplified sentence engine",
        "not feature-equal to the canonical",
        'folded back into `prototype.html`'
    )) {
        Require-Text -Text $readmeText -Needle $needle -Label "README.md"
    }
} else {
    $failures += "Missing README.md mobile role context"
}

if (Test-Path -LiteralPath $spec -PathType Leaf) {
    $specText = Read-Utf8Text -Path $spec
    foreach ($needle in @(
        "tools/start_static_server.ps1",
        "DOM readiness",
        "audit_mobile_prototypes.ps1",
        "UX-only layout candidates using a simplified sentence engine",
        "not final mobile routes or feature-equal builds",
        'fold back into canonical `prototype.html`'
    )) {
        Require-Text -Text $specText -Needle $needle -Label "SPEC.md"
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
    RoleContext = "UX-only mobile candidates"
    SharedCss = (Test-Path -LiteralPath $sharedCss -PathType Leaf)
    SharedJs = (Test-Path -LiteralPath $sharedJs -PathType Leaf)
}
