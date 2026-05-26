# Console14 Final Deploy Prompt

```text
작업 폴더는 C:\Users\jungg\Desktop\CONSOLE 입니다.

목표: Console14 backend experiment를 Render backend + Netlify frontend로 공개 배포하고, 최종 빌드/브라우저 검증까지 끝낸다.

중요한 경계:
- 외부 서비스 직접 조작은 사용자가 명시 지시한 경우에만 한다.
- Render/Netlify tool 또는 plugin/connector가 있으면 우선 사용한다. 없으면 Dashboard 상태와 사용자가 제공한 URL을 기준으로 검증/가이드는 하되, 리소스를 직접 조작했다고 말하지 않는다.
- Netlify 기존 site/project가 있으면 새 site를 만들지 말고 기존 site를 우선한다. 새 site나 유료 리소스 생성이 필요하면 멈추고 확인을 받는다.
- prototype.html, prototype_resonance.html 수정 금지. backend 통합 대상은 10_projects/console14/prototype_backend_experiment.html 뿐이다.
- API key 값 출력/복사/커밋 금지. 존재 여부와 플랫폼 설정/작동 상태만 확인한다.
- ANTHROPIC_API_KEY와 ELEVENLABS_API_KEY는 사용자가 구매한 실제 키이며 Render Environment Group hyun.ben에 있어야 한다.
- Ben이 만든 Claude/Haiku route 의도를 임의로 바꾸지 않는다. 모델명/API 호출부 변경은 실제 오류 증거가 있을 때만 제안하고, 사용자 확인 없이 바꾸지 않는다.

먼저 읽을 파일:
- AGENTS.md, GUIDE_BUDGET.md
- 10_projects/console14/SPEC.md, TASKS.md, prototype_backend_experiment.html
- consoleBert/README.md, INTEGRATION_GUIDE.md
- consoleBert/server/README.md, main.py

현재 알려진 public backend URL:
- https://console14-backend.onrender.com

Render backend 검증:
- service Live 여부와 Environment Group hyun.ben attach 여부를 확인한다. key 값은 보지 말고 ANTHROPIC_API_KEY, ELEVENLABS_API_KEY present/connected 상태만 확인한다.
- endpoint: GET /, GET /docs, POST /transform with {"text":"Can you send the draft by Friday?","tone":"warm","x":4,"y":3}, POST /tts with {"text":"Please send the draft by Friday.","tone":"plain"}.
- /tts는 audio content-type/status만 확인한다. 오디오 파일이나 key 값은 출력하지 않는다.
- 실패하면 Render Logs의 마지막 의미 있는 줄로 원인을 분리한다: build dependency, start command, port binding, env group, provider API error, app exception.

Frontend 연결:
- 10_projects/console14/prototype_backend_experiment.html만 수정한다.
- public frontend에서는 localhost:8000, 127.0.0.1:8000을 쓰지 않는다.
- Render backend public URL은 meta tag 방식을 우선한다: <meta name="console14-backend-url" content="https://console14-backend.onrender.com">
- 기존 query parameter local route는 local testing용으로만 남길 수 있다.
- prototype.html과 prototype_resonance.html은 git diff로 미수정 확인한다.

Netlify 배포:
- 기존 Netlify site/project를 먼저 찾고, 새 site 생성이 필요하면 사용자 확인을 받는다.
- publish root는 repository root 기준으로 prototype_backend_experiment.html 경로가 그대로 접근 가능해야 한다.
- 배포 후 frontend public URL에서 /10_projects/console14/prototype_backend_experiment.html 이 열려야 한다.
- frontend status/readout이 Backend URL configured로 보이는지 확인한다.

브라우저 검증:
- desktop과 mobile viewport에서 public Netlify URL을 연다.
- custom input에 직접 문장을 넣고 TRANSFORM을 눌러 source claude/flan-t5/echo 중 하나가 안정적으로 표시되는지 확인한다. Claude 키가 작동하면 claude가 기대값이다.
- SPEAK를 눌러 /tts 호출을 확인한다. 실제 오디오 청취는 필요하면 수동 확인으로 남긴다.
- backend error 상태를 강제로 확인한다. 예: 임시로 잘못된 backend query URL을 붙여 열되 원본 파일은 오염시키지 않는다.
- TRANSFORM/SPEAK 실패 후 버튼 disabled 상태가 반드시 복구되는지 확인한다.
- console error, layout overlap, mobile text clipping을 확인한다.

수정/검증 후 문서 및 task 처리:
- 필요한 경우 10_projects/console14/TASKS.md에 이번 배포 검증 task를 영어 checkbox/task title 규칙에 맞게 갱신한다.
- 프롬프트나 재사용 지시문을 추가/수정했다면 50_library/agent_prompts/user_cognitive_structure.md도 짧게 갱신한다.
- 한글 .md/.txt를 새로 만들거나 크게 수정했으면 tools/ensure_utf8_bom.ps1를 실행한다.
- guide 파일을 크게 수정했으면 tools/check_guide_budgets.ps1도 실행한다.

마지막 보고 형식:
- 수정/배포한 파일
- prototype.html, prototype_resonance.html 미수정 확인
- Render backend URL, Netlify frontend URL
- env var 존재 여부만: ANTHROPIC_API_KEY present, ELEVENLABS_API_KEY present
- 검증 명령과 결과: /, /docs, /transform, /tts, desktop/mobile browser
- backend error 상태와 button disabled 복구 확인
- 남은 수동 확인 사항

중단 조건:
- Render backend public URL이 실제로 live가 아님
- backend service에 env group attach가 확인되지 않음
- 새 유료 리소스 생성 필요, API key 값 노출 위험
- backend public URL 없이 frontend만 배포되는 상황
- prototype.html 또는 prototype_resonance.html 수정 필요
```
