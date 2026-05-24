> ARCHIVE ONLY - current tasks are in [../console14/TASKS.md](../console14/TASKS.md).
> Copied from Console13 on 2026-05-24 into Console14; this spec is Previous Source context.

# Console13 - Language/Tone/Coordinate Direction

## 출처

- 2026-05-24 early external-reviewer feedback on Console Prototype 13.
- 데모 URL: https://console-demo.netlify.app/
- Project hub: [README.md](README.md)
- 로컬 prototype: [prototype.html](prototype.html)
- 관련 사람/대화 로그는 local-only로 유지하고 public GitHub에는 올리지 않는다.

## 핵심 목표

문장, 음성, 톤, 좌표를 하나의 덩어리로 보지 않고 분리된 조절 단위로 다룬다. 사용자는 조절한 톤을 다시 음성으로 들으면서, 자신이 의도한 말의 방향이 실제로 어떻게 반사되는지 확인한다.

## 작업 가설

- 문장 레이어: 원문과 변형된 텍스트를 다룬다.
- 톤 레이어: 사용자가 조절하는 분위기, 정서, 태도, 강도 값을 다룬다.
- 좌표 레이어: 의미/정서 방향을 embedding 또는 유사한 벡터 공간으로 표현한다.
- 음성 레이어: 조절된 톤을 TTS로 출력해 사용자가 자기 의도를 다시 듣게 한다.
- UI 레이어: 조작감을 "semantics dial"처럼 느끼게 한다.
- 제품 언어: 실제 프로젝트 UI와 예시는 영어 중심으로 둔다. 한국어는 기획, 빌드, 내부 설명 과정에서만 사용한다.

## 후보 기술 route

### Route 1 - LLM/BERT 기반 텍스트 변형

- 입력: 원문 텍스트 + 원하는 분위기/톤.
- 처리: LLM 또는 BERT 계열 모델이 변형 방향을 예측.
- 출력: 조절된 텍스트.
- 초기 검증은 fine-tuning 없이 zero-shot inference로 시작할 수 있다.
- 이후 데이터가 쌓이면 fine-tuning route를 검토한다.

### Route 2 - Word embedding 기반 좌표 조작

- 단어/문장을 벡터로 표현한다.
- 사용자가 조절한 의미 또는 톤 방향을 벡터 연산으로 반영한다.
- 결과 벡터와 가까운 단어/문장 후보를 찾는다.
- 프로젝트의 "언어 좌표" 설명과 가장 직접적으로 연결된다.
- 단, 실제 제품 기능으로 넣지는 않는다. GitHub README, demo note, 발표/소개에서 아이디어를 설명하는 conceptual route로만 사용한다.

### Route 3 - TTS 기반 reflected intention

- 텍스트 또는 조절된 텍스트를 음성으로 출력한다.
- ElevenLabs 같은 상용 API와 Hugging Face의 무료/open-source TTS 모델을 비교한다.
- 핵심은 단순 낭독이 아니라, 사용자가 조절한 톤이 청각적으로 되돌아오는 경험이다.

## 다음 prototype에서 확인할 질문

- 사용자가 실제로 조절하는 축은 무엇인가: 정중함, 친밀감, 밝기, 단호함, 긴장도, 감정 강도 등.
- 좌표를 화면에 명시적으로 보여줄지, 아니면 내부 모델로만 둘지.
- 출력은 텍스트 변형이 먼저인지, 음성 반영이 먼저인지.
- 다이얼 조작이 의미를 바꾸는지, 톤만 바꾸는지, 둘 다 바꾸는지.
- 영어 제품으로 설계할 때, 한국어 작업 메모가 UX 문구나 예시 데이터에 섞이지 않게 할 방법은 무엇인가.
- 언어학과 affective computing을 더 공부한 뒤, 현재 grid/dial UX를 어떻게 재설계할 것인가.

## 보관된 당시 우선순위

1. GitHub repo와 README를 만들어 외부 협업자가 이해할 수 있게 만든다.
2. LLM zero-shot route를 작은 예시로 검증한다.
3. 음성 route 후보를 1-2개로 좁힌다.
4. embedding/coordinate framing을 짧은 diagram 또는 demo note로 설명한다.
