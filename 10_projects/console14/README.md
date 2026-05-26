# Console14

Prototype 14 is the active workbench for clarifying the tone and X/Y language controls while keeping the Console13 visual design mostly intact.

## Quick Links

- Canonical static prototype: [prototype.html](prototype.html)
- Archived historical baseline: [archive/prototype_2026-05-26_preserved_console13_snapshot.html](archive/prototype_2026-05-26_preserved_console13_snapshot.html)
- Backend experiment/API: [prototype_backend_experiment.html](prototype_backend_experiment.html), [Netlify](https://console-demo.netlify.app/10_projects/console14/prototype_backend_experiment.html), [Render](https://console14-backend.onrender.com)
- Audits: [audit_resonance_build.ps1](audit_resonance_build.ps1), [audit_mobile_prototypes.ps1](audit_mobile_prototypes.ps1)
- Mobile selector: [mobile_prototypes.html](mobile_prototypes.html) / [Pages](https://hyun-ilab.github.io/CONSOLE/10_projects/console14/mobile_prototypes.html)
- Project docs: [SPEC.md](SPEC.md), [TASKS.md](TASKS.md), [../console13/prototype.html](../console13/prototype.html)
- Reviewer/person notes and conversation logs are local-only and not published to GitHub.

## Mobile One-Handed Prototypes

Open [mobile_prototypes.html](mobile_prototypes.html) to compare the six UX-only layout candidates. They use a simplified sentence engine, are not feature-equal to the canonical [prototype.html](prototype.html), and any selected mobile UX should be folded back into `prototype.html`.

## Prototype Roles

- `prototype.html`: canonical active static prototype and source of truth for the promoted resonance route.
- `archive/prototype_2026-05-26_preserved_console13_snapshot.html`: historical preserved Console13/early Console14 snapshot with old BERT/local `consoleBert` traces.
- `prototype_backend_experiment.html`: backend experiment only, using the Render API and provider fallback path.
- `mobile_prototypes.html` plus `prototype_mobile_01` through `prototype_mobile_06`: UX-only mobile layout candidates using a simplified sentence engine.

## Current State

- Copied from Console13 on 2026-05-24.
- `prototype_resonance.html` was promoted into `prototype.html` on 2026-05-26; the old `prototype.html` is archived and hash-protected.
- `prototype_backend_experiment.html` is public experiment routing, not the static source of truth.
- Run `.\10_projects\console14\audit_resonance_build.ps1` before treating the promoted static prototype as clean. The script name is legacy; it now audits the promoted canonical static prototype.
- Product stance: Console14 is a relationship-pressure control tool (`관계 압력을 조절하는 도구`), not a generic sentence-polishing tool.
- Keep the console body, LCD, dial, grid, and gauges recognizable while clarifying tone, formality/social distance, and directness/pressure.
