# Projects

현재 살아 있는 프로젝트 허브입니다. 한 프로젝트는 하나의 짧은 영문 slug 폴더를 가집니다.

## Convention

- 프로젝트 루트에는 `README.md`, `SPEC.md`, `TASKS.md`처럼 바로 열어야 하는 문서를 둡니다.
- 현재 활성 할일은 canonical command `rg --files -g TASKS.md 10_projects`로 찾습니다.
- 대표 prototype이나 demo 파일은 처음에는 프로젝트 루트에 둡니다.
- 산출물이 많아지면 `assets/`, `experiments/`, `reviews/`, `archive/`를 프로젝트 안에 추가합니다.
- 사람별 맥락은 `../20_people/`, 날짜별 대화 기록은 `../30_logs/`에서 연결합니다.

## Active Project

- [console14](console14/README.md): Prototype 14 active workbench. Copied from Console13 on 2026-05-24; keep visual design mostly unchanged while rewriting sentence behavior and clarifying tone/X/Y axes.

## Previous Source

- [console13](console13/README.md): ARCHIVE ONLY. Current tasks are in [console14/TASKS.md](console14/TASKS.md).
