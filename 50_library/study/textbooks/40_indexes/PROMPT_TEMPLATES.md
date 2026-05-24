# Prompt Templates

## Add New Textbooks

Use this when adding legally obtained university-access textbooks.

```text
현재 폴더는 C:\Users\jungg\Desktop\CONSOLE 입니다.

내가 대학교 학생 신분으로 합법적으로 받은 아래 교재 파일들을
50_library/study/textbooks/ 체계에 실제로 추가해줘.

[추가할 파일 경로]
- C:\Users\jungg\Downloads\...

작업 전:
1. AGENTS.md, README.md, MEMORY.md, GUIDE_BUDGET.md와 textbook 관련 README/40_indexes 안내파일을 먼저 읽어.
2. 입력 파일의 존재, 확장자, 크기, 제목/저자/ISBN, PDF page count 또는 EPUB spine count를 확인해.
3. 기존 10_sources, 15_source_text, 20_converted_md, 40_indexes 항목 수를 기록해.

보존 규칙:
1. 원본 PDF/EPUB은 수정/삭제/이동하지 말고 10_sources/ 아래에 복사만 해.
2. 같은 파일명이 이미 있으면 SHA-256을 비교하고, 다르면 덮어쓰지 말고 멈춰.
3. 반드시 먼저 15_source_text/에 원문 보존본을 만들어. 요약, 번역, 의역, 개념정리, 생략은 금지야.
4. PDF는 <!-- pdf-page: N --> 및 ## [PDF page N] 마커를 유지해.
5. EPUB은 <!-- epub-spine: N; href: ... --> 및 가까운 장/절 제목을 유지해.
6. 수식, 표, 캡션, 각주, 참고문헌, 그림 언급은 가능한 한 보존하고, 읽을 수 없는 곳은 [unreadable: ...]로 표시해.
7. PDF는 15_source_text 검증 후 20_converted_md/에 원문 기반 읽기용 Markdown도 만들어. EPUB readable Markdown은 내가 요청할 때만 만들어도 돼.

색인 규칙:
1. 40_indexes의 TEXTBOOK_CATALOG, SOURCE_MAP, TOPIC_INDEX, HEADING_INDEX, TERM_INDEX, textbook_manifest.json, INGEST_VERIFICATION__YYYY-MM-DD.md를 갱신해.
2. tools/ingest_textbooks.py를 쓸 경우 새 파일만 기준으로 색인을 다시 써서 기존 교재 항목을 없애면 안 돼. 전체 기존 source + 새 source 기준으로 재생성하거나 안전하게 병합해.
3. 색인은 라우팅용으로 얇게 유지하고 GUIDE_BUDGET.md 예산을 넘기지 마.

검증 게이트:
1. 원본 복사본 SHA-256이 입력 파일과 같은지 확인.
2. 15_source_text 파일 존재, 크기, 원본 파일명/책 제목 포함 여부를 확인.
3. PDF marker 수가 page count와 같은지, EPUB marker 수가 spine count와 같은지 확인.
4. PDF readable Markdown을 만들었다면 marker 수가 page count와 같은지 확인.
5. 기존 catalog/source map 항목이 사라지지 않았는지 전후 개수를 비교.
6. 한글 .md/.txt를 만들거나 크게 수정했다면 tools/ensure_utf8_bom.ps1을 실행.
7. 안내파일을 고쳤다면 tools/check_guide_budgets.ps1도 실행.

마지막 답변에는 추가된 원본 경로, source_text 경로, converted_md 경로, marker count, unreadable count, 기존 색인 보존 여부를 표로 보고해. 원문 추출 품질이 낮으면 요약으로 대체하지 말고 실패 원인과 다음 조치만 보고하고 멈춰.
```

## Ask From Textbooks

Use this when asking Codex to answer from the local textbook corpus.

```text
50_library/study/textbooks/ 안의 교재 원본 텍스트, 변환본, 색인을 근거로 답해줘.

질문:
[여기에 질문]

답변 조건:
1. 먼저 40_indexes/를 보고 관련 교재를 찾고, 가능하면 15_source_text/의 원문 보존본을 1차 근거로 확인해.
2. 답은 한국어로 설명해.
3. 핵심 주장마다 출처를 붙여줘.
4. 긴 원문 복사는 피하고, 필요한 경우 짧은 인용만 사용해.
5. 교재들 사이의 관점 차이가 있으면 비교해서 말해줘.
6. 30_notes/의 요약노트만 보고 답하지 말고, 중요한 내용은 15_source_text/ 또는 20_converted_md/에서 다시 확인해.
7. 근거가 부족하면 부족하다고 말하고, 어떤 교재를 추가하면 좋을지도 제안해줘.
```

