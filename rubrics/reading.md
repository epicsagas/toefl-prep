# TOEFL Reading — Grading Rubric (ETS-aligned)

Used by `llm_eval.sh grade` as the system-prompt rubric. Reading is objective
(multiple choice), so the LLM's job is **answer checking + rationale**, not
holistic scoring. The score reflects accuracy across the item set.

## Task family

TOEFL iBT Reading: 2 passages, ~10 questions each. Question types:
- Factual information / Negative factual
- Inference & Rhetorical purpose
- Vocabulary in context
- Sentence simplification
- Insert text (sentence insertion)
- Prose summary (6-point, multi-select)
- Fill-in-a-table (completed categories)

## Scoring scale (per item set, 10 questions)

| Raw correct | Scaled (0–30 proxy) | Band     | Score (rubric 0–5) |
|-------------|---------------------|----------|--------------------|
| 9–10        | 28–30               | ADVANCED | 5                  |
| 7–8         | 22–27               | GOOD     | 4                  |
| 5–6         | 15–21               | FAIR     | 3                  |
| 3–4         | 9–14                | LOW      | 2                  |
| 1–2         | 4–8                 | (low)    | 1                  |
| 0           | 0–3                 | (none)   | 0                  |

## What the evaluator MUST produce

1. **Per-question verdict**: for each item, mark `correct`/`incorrect`/`partial`,
   the correct option, and a **one-line rationale** citing the exact sentence(s)
   in the passage that justify the answer.
2. **Error taxonomy**: classify each wrong answer by type:
   - `misread-detail` — missed a factual line
   - `over-inference` — went beyond the text
   - `vocab-context` — wrong word sense
   - `insertion-logic` — wrong cohesion point
   - `summary-weight` — picked minor vs. major idea
3. **Aggregate**: total correct / total, band, and the **top 2 weakness types** to drill.

## Dimensions (for the JSON `dimensions` object)

- `accuracy`: correct/total ratio (0–5 mapped as table above)
- `evidence_grounding`: how well rationales cite passage text (0–5)
- `weakness_concentration`: density of a single error type (higher = more drillable, 0–5)

## Honesty rule

If the provided answer key is uncertain or a question is ambiguous, mark it
`ambiguous` rather than forcing a verdict — do not inflate accuracy.
