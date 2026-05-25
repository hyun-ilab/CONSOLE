# Console14 - Active Prototype Tasks

## Setup

- Current prototype: 14
- Source copied from Console13 on 2026-05-24: `../console13/prototype.html`
- Goal: keep visual design mostly unchanged; rewrite sentence behavior and clarify tone/X/Y axes.

## Done

- [x] Create `10_projects/console14/` from `console13`.
- [x] Make `console14` the active project in root and project indexes.
- [x] Update prototype surface labels from Prototype 13 to Prototype 14.

## Next

- [x] Add small axis wording near the top readout or gauge area without redesigning the console.
- [x] Rewrite the sentence pools so the output demonstrates practical English tone transformation.
- [x] Keep tone dial behavior intact while making each tone family read clearly in the output.
- [x] Keep X/Y numeric readouts live and map X to formality/social distance and Y to directness/pressure.
- [x] Open the prototype in browser and verify dial, XY drag, text fit, and mobile layout.
- [x] Add X/Y attribute labels directly on the grid surface.
- [x] Audit all 60 tone-dial steps and remove repeated adjacent sentence states.
- [x] Stabilize the mobile top readout so fast dial/grid changes do not push the LCD.
- [x] Switch readout wrapping to deterministic grid rows and fixed numeric/text slots.
- [x] Separate narrow-mobile grid labels so axis text and current X/Y value do not overlap.
- [x] Tune narrow-mobile readout text so longest X/Y labels fit without clipping.
- [x] Give the narrow-mobile current grid value a small tag backing so the reticle cannot obscure it.
- [x] Define the product stance: a relationship-pressure control tool (`관계 압력을 조절하는 도구`), not a generic sentence-polishing tool.
- [ ] Tone family 지도 만들기: map the Console14 tone dial against explicit tone dimensions so users can see why each tone family behaves differently.
  TASK-NOTE: aliases = tone map, tone dimension table, dry/plain/warm 표, tone family map.
  TASK-NOTE: target = Console14 60-step tone dial in `prototype.html`.
  TASK-NOTE: role = source rule map for sentence generation and compact explanation UI.
  TASK-NOTE: links = tone dial chooses family; X axis is formality/social distance; Y axis is directness/pressure.
  TASK-NOTE: not = generic writing-style taxonomy; not a replacement for X/Y axes.
  TASK-NOTE: dimensions = vocabulary, sentence length, indirectness, pressure-handling, friendliness, rhythm, failure modes.
- [ ] Draft reusable sentence sets for email, Slack, professor, client, and close friend contexts.
- [ ] Add context presets such as email, Slack, professor, client, and close friend.
- [ ] Add a user-input mode that transforms a custom sentence through the current tone and X/Y settings.
- [ ] Draft before/after sample sets for original, current, softer, and more direct variants.
- [ ] Add a before/after comparison mode for original, current, softer, and more direct variants.
- [ ] Add a compact explanation layer that names what changed in the transformed sentence.
- [ ] Rework the mobile one-handed interaction path for stable thumb control of the dial, grid, and readouts.
- [ ] Build an automated audit for all 6,000 tone/X/Y sentence combinations.
- [ ] Write a Console14 English tone style guide that documents sentence-generation rules.
- [ ] Prepare a short usability test script and observation sheet for five quick testers.
- [ ] Define tone safety rules that separate clarity and firmness from manipulation or excessive pressure.
- [ ] Choose the top three prototype additions to implement first after the language rules are clearer.
