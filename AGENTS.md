# AGENTS.md — toefl-prep plugin

> 공유 에이전트 가이드. Claude Code·Codex·agy 세 호스트가 모두 이 파일을 시스템 프롬프트로 로드한다.

## 역할

TOEFL iBT 4주 집중 학습 플러그인. Reading/Listening/Speaking/Writing 4개 영역을 **로컬 모델(Ollama + whisper.cpp)**로 오프라인 평가한다. 워크플로·루브릭·채점 전략·한계 규칙은 `skills/toefl/SKILL.md` 가 권위적 문서다. 사용자가 토플 관련 요청("토플", "스피킹 연습", "라이팅 채점", "리딩 문제", "모의고사", "어떤 주차", "점수 확인" 등)을 하면 그 스킬을 따른다.

## 의존성 (사전 설치 필요)

이 플러그인은 외부 CLI에 의존한다. **자동 설치 훅이 없으므로** 사용자가 사전에 설치해야 한다.

- **Ollama** (LLM 평가/문제 생성): `brew install ollama && ollama serve` + `ollama pull qwen2.5:7b-instruct` (추천, M2 16GB 최적) 또는 `ollama pull llama3.1:8b` (폴백).
- **whisper.cpp** (스피킹 STT): `brew install whisper-cpp` + 모델 다운로드:
  ```bash
  mkdir -p ~/.local/share/whisper
  curl -L https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin \
    -o ~/.local/share/whisper/ggml-base.en.bin
  ```
- **ffmpeg** (오디오 정규화, 권장): `brew install ffmpeg`
- **PyYAML** (로드맵 계산): `pip3 install pyyaml` — `scripts/roadmap.sh`가 schedule.yaml 파싱에 사용.

스크립트(`scripts/config.sh`)가 모델 자동 선택을 시도하지만, 미설치 시 사용자에게 설치 명령을 안내한다.

## 학습 일정 (사용자 커스텀)

날짜/요일/시간대/목표는 하드코딩되지 않는다. `${TOEFL_DATA_DIR}/schedule.yaml`이 단일 진실 원천이며,
`scripts/roadmap.sh`가 현재 주차·D-day·오늘 스케줄을 계산한다. 템플릿은 `skills/toefl/schedule.example.yaml`.
schedule.yaml이 없으면 roadmap.sh가 복사 안내를 출력한다.

## 스크립트/루브릭 경로

- 평가 스크립트: `${CLAUDE_PLUGIN_ROOT}/scripts/` 아래.
  - Claude Code → `${CLAUDE_PLUGIN_ROOT}`
  - Codex / agy → 각 호스트의 플러그인 루트 환경 변수로 치환. 변수를 모르면 스킬 디렉토리를 먼저 식별한 뒤 절대경로로 실행.
- 루브릭: `${CLAUDE_PLUGIN_ROOT}/rubrics/{reading,listening,speaking,writing}.md`.
- 데이터 저장: OS 문서 폴더 하위 `~/Documents/toefl-prep/` (macOS/Linux). 환경변수 `TOEFL_DATA_DIR`로 오버라이드 (레거시 `TOEFL_VAULT_DIR` 호환). 공개 레포이므로 로컬 경로를 하드코딩하지 않는다.
- **schedule.yaml 자동 생성 금지**: `roadmap.sh`는 schedule.yaml이 없으면 사용자에게 대화형으로 묻고 `Y`일 때만 템플릿을 복사한다. 자동으로 덮어쓰지 않는다.

## 호스트별 차이

- **Claude Code**: `commands/` (5개 슬래시 명령) + SKILL 모두 사용.
- **Codex / agy**: `commands/` 미지원 → SKILL.md의 "의도 → 액션 매핑" 표를 따라 동일한 워크플로를 스크립트 직접 호출로 수행.

## 윤리·정직성 (요약 — 전문은 SKILL.md)

- 로컬 LLM 점수는 **연습용 추정치**. ETS 공인 채점과 절대적 차이 존재. 실전은 TPO로 검증.
- 스피킹 발음 평가는 전사 품질이라는 **간접 지표**일 뿐. 발음/억양/강세는 미평가 — 결과에 명시.
- 채점 결과에 사용자 개인정보(주민번호·계좌 등)를 기록하지 않는다.
- 사용자가 제출한 답안/녹음은 로컬만 사용하고 외부 전송하지 않는다.
