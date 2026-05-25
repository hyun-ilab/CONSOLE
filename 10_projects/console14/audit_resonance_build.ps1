param(
    [string]$ProjectRoot = $PSScriptRoot
)

$ErrorActionPreference = "Stop"

$project = (Resolve-Path -LiteralPath $ProjectRoot).Path
$workspace = (Resolve-Path -LiteralPath (Join-Path $project "..\..")).Path
$baseline = Join-Path $project "prototype.html"
$resonance = Join-Path $project "prototype_resonance.html"
$readme = Join-Path $project "README.md"
$spec = Join-Path $project "SPEC.md"
$tasks = Join-Path $project "TASKS.md"

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

Add-Check "baseline file exists" (Test-Path -LiteralPath $baseline) "prototype.html is present"
Add-Check "working copy exists" (Test-Path -LiteralPath $resonance) "prototype_resonance.html is present"

if (Test-Path -LiteralPath $baseline) {
    $relativeBaseline = "10_projects/console14/prototype.html"
    & git -C $workspace diff --quiet -- $relativeBaseline
    Add-Check "baseline unchanged in git diff" ($LASTEXITCODE -eq 0) "$relativeBaseline has no unstaged diff"
}

if (Test-Path -LiteralPath $readme) {
    $check = Test-ContainsAll -Path $readme -Needles @(
        "Resonance build copy",
        '`prototype.html` remains the preserved Console14 baseline'
    )
    Add-Check "README build routing" $check.Pass ("missing: " + ($check.Missing -join ", "))
}

if (Test-Path -LiteralPath $spec) {
    $check = Test-ContainsAll -Path $spec -Needles @(
        'Preserved baseline: `prototype.html`.',
        'Working build copy: `prototype_resonance.html`.',
        "Static-only route",
        "Voice route: browser Web Speech only",
        "## Build Governance",
        "## Verification Tiers"
    )
    Add-Check "SPEC governance" $check.Pass ("missing: " + ($check.Missing -join ", "))
}

if (Test-Path -LiteralPath $tasks) {
    $check = Test-ContainsAll -Path $tasks -Needles @(
        'Current prototype: `prototype.html` preserved baseline.',
        'Current working build copy: `prototype_resonance.html`.',
        'Decide whether to promote `prototype_resonance.html` over the preserved `prototype.html`.',
        "Run the resonance build audit gate before promotion."
    )
    Add-Check "TASKS promotion gate" $check.Pass ("missing: " + ($check.Missing -join ", "))
}

if (Test-Path -LiteralPath $resonance) {
    $html = Read-Utf8Text -Path $resonance
    $requiredHooks = @(
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
    Add-Check "resonance UI/function hooks" ($missingHooks.Count -eq 0) ("missing: " + ($missingHooks -join ", "))

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
        $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("console14_resonance_audit_{0}.js" -f $PID)
        [System.IO.File]::WriteAllText($tmp, $nodeScript, [System.Text.UTF8Encoding]::new($false))
        try {
            $nodeOutput = & node $tmp $resonance 2>&1
            $nodeExit = $LASTEXITCODE
        } finally {
            Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
        }

        $json = ($nodeOutput | Select-Object -Last 1)
        try {
            $matrix = $json | ConvertFrom-Json
            $matrixPass = $nodeExit -eq 0 -and $matrix.total -eq 30000 -and $matrix.issueCount -eq 0 -and $matrix.scenarioCount -eq 5
            Add-Check "sentence matrix audit" $matrixPass ("total=$($matrix.total); issues=$($matrix.issueCount); scenarios=$($matrix.scenarioCount)")
        } catch {
            Add-Check "sentence matrix audit" $false ("could not parse node output: " + ($nodeOutput -join " "))
        }
    } else {
        Add-Check "sentence matrix audit" $false "node is required for the reusable JavaScript audit"
    }
}

$rows | Format-Table -AutoSize

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { "ERROR: $_" }
    exit 1
}
