---
description: TOEFL 유형 문제 생성 — 로컬 LLM(Ollama)이 reading/listening/speaking/writing 영역의 실전형 문제를 생성하여 practice/에 저장한다.
argument-hint: "[reading|listening|speaking|writing] [count]"
allowed-tools: Bash, Read, Write
disable-model-invocation: true
---

# /toefl-practice — 문제 생성 (로컬 LLM)

지정 영역의 TOEFL 유형 문제를 로컬 LLM이 생성한다. 외부 API 미사용(오프라인).

## 사전 확인

1. Ollama 실행 + 모델 확인:
   ```bash
   PLUGIN=~/.claude/plugins/marketplaces/toefl/toefl-prep
   curl -sf http://localhost:11434/api/tags >/dev/null || { echo "Run: ollama serve"; exit 1; }
   ```
2. 스크립트 경로 변수:
   ```bash
   EVAL="$PLUGIN/scripts/llm_eval.sh"
   ```

## 영역별 생성 프롬프트

인자가 없으면 4개 영역 1세트씩 생성. `count` 기본 1.

### reading (RC)
- 생성 대상: 학술 지문(~700단어, 주제: 생물/역사/지질/예술 중 택) + 문항 3개
  (Factual 1, Inference 1, Vocabulary 1) + 정답키 + 근거 문장.
- 프롬프트 핵심: "Generate a TOEFL iBT Reading passage (~700 words) on
  [topic], then 3 questions (one factual, one inference, one vocabulary-in-
  context) each with 4 options, then an answer key citing the exact passage
  sentence for each. Output as markdown with sections: ## Passage, ##
  Questions, ## Answer Key."

### listening (LC)
- 생성 대상: 강의/대화 스크립트(~5분 분량) + 문항 3개 + 정답키.
- ⚠️ 오디오는 생성하지 않음 — 스크립트만 제공 (사용자가 직접 읽거나 TTS로 변환).
- 프롬프트 핵심: "Generate a TOEFL Listening lecture transcript (~800 words,
  academic) with 3 questions (main idea, detail, inference) + answer key
  citing transcript lines."

### speaking
- Task 1(Independent) 또는 Task 2–4(Integrated) 안내문 생성.
- 프롬프트 핵심: "Generate a TOEFL Speaking Task 1 prompt (opinion question)
  with 15s prep / 45s response instructions, plus a model 45s response and
  3 scoring notes per the ETS rubric."

### writing
- Integrated(읽기+듣기→요약) 또는 Academic Discussion 프롬프트 생성.
- 프롬프트 핵심: "Generate a TOEFL Academic Discussion Writing prompt:
  professor question + 2 student posts (~50 words each). Then provide a
  model response (~100 words) and 3 rubric-based scoring notes."

## 실행 단계

1. 영역/개수 파싱 (기본: 전체 1세트).
2. 각 영역별로:
   ```bash
   date=$(date +%Y-%m-%d)
   out="${TOEFL_DATA_DIR:-$HOME/Documents/toefl-prep}/practice/${date}-${section}-$(date +%H%M).md"
   mkdir -p "$(dirname "$out")"
   "$EVAL" gen --inline "<위 프롬프트>" "" "$out.gen"
   ```
   - `gen` 모드(temperature 0.7) 사용, 루브릭 불필요(빈 인자).
3. 생성 결과를 마크다운으로 정리하여 `practice/`에 저장:
   - 프론트매터: `project: toefl`, `tags: [toefl, layer/raw, type/spec]`.
   - 정답키는 `<details>` 접기로 분리 (풀고 나서 확인용).
4. `JOURNAL.md`에 "오늘 생성된 문제" 한 줄 추가.

## 정직성 원칙

- LLM 생성 문제는 실전 TOEFL과 유사하지만 **동일하지 않음**. 난이도 편차 존재.
- 정답키의 근거 문장이 지문에 실제로 없으면(할루시네이션) 생성 실패로 간주하고 재생성.
- 리스닝은 오디오 미제공 명시 → 사용자가 TTS(`say`/edge-tts)로 변환 권장.
