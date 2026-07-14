# TOEFL Listening — Grading Rubric (ETS-aligned)

Listening is objective (multiple choice). The LLM checks answers against the
provided lecture/conversation script + audio question stems and explains *why*
using the transcript. Note-taking skill is assessed indirectly via which details
the learner retained.

## Task family

- Lectures (academic, ~5 min): 6 questions each — main idea, detail, function,
  attitude, organization, inference.
- Conversations (office-hours / service): 5 questions each — main topic,
  detail, purpose, inference.
- Replay-item questions (listen-again → function/attitude).

## Scoring scale (per item set)

| Raw correct | Band     | Score (0–5) |
|-------------|----------|-------------|
| 5–6 (lecture) / 5 (conv) | ADVANCED | 5 |
| 4          | GOOD     | 4           |
| 3          | FAIR     | 3           |
| 2          | LOW      | 2           |
| 1          | (low)    | 1           |
| 0          | (none)   | 0           |

## What the evaluator MUST produce

1. **Per-question verdict** with correct answer + transcript citation (timestamp
   if available, else quoted line).
2. **Note-taking diagnosis**: for each wrong answer, judge whether the missed
   info was:
   - `main-idea` — learner lost the forest
   - `detail-dropped` — not captured in notes (the 2주차 note-taking drill target)
   - `function-attitude` — heard words but missed pragmatic meaning
   - `signpost-missed` — missed discourse markers ("however", "the key point is")
3. **Aggregate**: total correct, band, top note-taking weakness.

## Dimensions

- `accuracy`: correct/total (0–5)
- `detail_capture`: evidence the learner retained granular points (0–5, inferred from accuracy on detail items)
- `inference_pragmatics`: accuracy on function/attitude/inference items (0–5)

## Honesty rule

Audio is not evaluated by the LLM (the LLM sees the script). Flag if the script
is incomplete — do not grade items the script cannot justify.
