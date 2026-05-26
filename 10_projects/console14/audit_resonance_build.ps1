param(
    [string]$ProjectRoot = $PSScriptRoot
)

$ErrorActionPreference = "Stop"

$project = (Resolve-Path -LiteralPath $ProjectRoot).Path
$workspace = (Resolve-Path -LiteralPath (Join-Path $project "..\..")).Path
$canonical = Join-Path $project "prototype.html"
$deprecatedRootCopy = Join-Path $project "prototype_resonance.html"
$archive = Join-Path $project "archive"
$historicalSnapshot = Join-Path $archive "prototype_2026-05-26_preserved_console13_snapshot.html"
$resonanceArchive = Join-Path $archive "prototype_resonance_2026-05-26_pre_promotion_copy.html"
$manifest = Join-Path $archive "prototype_manifest.sha256"
$readme = Join-Path $project "README.md"
$spec = Join-Path $project "SPEC.md"
$tasks = Join-Path $project "TASKS.md"
$rootReadme = Join-Path $workspace "README.md"
$projectsReadme = Join-Path $workspace "10_projects\README.md"

$rows = New-Object System.Collections.Generic.List[object]
$failures = New-Object System.Collections.Generic.List[string]

function Add-Check {
    param(
        [string]$Name,
        [bool]$Pass,
        [string]$Detail
    )

    $rows.Add([PSCustomObject]@{
        Check = $Name
        Status = if ($Pass) { "OK" } else { "FAIL" }
        Detail = $Detail
    }) | Out-Null

    if (-not $Pass) {
        $failures.Add("${Name}: ${Detail}") | Out-Null
    }
}

function Read-Utf8Text {
    param([string]$Path)
    $utf8Strict = [System.Text.UTF8Encoding]::new($false, $true)
    return $utf8Strict.GetString([System.IO.File]::ReadAllBytes($Path))
}

function Test-ContainsAll {
    param(
        [string]$Path,
        [string[]]$Needles
    )

    $text = Read-Utf8Text -Path $Path
    $missing = @($Needles | Where-Object { -not $text.Contains($_) })
    return [PSCustomObject]@{
        Pass = $missing.Count -eq 0
        Missing = $missing
    }
}

function Get-ManifestMap {
    param([string]$Path)

    $map = @{}
    foreach ($line in [System.IO.File]::ReadAllLines($Path)) {
        if ($line -match "^\s*([0-9a-fA-F]{64})\s+\*?(.+?)\s*$") {
            $map[$Matches[2]] = $Matches[1].ToLowerInvariant()
        }
    }
    return $map
}

function Test-ManifestHash {
    param(
        [hashtable]$Map,
        [string]$FilePath
    )

    $name = [System.IO.Path]::GetFileName($FilePath)
    if (-not $Map.ContainsKey($name)) {
        return [PSCustomObject]@{ Pass = $false; Detail = "manifest missing $name" }
    }

    $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $FilePath).Hash.ToLowerInvariant()
    $expected = $Map[$name]
    return [PSCustomObject]@{
        Pass = $actual -eq $expected
        Detail = "expected=$expected; actual=$actual"
    }
}

Add-Check "canonical prototype exists" (Test-Path -LiteralPath $canonical -PathType Leaf) "prototype.html is present"
Add-Check "deprecated root resonance copy absent" (-not (Test-Path -LiteralPath $deprecatedRootCopy)) "prototype_resonance.html should not remain as an active root file"
Add-Check "archive directory exists" (Test-Path -LiteralPath $archive -PathType Container) "archive directory is present"
Add-Check "historical snapshot exists" (Test-Path -LiteralPath $historicalSnapshot -PathType Leaf) "old prototype.html snapshot is archived"
Add-Check "pre-promotion copy archived" (Test-Path -LiteralPath $resonanceArchive -PathType Leaf) "pre-promotion resonance copy is archived"
Add-Check "archive manifest exists" (Test-Path -LiteralPath $manifest -PathType Leaf) "prototype_manifest.sha256 is present"

if ((Test-Path -LiteralPath $manifest -PathType Leaf) -and
    (Test-Path -LiteralPath $historicalSnapshot -PathType Leaf) -and
    (Test-Path -LiteralPath $resonanceArchive -PathType Leaf)) {
    $manifestMap = Get-ManifestMap -Path $manifest
    $historicalHash = Test-ManifestHash -Map $manifestMap -FilePath $historicalSnapshot
    Add-Check "historical snapshot hash protected" $historicalHash.Pass $historicalHash.Detail

    $resonanceHash = Test-ManifestHash -Map $manifestMap -FilePath $resonanceArchive
    Add-Check "pre-promotion copy hash protected" $resonanceHash.Pass $resonanceHash.Detail
}

