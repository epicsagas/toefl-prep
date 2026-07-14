# toefl-prep

> TOEFL iBT 4주 집중 학습 플러그인 — Claude Code · Codex · agy(Antigravity CLI) 지원.

Reading / Listening / Speaking / Writing 4개 영역을 **로컬 LLM(Ollama) + whisper.cpp**로 오프라인 평가한다. 외부 API 의존 없이 내 컴퓨터에서 문제 생성부터 채점, 점수 추적까지 전부 처리한다.

## 핵심 일정

| 항목 | 내용 |
|------|------|
| 학습 기간 | 2026-07-15 ~ 08-12 (4주, 평일 3h / 주말 8h) |
| 🚨 시험 마지노선 | 08-08 ~ 08-10 (Home Edition 또는 시험장) |
| 🎯 지원 마감 | 08-15 (Georgia Tech OMSCS 2027 Spring) |
| 목표 점수 | **90점** |

## 특징

- **완전 오프라인 평가**: 모든 채점을 로컬 모델로 수행. 외부 API 비용/지연 없음.
- **4개 영역 통합**: 각 영역 특성에 맞춘 평가 경로.
  - Reading/Listening — LLM 정답 검수 + 오답 근거(지문/스크립트 인용) 추출
  - Writing — ETS 0–5점 루브릭 직접 채점 (Content/Org/Language/Mechanics)
  - Speaking — whisper.cpp 전사 → LLM 루브릭 (Delivery/Language Use/Topic Development)
- **4주 로드맵**: 주차별 목표·체크리스트 자동 안내.
- **점수 추적**: 영역별 히스토리로 약점 진단 및 딥 드릴.

## 설치

### Claude Code

```bash
/plugin marketplace add epicsagas/toefl-prep
/plugin install toefl-prep@epicsagas
```

### Codex / agy(Antigravity)

repo를 clone 후 각 호스트의 플러그인 디렉토리로 심볼릭링크 또는 복사:
```bash
git clone https://github.com/epicsagas/toefl-prep
# Codex: ~/.codex/plugins/toefl-prep -> clone
# agy: ~/.agy/plugins/toefl-prep -> clone
```

## 사전 요구사항

```bash
# 1. Ollama (LLM 평가/문제 생성)
brew install ollama
ollama serve &
ollama pull qwen2.5:7b-instruct   # 추천 (M2 16GB 최적, ~4.7GB, 영어 채점 최상위)
# 또는 폴백: ollama pull llama3.1:8b

# 2. whisper.cpp (스피킹 STT)
brew install whisper-cpp
mkdir -p ~/.local/share/whisper
curl -L https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin \
  -o ~/.local/share/whisper/ggml-base.en.bin

# 3. ffmpeg (오디오 정규화, 권장)
brew install ffmpeg
```

스크립트가 모델을 자동 선택하지만(qwen2.5:7b 우선, llama3.1:8b 폴백), 미설치 시 설치 명령을 안내한다.

## 사용 (Claude Code)

| 명령 | 설명 |
|------|------|
| `/toefl-roadmap` | 현재 주차 학습 목표/과제 |
| `/toefl-practice [section] [n]` | TOEFL 유형 문제 생성 |
| `/toefl-grade [section] [file]` | 답안/녹음 채점 → SCORES.md 누적 |
| `/toefl-drill [weakness]` | 취약 영역 집중 반복 |
| `/toefl-status` | 진행률 + 점수 추이 + 목표 갭 |

> Codex/agy는 SKILL.md의 "의도 → 액션 매핑"을 따라 동일한 스크립트를 직접 호출한다.

## 데이터 저장

기본 `~/workspace/SecondBrain/01-Projects/toefl/` (환경변수 `TOEFL_VAULT_DIR`로 오버라이드).

## 한계 (정직성)

- **스피킹 발음**: whisper.cpp 전사 품질은 발음의 *간접* 지표. 실제 발음/억양/강세 미평가.
- **로컬 LLM 채점**: 7–8b급 모델은 ETS 공인 채점과 절대적 차이. 연습용 추정치 — 실전은 TPO로 검증.
- **리스닝 실전**: 오디오 재생은 사용자 환경 책임. 플러그인은 스크립트+문제만 제공.

## 구조

```
toefl-prep/
├── plugin.json                 # agy 직접 로드용
├── .claude-plugin/             # Claude Code (marketplace + plugin manifest)
├── .codex-plugin/              # Codex
├── skills/toefl/SKILL.md       # 권위적 워크플로 (모든 호스트 공유)
├── commands/                   # Claude Code 슬래시 명령 (5개)
├── scripts/                    # config.sh, llm_eval.sh, stt_transcribe.sh
├── rubrics/                    # reading/listening/speaking/writing (ETS 기반)
├── AGENTS.md                   # 3사 공통 에이전트 지침
└── README.{md,en.md}
```

## 라이선스

MIT
