# Start Here

This is the public, sanitized entry point for using this repository with Codex or Claude Code.

## First Read

- Read [README.md](README.md) for the workspace map and routing rules.
- Read [AGENTS.md](AGENTS.md) for Codex and shared agent behavior.
- Read [CLAUDE.md](CLAUDE.md) when using Claude Code; it imports `AGENTS.md`.
- Open [10_projects/console14/README.md](10_projects/console14/README.md) for the active prototype.
- Open [10_projects/console14/TASKS.md](10_projects/console14/TASKS.md) for the current next actions.

## Agent Setup

- Codex: start from the repository root so `AGENTS.md` is loaded.
- Claude Code: start from the repository root so `CLAUDE.md` imports `AGENTS.md`.
- Public prototype: [https://hyun-ilab.github.io/CONSOLE/](https://hyun-ilab.github.io/CONSOLE/).
- The canonical active-task command is:

```powershell
rg --files -g TASKS.md 10_projects
```

## Good First Prompts

- "Inspect the active Console14 task list and recommend the smallest next implementation step."
- "Open the Console14 prototype and check whether the current task can be implemented without changing the industrial visual design."
- "Review `10_projects/console14/SPEC.md` and `TASKS.md`, then propose the next three prototype changes."
- "Before editing, confirm which files are in scope and which local-only folders must stay private."

## Privacy Boundaries

- `20_people/` and `30_logs/` are local-only and intentionally not published.
- `MEMORY.md`, private agent prompts, and private handoff notes are local-only.
- Do not reconstruct or summarize private people context or conversation logs from this public repository.
- Textbook indexes are public navigation aids; bundled source texts and converted full-text corpora are excluded.

## Verification Commands

Run these after structural or guide-file changes:

```powershell
.\tools\audit_workspace_structure.ps1
.\tools\check_guide_budgets.ps1
.\tools\ensure_utf8_bom.ps1
```