if (Test-Path -LiteralPath $canonical -PathType Leaf) {
    $html = Read-Utf8Text -Path $canonical
    $requiredHooks = @(
        "Console14 role: canonical active static prototype",
        "reflection-panel",
        "data-scenario=`"email`"",
        "data-scenario=`"slack`"",
        "data-scenario=`"professor`"",
        "data-scenario=`"client`"",
        "data-scenario=`"friend`"",
        "id=`"customInput`"",
        "compareOriginal",
        "compareCurrent",
        "compareSofter",
        "compareDirect",
        "speechSynthesis",
        "auditSentences",
        "window.console14"
    )
    $missingHooks = @($requiredHooks | Where-Object { $html -notlike "*$_*" })
    Add-Check "canonical UI/function hooks" ($missingHooks.Count -eq 0) ("missing: " + ($missingHooks -join ", "))

    $oldBackendMarkers = @("BERT", "consoleBert", "localhost:8000", "Server not running")
    $foundOldMarkers = @($oldBackendMarkers | Where-Object { $html -like "*$_*" })
    Add-Check "canonical old backend markers absent" ($foundOldMarkers.Count -eq 0) ("found: " + ($foundOldMarkers -join ", "))

    if (Get-Command node -ErrorAction SilentlyContinue) {
        $nodeScript = @'
const fs = require("fs");
const file = process.argv[2];
const html = fs.readFileSync(file, "utf8");
const scripts = [...html.matchAll(/<script>([\s\S]*?)<\/script>/g)];
if (!scripts.length) throw new Error("script tag not found");
const script = scripts[scripts.length - 1][1];

class ClassList {
  constructor() { this.values = new Set(); }
  add(...items) { items.forEach((item) => this.values.add(item)); }
  remove(...items) { items.forEach((item) => this.values.delete(item)); }
  toggle(item, force) {
    if (force === undefined) {
      if (this.values.has(item)) { this.values.delete(item); return false; }
      this.values.add(item); return true;
    }
    if (force) this.values.add(item);
    else this.values.delete(item);
    return !!force;
  }
  contains(item) { return this.values.has(item); }
}

function makeElement(id = "") {
  return {
    id,
    children: [],
    dataset: {},
    className: "",
    textContent: "",
    value: "",
    style: { setProperty() {} },
    classList: new ClassList(),
    clientWidth: 1200,
    clientHeight: 400,
    scrollWidth: 0,
    scrollHeight: 0,
    addEventListener() {},
    appendChild(child) { this.children.push(child); return child; },
    setAttribute() {},
    setPointerCapture() {},
    getBoundingClientRect() { return { left: 0, top: 0, width: 220, height: 220 }; }
  };
}

const ids = [
  "dial", "dialGrid", "field", "sentence", "displayId", "speakButton",
  "voiceDot", "voiceStatus", "topTone", "topX", "topY", "fieldCurrent",
  "customInput", "toneDimension", "deltaLabel", "safetyLabel",
  "compareOriginal", "compareCurrent", "compareSofter", "compareDirect"
];
const elements = Object.fromEntries(ids.map((id) => [id, makeElement(id)]));
const scenarioButtons = ["email", "slack", "professor", "client", "friend"].map((scenario) => {
  const button = makeElement(`scenario-${scenario}`);
  button.dataset.scenario = scenario;
  return button;
});

global.window = {
  innerWidth: 1280,
  addEventListener() {},
  getComputedStyle() { return { fontSize: "28px" }; },
  speechSynthesis: { cancel() {}, speak() {} }
};
global.document = {
  documentElement: makeElement("root"),
  getElementById(id) { return elements[id] || makeElement(id); },
  querySelectorAll(selector) { return selector === ".scenario-button" ? scenarioButtons : []; },
  createElement(tag) { return makeElement(tag); }
};
global.requestAnimationFrame = (callback) => { callback(); return 0; };
global.cancelAnimationFrame = () => {};
global.SpeechSynthesisUtterance = function SpeechSynthesisUtterance(text) {
  this.text = text;
};

new Function(script)();
if (!window.console14 || typeof window.console14.auditSentences !== "function") {
  throw new Error("window.console14.auditSentences not exposed");
}

const result = window.console14.auditSentences();
const scenarioKeys = Object.keys(window.console14.scenarios || {});
const payload = {
  total: result.total,
  issueCount: result.issueCount,
  issues: result.issues,
  scenarioCount: scenarioKeys.length,
  scenarios: scenarioKeys
};
console.log(JSON.stringify(payload));

if (payload.total !== 30000 || payload.issueCount !== 0 || payload.scenarioCount !== 5) {
  process.exit(1);
}
'@
        $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("console14_promoted_static_audit_{0}.js" -f $PID)
        [System.IO.File]::WriteAllText($tmp, $nodeScript, [System.Text.UTF8Encoding]::new($false))
        try {
            $nodeOutput = & node $tmp $canonical 2>&1
            $nodeExit = $LASTEXITCODE
        } finally {
            Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
        }

        $json = ($nodeOutput | Select-Object -Last 1)
        try {
            $matrix = $json | ConvertFrom-Json
            $matrixPass = $nodeExit -eq 0 -and $matrix.total -eq 30000 -and $matrix.issueCount -eq 0 -and $matrix.scenarioCount -eq 5
            Add-Check "canonical sentence matrix audit" $matrixPass ("total=$($matrix.total); issues=$($matrix.issueCount); scenarios=$($matrix.scenarioCount)")
        } catch {
            Add-Check "canonical sentence matrix audit" $false ("could not parse node output: " + ($nodeOutput -join " "))
        }
    } else {
        Add-Check "canonical sentence matrix audit" $false "node is required for the reusable JavaScript audit"
    }
}

