# Console14

Prototype 14 is the active workbench for clarifying tone and X/Y language controls while keeping the Console13 industrial design mostly intact.

## Quick Links

- Baseline: [prototype.html](prototype.html)
- Static work: [prototype_resonance.html](prototype_resonance.html) / [GitHub](https://github.com/hyun-ilab/CONSOLE/blob/main/10_projects/console14/prototype_resonance.html)
- Backend experiment: [prototype_backend_experiment.html](prototype_backend_experiment.html) / [Netlify](https://console-demo.netlify.app/10_projects/console14/prototype_backend_experiment.html) / [Render API](https://console14-backend.onrender.com)
- Mobile selector: [mobile_prototypes.html](mobile_prototypes.html) / [Pages](https://hyun-ilab.github.io/CONSOLE/10_projects/console14/mobile_prototypes.html)
- Audits: [audit_resonance_build.ps1](audit_resonance_build.ps1), [audit_mobile_prototypes.ps1](audit_mobile_prototypes.ps1)
- Source/spec/tasks: [../console13/prototype.html](../console13/prototype.html), [SPEC.md](SPEC.md), [TASKS.md](TASKS.md)
- Local-only: reviewer/person notes and conversation logs.

## Prototype File Roles

| File | Role | Edit rule |
| --- | --- | --- |
| [prototype.html](prototype.html) | Preserved baseline copied from Console13. | Do not edit unless promotion is explicitly accepted. |
| [prototype_resonance.html](prototype_resonance.html) | Current static working build and promotion candidate. | Main target for static language, tone, X/Y, and visual tuning. |
| [prototype_backend_experiment.html](prototype_backend_experiment.html) | Backend experiment for Claude transform and ElevenLabs TTS. | Keep separate from the static mainline. |
| [mobile_prototypes.html](mobile_prototypes.html) | Selector for six one-handed mobile candidates. | Compare candidates only; not the final mobile choice. |
| `prototype_mobile_01_*.html` through `prototype_mobile_06_*.html` | Mobile UX candidates. | Fold one back only after explicit selection. |

## Current State

- Copied from Console13 on 2026-05-24.
- Console13 remains a source snapshot unless the user explicitly asks to change it.
- Run `.\10_projects\console14\audit_resonance_build.ps1` before promoting `prototype_resonance.html` over `prototype.html`.
- Backend route uses Render Claude first, `source: "echo"` fallback, and ElevenLabs `/tts`.
- Mobile selector opens the six candidates; no final mobile route is chosen yet.
- Product stance: Console14 is a relationship-pressure control tool (`관계 압력을 조절하는 도구`), not a generic sentence-polishing tool.
- Visual rule: keep the console body, LCD, dial, grid, and gauges recognizable.
- Content rule: sentences should demonstrate tone, formality/social distance, and directness/pressure.
