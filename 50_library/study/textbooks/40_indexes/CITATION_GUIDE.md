# Citation Guide

Updated: 2026-05-24

Use this for answers grounded in the textbook corpus.

## PDF Sources

Format:

`Title, PDF page N, source_text path`

Example:

`Large Language Models: A Deep Dive, PDF page 303, 15_source_text/springer/KamathEtAl_LargeLanguageModelsADeepDive_978-3-031-65647-7__source_text.md`

PDF page markers come from `<!-- pdf-page: N -->` and the nearby `## [PDF page N]` marker. `20_converted_md/` can be used as the readable page-order copy for PDFs, but confirm important claims against the same marker in `15_source_text/` when possible.

## EPUB Sources

Format:

`Title, EPUB spine N, section heading, source_text path`

Example:

`Large Language Models, EPUB spine 021, 10.4 Retrieval-Augmented Generation, 15_source_text/springer/ZhaoEtAl_LargeLanguageModels_978-981-96-6259-3__source_text.md`

EPUB markers come from `<!-- epub-spine: N; href: ... -->` plus the nearest useful chapter or section heading.

## Quoting Rule

Prefer summary plus source. Use only short direct quotations when exact wording matters. Do not use `PROMPT_TEMPLATES.md` as evidence.

