# Textbooks

This folder stores legally obtained textbook files and derived study materials.

## Folder Roles

- `00_inbox/`: Newly added files before they are sorted.
- `10_sources/`: Original source files only, such as `.pdf` and `.epub`. Treat as read-only.
- `15_source_text/`: Extracted original text from the source files in an LLM-friendly format. Do not summarize, translate, paraphrase, or rewrite.
- `20_converted_md/`: Markdown converted from PDFs or EPUBs.
- `30_notes/`: Study notes, topic explanations, comparison tables, and Korean summaries.
- `40_indexes/`: Catalogs, source maps, citation indexes, and reusable prompts.
- `90_archive/`: Deprecated conversions, old indexes, and superseded working files.

## Source Rule

Keep original PDFs and EPUBs unchanged in `10_sources/`. Put every derived artifact in `20_converted_md/`, `30_notes/`, or `40_indexes/`.

## Original Text Rule

For each source textbook, preserve extracted original text in `15_source_text/` before making summaries or study notes.

The `15_source_text/` version must be source-faithful:

- no summarization
- no translation
- no paraphrasing
- no concept-only extraction
- no deletion of sections because they seem unimportant
- preserve page markers, chapter/section headings, equations, tables, captions, footnotes, references, and figure mentions when extractable

Allowed cleanup is limited to extraction hygiene: fixing line-break artifacts, OCR spacing errors, page headers/footers only when they are repeated noise, and clearly marking unreadable or damaged regions.

## Citation Goal

Converted Markdown should preserve enough provenance for later answers:

- original file name
- book title and author/editor when known
- page marker or section/chapter marker
- conversion date
- conversion notes, especially OCR or layout issues
