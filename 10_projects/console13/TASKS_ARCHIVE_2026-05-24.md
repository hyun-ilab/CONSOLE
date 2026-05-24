> ARCHIVE ONLY - current tasks are in [../console14/TASKS.md](../console14/TASKS.md).
> Copied from Console13 on 2026-05-24 into Console14; this file preserves the previous source task list.

# Console13 - Tasks from External Reviewer Feedback (2026-05-24)

## 연결

- Project hub: [README.md](README.md)
- Current tasks: [../console14/TASKS.md](../console14/TASKS.md)
- Spec: [SPEC.md](SPEC.md)
- Reviewer/person notes and conversation logs are local-only and not published to GitHub.

## 완료된 액션

- DONE: README에 프로젝트 목표를 짧게 쓰기: 문장, 음성, 톤, 좌표를 분리해 조절하고, 음성으로 반사된 의도를 확인하는 도구.
- DONE: 현재 Netlify 데모와 로컬 HTML prototype 경로를 README에 연결하기.

## 보관된 당시 미완료 액션

- ARCHIVED-ACTION: Console Prototype 13 GitHub repo 만들기.
- ARCHIVED-ACTION: Send the GitHub link to the early reviewer.
- ARCHIVED-ACTION: ElevenLabs와 Hugging Face TTS 모델을 비교해, 초기 음성 route 후보를 1-2개로 줄이기.
- ARCHIVED-ACTION: LLM/BERT zero-shot 텍스트 변형 route를 작은 예시 3개로 테스트하기.
- ARCHIVED-ACTION: Word embedding/언어 좌표 route는 프로젝트 소개용 설명으로만 짧은 실험 또는 다이어그램을 만들기. 실제 제품 기능에는 넣지 않는다.
- ARCHIVED-ACTION: 선형대수/최적화 기본 개념도 이해하기: 선형결합에서 노름, 코사인 유사도, 고유벡터/SVD/PCA, 손실함수/그래디언트/최적화로 이어지는 흐름을 말로 설명할 수 있게 정리하기.
  ```text
  선형결합
     ↓
  노름 (벡터 크기 정의)
     ↓
  코사인 유사도 (노름 + 내적)

  선형결합
     ↓
  고유벡터 ─→ SVD (일반화)
                  ↓
              차원축소 (PCA = SVD 기반)

  손실함수 (목적 정의)
     ↓
  그래디언트 (목적의 변화율)
     ↓
  최적화 (그래디언트로 손실 줄이기)
  ```
- ARCHIVED-ACTION: affective computing 키워드로 early reviewer의 이론 맥락과 연결되는 참고자료 3-5개 찾기. 특히 `정서 데이터 수집 -> 특징 처리 -> 학습/분류 -> 감정 예측 또는 반응` 흐름을 Console13의 `입력 문장/음성 -> 톤·좌표 특징 추출 -> LLM/BERT 또는 embedding route -> 변형문·TTS 반사` 흐름과 대응시켜 정리하기.
- ARCHIVED-ACTION: affective computing 관점에서 Console13을 "감정 인식"이 아니라 "의도/톤 조절과 반사" 프로젝트로 설명하는 1문단 framing 작성하기. 핵심 문장은 "사용자가 말의 정서적 방향을 조절하면 시스템이 그 조절값을 문장과 음성으로 되돌려 주어, 의도와 실제 수신 인상 사이의 차이를 확인하게 한다"로 잡기.
- ARCHIVED-ACTION: affective computing 파이프라인을 프로젝트 기능 단위로 풀어 작은 메모 작성하기: 정서 데이터 수집은 사용자의 원문·목표 톤·음성 피드백, 특징 처리는 정중함/친밀감/단호함/감정 강도 좌표화, 학습/분류는 zero-shot 변형 또는 embedding 후보 탐색, 감정 예측/반응은 변형문과 TTS로 되돌려 듣기.
- ARCHIVED-ACTION: 위 framing을 prototype 또는 README에 연결할 짧은 예시 1개 만들기: 원문 1개를 선택하고, 목표 톤 좌표를 바꾼 뒤, 변형문과 음성 확인 포인트를 함께 적어 "affective computing이 프로젝트에서 어떻게 작동하는지" 보이게 하기.
- ARCHIVED-ACTION: 현재 prototype의 x/y축은 `격식↔무례` 기준으로 일단 확정하고, 추후 UX 변경과 무관하게 현재 구현은 이 기준으로 진행하기.
- ARCHIVED-ACTION: 언어학 + affective computing을 공부한 뒤 UX 자체를 개편하기: polite, warm, firm, emotionally intense 같은 영어 UI 다이얼 축 3-4개를 재정의한다.
- ARCHIVED-ACTION: embedding 실험용 영어 문장 10개를 만들고, 각 문장의 좌표 이동 전/후 후보 표현을 표로 정리하기. 한국어는 제품 언어가 아니라 빌드 과정의 작업 언어로만 사용한다.
- ARCHIVED-ACTION: zero-shot 변형 예시 5개 작성하기: 원문, 목표 톤, 변형문, 바뀐 좌표값, 음성 확인 포인트를 함께 적기.
- ARCHIVED-ACTION: zero-shot 예시 중 1개를 prototype 화면 또는 README에 연결해 "입력 -> 좌표 조절 -> 변형문 -> TTS 반사" 흐름으로 보여주기.

## Early Reviewer에게 다시 물어볼 수 있는 질문

- 공부 중인 affective computing 이론에서 이 프로젝트와 가장 가까운 개념은 무엇인지.
- GitHub repo를 봤을 때 먼저 보고 싶은 부분이 UI인지, 모델 pipeline인지, 이론 framing인지.
- 음성 route는 ElevenLabs류 API를 먼저 붙이는 게 좋은지, 무료/open-source TTS로 가는 게 좋은지.

## 완료 기준

- GitHub 링크를 보냈다.
- repo README만 봐도 프로젝트 목표와 현재 prototype 상태가 이해된다.
- 다음 기술 route 후보가 최소 1개 이상 작동 예시로 정리되어 있다.
