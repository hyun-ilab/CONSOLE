# AGENTS.md instructions for `C:\Users\jungg\Desktop\CONSOLE`

기본 작업 대상은 이 폴더의 로컬 파일과 프로젝트 문서다. 외부 서비스 작업은 사용자가 명시했을 때만 수행한다.

## Encoding

이 워크스페이스의 한글 `.md` / `.txt` 파일은 Windows PowerShell 기본 읽기에서도 깨지지 않도록 UTF-8 with BOM으로 저장한다.

- PowerShell에서 한글 파일을 읽을 때는 먼저 `Get-Content -Encoding UTF8` 또는 `[Text.Encoding]::UTF8.GetString([IO.File]::ReadAllBytes($path))`를 사용한다.
- 한글 파일이 깨져 보이면 파일 손상으로 판단하기 전에 BOM/디코딩 문제를 먼저 가정한다.
- 한글 `.md` / `.txt`를 새로 만들거나 크게 수정한 뒤에는 `tools/ensure_utf8_bom.ps1`로 UTF-8 BOM을 맞춘다.

## Guide File Budget

안내파일은 토큰 효율 5/10 수준으로 유지한다. 너무 압축해서 맥락을 잃지는 않되, README/AGENTS/MEMORY/INDEX류가 작업 기록 전체를 삼키지 않게 한다.

- 세부 기준은 `GUIDE_BUDGET.md`를 따른다.
- 안내파일에 긴 역사, 전문, 세부 연구, 오래된 예시를 누적하지 않는다.
- 안내파일이 예산을 넘으면 현재 지도, 활성 링크, 실수 방지 규칙만 남기고 나머지는 `10_projects/`, `30_logs/`, `50_library/`, `90_archive/` 중 맞는 곳으로 옮기거나 제거한다.
- 큰 문서 정리 뒤에는 `tools/check_guide_budgets.ps1`와 `tools/ensure_utf8_bom.ps1`를 실행한다.

## Routing and Task Hygiene

- 구조/라우팅/아카이브를 정리할 때는 영향을 받는 텍스트 파일을 제목이나 검색 결과만으로 판단하지 말고 전체 바이트를 읽는다. 검증은 `.\tools\audit_workspace_structure.ps1`를 우선 사용한다.
- `Select-Object -First`, `rg` 결과, 파일명 목록은 탐색 증거일 뿐 전체 읽기 증거가 아니다.
- 현재 할일을 찾을 때는 먼저 canonical command `rg --files -g TASKS.md 10_projects`만 실행한다. 필요할 때만 관련 `README.md`, `SPEC.md`, `30_logs/`, `50_library/`를 보조 근거로 연다.
- 프로토타입 파일이 여러 개인 프로젝트는 프로젝트 `README.md`에 파일 역할 표를 두고, HTML 상단 주석에도 preserved baseline / working build / experiment / candidate 여부를 짧게 적어 파일만 열어도 정식 여부를 오해하지 않게 한다.
- Markdown task checkbox syntax는 활성 프로젝트의 `TASKS.md`에서만 사용한다. 참고용 점검표는 `CHECK:` 같은 일반 bullet로 쓴다.
- 활성 프로젝트 `TASKS.md`의 체크박스 task 제목과 `TASK-NOTE:` 필드는 영어로 쓴다. 한국어는 사용자 원문이나 source wording을 짧게 인용해야 할 때만 둔다.
- Codex가 새 실행 할일을 만들거나 추상/프로토타입 할일을 구체화할 때는 relational task notes를 붙인다: `aliases`, `target`, `role`, `links`, `not` 중 최소 3개를 짧게 남겨 사용자의 다음 짧은 표현이 어느 artifact/부품을 가리키는지 다시 붙잡을 수 있게 한다.
- `TASK-NOTE:`는 task 아래 일반 bullet로 쓰고 checkbox를 늘리지 않는다. 안내파일에는 규칙 요약만 두고, 상세 연결관계는 해당 project `TASKS.md`나 `SPEC.md`에 둔다.
- 새 정보는 역할별로 보낸다: Active Project 실행 할일은 `10_projects/<slug>/TASKS.md`, Previous Source/archive 맥락은 해당 source 폴더의 archive 문서나 `90_archive/`, People Context는 `20_people/`, 대화 기록은 `30_logs/`, 참고자료와 재사용 프롬프트는 `50_library/`.
- 사용자가 나중에 쓸 프롬프트, 재사용 프롬프트, 작업 지시문을 요청하면 별도 지시가 없어도 `50_library/agent_prompts/user_cognitive_structure.md`를 함께 갱신한다. 사용자가 파일 수정을 금지한 경우만 예외다.
