# Console14 - Prototype 14 Direction

## Source

- Copied from Console13 on 2026-05-24: `../console13/`
- Local prototype: [prototype.html](prototype.html)
- Previous spec: [../console13/SPEC.md](../console13/SPEC.md)

## Goal

Keep the tactile Console13 interface, but make the language controls legible. The user should understand that the dial changes tone family, while the X/Y field changes two sentence qualities and keeps live numeric readouts.

## Product Stance

Console14 is a relationship-pressure control tool (`관계 압력을 조절하는 도구`), not a tool for making English sound generically polished or stylish.

## Prototype 14 Scope

- Preserve the main industrial console design.
- Add only small explanatory UI around existing readouts if needed.
- Rewrite the output sentence system in English.
- Keep the dial as the tone-family control.
- Define X and Y in product language instead of leaving them as anonymous coordinates.

## Working Axis Labels

- Tone dial: style or attitude family, such as dry, plain, warm, firm, bright, or low.
- X axis: formality / social distance.
- Y axis: directness / pressure.

These labels are provisional. They should be visible enough for the prototype to teach the interaction, but not so heavy that they redesign the whole screen.

## Sentence Direction

The output should feel like a sentence transformed by tone and coordinate changes, not like unrelated fragments stitched together. Start from practical English request/response sentences and vary them across tone, X, and Y.

## Resonance Build Route

- Preserved baseline: `prototype.html`.
- Working build copy: `prototype_resonance.html`.
- Static-only route: local rule-based transforms; no backend, paid TTS API, model fine-tuning, or provider key.
- Tone family map keeps six families and adds dimensions: emotional resonance, clinical distance, pressure handling, rhythm, and failure boundary.
- Context presets: email, Slack, professor, client, and close friend.
- Custom sentence mode normalizes a short request locally and applies the current tone/X/Y state.
- Comparison strip: original, current, softer, and more direct.
- Voice route: browser Web Speech only for this build; rate, pitch, and rhythm are derived from tone and pressure.

## Build Governance

- Do not edit `prototype.html` for resonance work unless the user explicitly accepts promotion.
- Before any resonance edit, confirm the working target is `prototype_resonance.html`.
- Before promotion, run `.\10_projects\console14\audit_resonance_build.ps1` from the workspace root.
- Treat external TTS/provider research as a future-route note unless it changes the current static build.
- Mark a task complete only when the implementation or reusable verification artifact exists, not from a one-off observation alone.

## Verification Tiers

- Script audit: baseline diff, copy presence, required UI/function hooks, and the 30,000-state sentence matrix.
- Browser visual QA: desktop, mobile, detail zoom, interaction checks, and local console logs.
- Speech QA: Web Speech API path can be verified by state and call path; audible prosody still needs human listening.
- Promotion QA: browser evidence and script audit must both pass before replacing the preserved baseline.

## Local Browser QA Route

- Start local HTML checks through `tools/start_static_server.ps1`; open `http://127.0.0.1:<port>/...` in Browser instead of `file://`.
- Mobile prototype variants should keep browser-critical assets local. Avoid external font/CDN links in throwaway UX prototypes unless the external dependency itself is being tested.
- Browser automation should wait for DOM readiness, then inspect the target UI state. Do not make visual QA depend on full `load` completion when optional external assets could stall it.
- For the six mobile one-handed prototype files, run `.\10_projects\console14\audit_mobile_prototypes.ps1` after structural edits.

## Safety Boundary

- Firmness may clarify timing, priority, and next action.
- Resonance may add warmth and acknowledgement.
- The build should avoid guilt pressure, fake intimacy, coercion, and cold dismissal.

## Product Language

The UI, demo sentences, active task checkbox titles, and TASK-NOTE fields stay in English. Korean can remain in planning documents and internal notes, but not in the active TASKS.md task list unless quoting source wording is necessary.
