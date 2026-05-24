# CONSOLE Workspace

프로토타입, 배포, 사람 맥락, 대화 로그, 읽기자료를 얕고 프로젝트 중심으로 관리하는 작업 공간입니다.

## Root Map

- `00_inbox/`: 아직 프로젝트, 사람, 로그, 자료로 나누기 애매한 임시 캡처.
- `10_projects/`: 현재 진행 중인 프로젝트. 한 프로젝트는 짧은 영문 slug 폴더 하나를 가진다.
- `20_people/`: 사람별 맥락. 관계, 만난 경위, 톤, 운영 메모만 둔다.
- `30_logs/`: 날짜별 대화/이벤트 기록. 완료해야 할 일은 여기에 두지 않는다.
- `40_deployments/`: Netlify 등 배포 대상, 배포 설정, 배포 로그, 사이트 사본.
- `50_library/`: 공부자료, 디자인 원칙, Codex/LLM 읽기자료, 재사용 프롬프트.
- `90_archive/`: 비활성 프로젝트, 옛 구조, 더 이상 바로 쓰지 않는 스냅샷.

## Project Folder Rule

프로젝트 폴더는 가능한 한 얕게 유지합니다.

- `README.md`: 프로젝트 한 줄 목표, 현재 상태, 주요 링크.
- `SPEC.md`: 제품/기술 방향, 가설, 설계 메모.
- `TASKS.md`: 완료 조건이 분명한 다음 행동.
- `DECISIONS.md`: 반복해서 참조할 결정 사항이 많아질 때만 추가.
- `prototype.html`, `demo.html`처럼 현재 대표 파일은 프로젝트 루트에 둔다.
- 파일이 많아질 때만 `assets/`, `experiments/`, `reviews/`, `archive/`를 만든다.

## Naming

- 폴더명과 파일명은 영문 slug를 우선한다.
- 날짜가 필요한 로그/노트는 `YYYY-MM-DD__subject__topic.md` 형식을 쓴다.
- 사람이 아니라 프로젝트의 다음 행동이면 `10_projects/<project>/TASKS.md`에 둔다.
- 사람 맥락은 `20_people/`, 실제 대화 기록은 `30_logs/`, 지속 프로젝트 흐름은 `10_projects/`로 분리한다.

## Routing

- 현재 열린 할일의 1차 원천은 canonical command `rg --files -g TASKS.md 10_projects`로 찾는다.
- Markdown task checkbox syntax는 활성 프로젝트 `TASKS.md`에서만 사용하고, 라이브러리/가이드의 참고 점검표는 일반 bullet 또는 `CHECK:`로 쓴다.
- 프롬프트 요청이 있으면 재사용 가능한 형태를 `50_library/agent_prompts/`에도 반영한다.

## Encoding

- 한글이 들어간 `.md` / `.txt`는 UTF-8 with BOM으로 저장한다.
- PowerShell에서 읽을 때는 `Get-Content -Encoding UTF8`가 기본 안전 경로다.
- 필요하면 `tools/ensure_utf8_bom.ps1`을 실행해 현재 문서들의 BOM 상태를 한 번에 맞춘다.

## Guide Budgets

- 안내파일 분량 기준은 [GUIDE_BUDGET.md](GUIDE_BUDGET.md)를 따른다.
- 검사: `.\tools\check_guide_budgets.ps1`
- 구조/라우팅 감사: `.\tools\audit_workspace_structure.ps1`
- 정리 원칙: 현재 지도, 활성 링크, 실수 방지 규칙만 안내파일에 남긴다.

## Current Hubs

- Active Project: [Console14](10_projects/console14/README.md). Current tasks are discovered with `rg --files -g TASKS.md 10_projects`.
- Previous Source: [Console13](10_projects/console13/README.md). Archive only; copied from Console13 on 2026-05-24 into Console14.
- Local-only context: `20_people/` and `30_logs/` are intentionally ignored for public GitHub sharing.
