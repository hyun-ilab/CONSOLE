# Guide File Budget

Goal: token efficiency level 5/10. Keep enough context for a future Codex run to act correctly, but do not let guide files become project histories or source archives.

## Hard Budgets

- Root `README.md`: max 90 lines, max 4,500 characters.
- Nested `README.md`: max 55 lines, max 3,000 characters.
- `AGENTS.md`: max 90 lines, max 5,000 characters.
- `MEMORY.md`: max 140 lines, max 7,500 characters, max 50 active memory items.
- Other guide-like Markdown files such as `*GUIDE*.md`, `*INDEX*.md`, `*CATALOG*.md`, `*PROMPT*.md`, `*TEMPLATE*.md`, `*START_HERE*.md`, `STATUS.md`, `DECISIONS.md`: max 80 lines, max 5,000 characters.

## Keep In Guide Files

- Purpose of the folder or workflow.
- Current folder map.
- The few rules that prevent costly mistakes.
- Links to the current project hubs, logs, people, deployments, or library items.
- Maintenance commands.
- Routing rules that keep task discovery cheap, especially the rule that task checkbox syntax belongs only in active project `TASKS.md` files.

## Move Out Of Guide Files

- Full histories and transcripts go to `30_logs/` or `90_archive/`.
- Detailed research, reading notes, and source material go to `50_library/`.
- Project details go to `10_projects/<slug>/SPEC.md`, `TASKS.md`, or a scoped project note.
- Old links, stale examples, and duplicate explanations should be removed instead of preserved.
- Reference checklists should use normal bullets or `CHECK:` labels unless they are live project tasks.

## Maintenance Rule

Before adding substantial text to a guide file, run:

```powershell
.\tools\check_guide_budgets.ps1
```

If a guide file exceeds budget, shorten it in place first: keep the current map, active links, and mistake-prevention rules; move or delete the rest.