if (Test-Path -LiteralPath $historicalSnapshot -PathType Leaf) {
    $snapshotText = Read-Utf8Text -Path $historicalSnapshot
    $oldMarkers = @("BERT", "consoleBert", "localhost:8000", "Server not running")
    $missingOldMarkers = @($oldMarkers | Where-Object { $snapshotText -notlike "*$_*" })
    Add-Check "historical snapshot preserves old backend traces" ($missingOldMarkers.Count -eq 0) ("missing: " + ($missingOldMarkers -join ", "))
}

if (Test-Path -LiteralPath $readme -PathType Leaf) {
    $check = Test-ContainsAll -Path $readme -Needles @(
        '`prototype.html`: canonical active static prototype',
        'old BERT/local `consoleBert` traces',
        "The script name is legacy; it now audits the promoted canonical static prototype"
    )
    Add-Check "README canonical role" $check.Pass ("missing: " + ($check.Missing -join ", "))
}

if (Test-Path -LiteralPath $spec -PathType Leaf) {
    $check = Test-ContainsAll -Path $spec -Needles @(
        'Promoted static route: `prototype.html`.',
        'protected by `archive/prototype_manifest.sha256`.',
        'Do not recreate `prototype_resonance.html` as an active root file',
        "The six mobile files are UX-only layout candidates"
    )
    Add-Check "SPEC promoted governance" $check.Pass ("missing: " + ($check.Missing -join ", "))
}

if (Test-Path -LiteralPath $tasks -PathType Leaf) {
    $check = Test-ContainsAll -Path $tasks -Needles @(
        'Current prototype: `prototype.html` canonical active static prototype.',
        "Promote the resonance build into the canonical static prototype.",
        'target = canonical `prototype.html` plus archive snapshots.'
    )
    Add-Check "TASKS promoted route" $check.Pass ("missing: " + ($check.Missing -join ", "))
}

if (Test-Path -LiteralPath $rootReadme -PathType Leaf) {
    $check = Test-ContainsAll -Path $rootReadme -Needles @(
        "Console14 canonical static source: [10_projects/console14/prototype.html]",
        'It reflects `main`/Pages only after the promotion PR is merged.'
    )
    Add-Check "root README public/source split" $check.Pass ("missing: " + ($check.Missing -join ", "))
}

if (Test-Path -LiteralPath $projectsReadme -PathType Leaf) {
    $check = Test-ContainsAll -Path $projectsReadme -Needles @(
        'Canonical static source is `console14/prototype.html`',
        "The Netlify/Render path remains a backend experiment."
    )
    Add-Check "projects README public/source split" $check.Pass ("missing: " + ($check.Missing -join ", "))
}

$rows | Format-Table -AutoSize

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { "ERROR: $_" }
    exit 1
}
