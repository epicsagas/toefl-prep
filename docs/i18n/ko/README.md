[English](../../README.md) | **[한국어](README.md)** | [日本語](../ja/README.md) | [简体中文](../zh-Hans/README.md) | [繁體中文](../zh-Hant/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Deutsch](../de/README.md) | [Português](../pt/README.md) | [Русский](../ru/README.md) | [Italiano](../it/README.md)

> 이 문서는 [README.md](../../README.md)의 번역입니다. 영문 버전이 권위 있는 원본이며 더 최신일 수 있습니다.

# toefl-prep

> TOEFL iBT 학습 플러그인 — **Claude Code · Codex · agy(Antigravity CLI)**. Reading/Listening/Speaking/Writing 4개 영역을 **로컬 LLM(Ollama) + whisper.cpp**로 완전 오프라인 평가한다.

문제 생성부터 채점, 점수 추적까지 외부 API 없이 내 컴퓨터에서 전부 처리한다. 학습 로드맵은 **사용자 커스텀** — 학습 기간·요일·시간대·주차별 목표를 직접 설정한다.

## 특징

- **완전 오프라인 채점** — 로컬 모델만 사용. API 비용/지연 없고 데이터가 기기 밖으로 나가지 않는다.
- **영역별 평가 경로**:
  - Reading/Listening — LLM 정답 검수 + 지문/스크립트 인용 근거
  - Writing — ETS 0–5점 루브릭 직접 채점 (내용/조직/언어/기계성)
  - Speaking — whisper.cpp 전사 → LLM 루브릭 (전달/언어사용/주제전개)
- **커스텀 로드맵** — `schedule.yaml`이 날짜·요일·시간·주차별 목표를 결정. 하드코딩된 값은 없다.
- **점수 추적** — 영역별 히스토리로 약점 진단 및 집중 드릴.
- **3사 호스트 지원** — Claude Code(슬래시 명령), Codex, agy(스크립트 구동 워크플로).

## 설치

### Claude Code

```bash
/plugin marketplace add epicsagas/toefl-prep
/plugin install toefl-prep@epicsagas
```

### Codex / agy

각 호스트의 플러그인 디렉토리에 clone:

```bash
git clone https://github.com/epicsagas/toefl-prep
# Codex: ~/.codex/plugins/toefl-prep -> clone
# agy:   ~/.agy/plugins/toefl-prep -> clone
```

## 사전 요구사항

```bash
# 1. Ollama (LLM 채점/문제 생성)
brew install ollama
ollama serve &
ollama pull qwen2.5:7b-instruct   # 추천 (M시리즈 16GB에서 영어 채점 최상)
# 폴백: ollama pull llama3.1:8b

# 2. whisper.cpp (스피킹 STT)
brew install whisper-cpp
mkdir -p ~/.local/share/whisper
curl -L https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin \
  -o ~/.local/share/whisper/ggml-base.en.bin

# 3. ffmpeg (오디오 정규화, 권장) + PyYAML (로드맵)
brew install ffmpeg
pip3 install pyyaml
```

스크립트가 모델을 자동 선택(qwen2.5:7b 우선, llama3.1:8b 폴백)하며, 미설치 시 설치 안내를 출력한다.

## 학습 일정 설정

최초 실행 시 템플릿에서 계획 생성:

```bash
VAULT="${TOEFL_VAULT_DIR:-$HOME/workspace/SecondBrain/01-Projects/toefl}"
cp skills/toefl/schedule.example.yaml "$VAULT/schedule.yaml"
# 편집: start_date, test_window_*, study_days, hours, target_score, weeks
```

로드맵에 표시되는 모든 값은 `schedule.yaml`에서 온다.

## 사용 (Claude Code)

| 명령 | 설명 |
|------|------|
| `/toefl-roadmap` | 이번 주 목표 + 오늘 계획 |
| `/toefl-practice [영역] [n]` | TOEFL 유형 문제 생성 |
| `/toefl-grade [영역] [파일]` | 답안/녹음 채점 → SCORES.md 누적 |
| `/toefl-drill [약점]` | 취약 영역 집중 반복 |
| `/toefl-status` | 진행률 + 점수 추이 + 목표 대비 갭 |

> Codex/agy는 SKILL.md의 의도→액션 매핑을 따라 동일한 스크립트를 직접 호출한다.

## 정직한 한계

- **스피킹 발음**: whisper.cpp 전사 품질은 발음의 *간접* 지표. 실제 억양/강세는 미평가.
- **로컬 LLM 채점**: 7–8B 모델은 ETS 공인 채점과 절대적 차이. 연습용 추정치 — 실전 베이스라인은 TPO로 검증.
- **리스닝 재생**: 오디오 재생은 사용자 책임. 플러그인은 스크립트+문제만 제공.

## 기여

[CONTRIBUTING.md](../../CONTRIBUTING.md) 참고. 영문 `README.md`가 진실 원천 — 번역이 영문을 앞설 수 없다.

## 라이선스

MIT
