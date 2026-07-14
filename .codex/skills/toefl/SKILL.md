---
name: toefl
description: >
  TOEFL 집중 학습 도우미. 사용자가 "토플", "toefl", "스피킹 연습", "라이팅 채점",
  "리딩 문제", "리스닝", "모의고사", "점수 확인", "로드맵", "어떤 주차" 같은
  표현을 쓰거나 4주 토플 학습 일정/Georgia Tech OMSCS 지원 준비와 관련된 요청을
  할 때 사용한다. Reading/Listening/Speaking/Writing 4개 영역을 로컬 모델
  (Ollama + whisper.cpp)로 오프라인 평가한다. 목표 점수 90, 시험 마지노선 8/8~8/10.
---

# TOEFL 학습 도우미 (toefl-prep)

4주 집중 로드맵(7/15–8/12) + 로컬 LLM 기반 문제 생성/채점 + whisper.cpp 스피킹 평가.
모든 채점은 **오프라인 로컬 모델**로 수행한다.

> **스크립트/루브릭 위치**: 평가 엔진은 플러그인 디렉토리 아래 `${CLAUDE_PLUGIN_ROOT}/scripts/` (Ollama 래퍼, whisper.cpp 래퍼, 환경설정) 와 `${CLAUDE_PLUGIN_ROOT}/rubrics/` (4개 영역 루브릭) 에 있다. Claude Code는 `${CLAUDE_PLUGIN_ROOT}`, Codex/agy는 각 호스트의 플러그인 루트 변수로 치환한다. 변수를 모르면 먼저 스킬 디렉토리를 식별한 뒤 절대경로로 실행한다.
>
> **호스트별 워크플로**: Claude Code는 `commands/`의 슬래시 명령(`/toefl-roadmap` 등)을 직접 쓴다. Codex/agy는 아래 "의도 → 액션 매핑" 표를 따라 동일한 스크립트를 직접 호출한다 — 아래 각 영역별 명령 박스의 bash 블록이 호스트 중립적 진실 원천이다.

## 학습 일정 (사용자 커스텀)

날짜·요일·시간대·목표는 **하드코딩되지 않는다**. 모두 `${TOEFL_VAULT_DIR}/schedule.yaml`에서
사용자가 설정한다 (`skills/toefl/schedule.example.yaml`이 템플릿).

- `start_date` / `end_date` / `test_window_*` / `reporting_deadline` — 타임라인
- `study_days.weekdays` / `study_days.weekend` — 학습 요일 (원하는 요일만 나열)
- `hours.weekday` / `hours.weekend` / `*_window` — 요일별 시간·선호 시간대
- `target_score` / `purpose` — 목표 점수·용도
- `weeks: []` — 주차별 focus + tasks (start_date 기준 자동 정렬)

현재 주차/D-day/오늘 스케줄은 `scripts/roadmap.sh`가 계산:
```bash
scripts/roadmap.sh all [YYYY-MM-DD]   # 요약
scripts/roadmap.sh json               # {week, dday_test, today_hours, target_score, current_week...}
```
의존성: PyYAML (`pip3 install pyyaml`). schedule.yaml이 없으면 roadmap.sh가 설치 안내를 출력한다.

> 예시 기본값(Georgia Tech OMSCS 2027 Spring)이 템플릿에 들어있으나, 사용자가 자유롭게 변경한다.

## 의도 → 액션 매핑

| 사용자 의도 | 명령/스크립트 |
|-------------|---------------|
| "오늘 뭐 해야 돼", "로드맵", "몇 주차야" | `/toefl-roadmap` |
| "리딩 문제 만들어줘", "스피킹 연습", "문제 풀고 싶어" | `/toefl-practice [section] [count]` |
| "이 답안 채점해줘", "라이팅 채점", "녹음 평가해줘" | `/toefl-grade [section] [file]` |
| "취약점 집중", "딥 드릴" | `/toefl-drill [weakness]` |
| "점수 현황", "진행도", "지금 몇 점이야" | `/toefl-status` |

## 4개 영역 평가 전략 (로컬 모델 라우팅)

각 영역은 특성에 맞춰 다른 평가 경로를 사용한다. 핵심 스크립트:

- `scripts/llm_eval.sh grade <prompt> <rubric>` — Ollama 호출, JSON 점수 반환
- `scripts/stt_transcribe.sh <audio>` — whisper.cpp 전사 (스피킹 전용)
- `scripts/config.sh` — 모델 자동 선택 (qwen2.5:7b-instruct 우선, llama3.1:8b 폴백)

### Reading / Listening (객관식)
- 답안 + 정답키를 LLM에 전달 → 정답률 + 오답별 근거(지문/스크립트 인용) + 오류 유형 분류.
- 루브릭: `rubrics/reading.md`, `rubrics/listening.md`.
- 점수는 정답률 기반 (LLM이 점수를 임의 부여하지 않음).

### Writing (주관식)
- 에세이 텍스트 + 루브릭 → LLM이 ETS 0–5점 척도로 채점 (Content/Org/Language/Mechanics).
- 루브릭: `rubrics/writing.md`.
- 이 부분이 **로컬 LLM 평가 정확도가 가장 높음** (텍스트 in → 루브릭 out).

### Speaking (주관식 + 음성)
- **2단계 파이프라인**:
  1. `stt_transcribe.sh <녹음파일>` → 전사 텍스트 + 유창성 메트릭(words_per_sec 등)
  2. 전사 결과를 LLM에 전달 → Delivery/Language Use/Topic Development 루브릭 채점.
- 루브릭: `rubrics/speaking.md`.
- ⚠️ **한계 명시**: 전사 품질은 발음의 *간접* 지표. 실제 발음/억양/강세는 평가 불가.
  피드백에 반드시 "음성 직접 청취 없이 전사 기반 추정" 문구 포함.

## 모델 선택 로직 (config.sh `toefl_resolve_model`)

```
우선순위: 사용자 강제 지정 > qwen2.5:7b-instruct (설치 시) > llama3.1:8b (폴백)
```

M2 16GB 환경에서 qwen2.5:7b-instruct가 영어 채점 품질 최상위. 미설치 시:
```
ollama pull qwen2.5:7b-instruct   # ~4.7GB
```

## 데이터 저장 (SecondBrain 볼트)

모든 학습 데이터는 `01-Projects/toefl/`:
- `JOURNAL.md` — 일일 학습일지
- `SCORES.md` — 영역별 점수 히스토리 (자동 누적)
- `PROGRESS.md` — 주간 진행 + 약점 분석
- `practice/YYYY-MM-DD-{section}-{n}.md` — 생성 문제/답안/채점

프론트매터 규칙(AGENTS.md): `project: toefl`, `tags: [toefl, layer/raw, type/{doc-type}]`.

## 정직성 원칙

1. **로컬 모델 한계 인정**: 7–8b급 모델은 ETS 공인 채점과 절대적 차이 존재.
   보조 도구로 활용, 실전은 TPO로 검증 권장.
2. **스피킹 발음 한계**: 전사 기반 추정임을 매 결과에 명시.
3. **리스닝 실전**: 오디오 재생은 사용자 환경 책임. 플러그인은 스크립트+문제만 제공.
4. **템플릿 과용 패널티**: 라이팅에서 암기 템플릿이 얇은 내용을 덮으면 Content 점수 상한.

## 모의고사(TPO) 대비 메모

- 4주차에 TPO 3회 연속 응시 (화면 독해력/집중력 유지).
- 시험 직후 비공식 RC/LC 점수 즉시 확인.
- 이 플러그인의 점수는 **연습용 추정치** — TPO 실전 점수가 진짜 베이스라인.
