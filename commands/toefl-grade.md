---
description: TOEFL 답안/녹음 채점 — 로컬 LLM(Ollama)과 whisper.cpp로 4개 영역을 채점하여 SCORES.md에 점수를 누적 기록한다.
argument-hint: "[reading|listening|speaking|writing] [answer-file-or-audio]"
allowed-tools: Bash, Read, Write, Edit
disable-model-invocation: true
---

# /toefl-grade — 답안/녹음 채점 (로컬 모델)

답안 텍스트 또는 녹음 파일을 로컬 모델로 채점한다. 결과는 `SCORES.md`에 누적.

## 사전 확인

```bash
PLUGIN=~/.claude/plugins/marketplaces/toefl/toefl-prep
curl -sf http://localhost:11434/api/tags >/dev/null || { echo "Run: ollama serve"; exit 1; }
EVAL="$PLUGIN/scripts/llm_eval.sh"
STT="$PLUGIN/scripts/stt_transcribe.sh"
RUB="$PLUGIN/rubrics"
```

## 영역별 채점 경로

### reading / listening (객관식)
- 입력: 답안 + (문제/정답키가 담긴 문제 파일).
- 루브릭: `$RUB/reading.md` 또는 `$RUB/listening.md`.
- 실행:
  ```bash
  "$EVAL" grade "$answer_file" "$RUB/reading.md" /tmp/toefl_grade.json
  ```
- 프롬프트에 "사용자 답안과 정답키를 비교하여 정답률과 오답별 근거/오류유형을 출력" 명시.

### writing (주관식)
- 입력: 에세이 텍스트 파일 (또는 `--inline`).
- 루브릭: `$RUB/writing.md`.
- 실행:
  ```bash
  "$EVAL" grade "$essay_file" "$RUB/writing.md" /tmp/toefl_grade.json
  ```
- LLM이 Content/Org/Language/Mechanics 0–5점 + 라인별 첨삭 반환.

### speaking (음성 → 전사 → 채점, 2단계)
1단계: whisper.cpp 전사
```bash
"$STT" "$audio_file" /tmp/toefl_transcript.txt
```
2단계: 전사 결과를 LLM에 평가
```bash
"$EVAL" grade /tmp/toefl_transcript.txt "$RUB/speaking.md" /tmp/toefl_grade.json
```
- 프롬프트에 "전사 텍스트 + 유창성 메트릭을 Delivery/Language Use/Topic Development 루브릭으로 평가" 명시.
- ⚠️ 결과 피드백에 **반드시** 한계 문구 포함 확인:
  "음성 직접 청취 없이 전사 기반 추정. 발음/억양/강세 미평가."

## 실행 단계

1. 영역 + 파일 파싱. 파일 미지정 시:
   - writing/speaking: 임시 파일에 사용자가 붙여넣은 텍스트/녹음 경로 안내.
   - reading/listening: 가장 최근 `practice/` 문제의 답안으로 간주.
2. 해당 영역 채점 스크립트 실행 (위 경로).
3. JSON 결과(`/tmp/toefl_grade.json`) 파싱:
   - `score`(0–5), `band`, `dimensions`, `feedback`, `evidence`.
4. `SCORES.md`에 행 추가 (날짜 / 영역 / 점수 / 밴드 / 모델명 / 메모):
   ```
   | 2026-07-22 | writing | 3.5 | FAIR | qwen2.5:7b-instruct | template 과용, Content 약함 |
   ```
5. `practice/`에 채점 결과 파일 저장: `YYYY-MM-DD-{section}-grade-{n}.md`
   (원문 + 점수 + 피드백 통합).
6. 점수를 0–30 환산표(speaking/writing: 0–5→0–30)로 변환하여 목표(90) 대비 갭 표시.

## 환산표 (0–5 → 0–30, Speaking/Writing)

| 0–5 | 0–30 |
|-----|------|
| 5   | 28–30 |
| 4   | 22–27 |
| 3   | 17–22 |
| 2   | 10–16 |
| 1   | 4–9 |
| 0   | 0–3 |

## 정직성 원칙

- 모델명 항상 기록 (점수 신뢰도 판단용).
- speaking 결과에는 한계 문구 강제.
- 점수가 비정상적으로 높거나 낮으면(예: writing 5점인데 단문) "재검토 권장" 플래그.
- 로컬 LLM 점수는 연습용 추정치 — TPO 실전 점수가 진짜 베이스라인.
