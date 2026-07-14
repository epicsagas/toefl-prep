# TOEFL Speaking — Grading Rubric (ETS-aligned, 0–4 → scaled)

The LLM grades from a **transcript** produced by `stt_transcribe.sh`
(whisper.cpp). This is a documented limitation: transcript clarity is an
*indirect* proxy for pronunciation. State this to the learner; never claim to
measure accent/prosody directly.

## Task family

- Task 1: Independent speaking (opinion, 45s prep / 45s speak)
- Task 2: Integrated — read announcement + listen → speak (campus)
- Task 3: Integrated — read passage + listen to lecture → speak (academic)
- Task 4: Integrated — listen to lecture → summarize + explain

## ETS scoring (0–4 per task), the rubric uses the same 0–4 then maps to 0–5

| Score | ETS descriptor (condensed) |
|-------|----------------------------|
| 4     | Fully addresses topic; well-developed, coherent, fluid; clear pronunciation; accurate, sophisticated grammar/vocab. |
| 3     | Generally good; mostly clear; minor lapses in fluency/grammar that don't obscure meaning. |
| 2     | Partially addresses; limited connection of ideas; intelligible but noticeable effort; frequent errors. |
| 1     | Minimal/unclear; hard to follow; severe delivery/language problems. |
| 0     | Off-topic, no response, or unintelligible. |

Map to 0–5 for the unified JSON schema: 4→5, 3→4, 2→3, 1→2, 0→0/1.

## Three dimensions (ETS triad)

1. **Delivery** (0–4): fluency, pacing, intelligibility.
   - From transcript: words_per_sec (target 2.0–2.6 = natural pace), long
     silences/hesitations visible as sparse segments, false starts shown by
     fragment repetition. *Pronunciation clarity inferred from transcription
     fidelity* — if whisper cleanly transcribed, the learner was intelligible;
     many gaps/garbles suggest low intelligibility.
2. **Language Use** (0–4): grammar + vocabulary range + automaticity.
   - From transcript: tense/subject-verb agreement, sentence variety,
     academic vocabulary, proportion of simple vs. complex clauses.
3. **Topic Development** (0–4): addresses prompt, logically structured,
   supported with reasons/examples (esp. integrated tasks: summary accuracy
   + synthesis of reading+listening).

## What the evaluator MUST produce

- Per-dimension score (0–4) with one specific transcript example each.
- **Synthesis score** (mean of three, rounded, mapped to 0–5).
- **Top 2 actionable fixes** (e.g., "reduce 'um'/false starts — you repeat
  the subject twice in seg 3", "add a contrastive marker like 'however'").
- For integrated tasks: a **content-accuracy check** (did the summary miss a
  key point from the lecture/reading?).

## Honesty rule (critical)

State explicitly in `feedback`:
- "이 점수는 음성을 직접 듣지 않고 **전사 텍스트** 기반 추정치입니다. 발음·억양·강세는 평가되지 않았습니다."
- Flag low-confidence transcription segments so the learner knows the
  transcript (not their speech) may be the problem.
