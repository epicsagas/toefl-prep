---
description: 취약 영역 집중 반복 — SCORES.md에서 약점을 식별하여 해당 유형의 문제를 연속 생성/채점하는 딥 드릴 루프를 안내한다.
argument-hint: "[weakness-type|auto]"
allowed-tools: Bash, Read, Write
disable-model-invocation: true
---

# /toefl-drill — 취약 영역 집중 반복

`SCORES.md`/`PROGRESS.md`에서 약점을 식별하고, 해당 유형 문제를 집중 생성+채점한다.

## 약점 유형 분류

Reading: `misread-detail` | `over-inference` | `vocab-context` | `insertion-logic` | `summary-weight`
Listening: `main-idea` | `detail-dropped` | `function-attitude` | `signpost-missed`
Speaking: `delivery-fluency` | `delivery-pronunciation` | `language-grammar` | `language-vocab` | `development-structure`
Writing: `content-thin` | `org-disjointed` | `language-errors` | `template-overuse`

## 실행 단계

1. **약점 식별**:
   - 인자가 `auto` 또는 없으면 `SCORES.md`의 최근 5회 채점에서 가장 빈도 높은
     오류 유형/낮은 dimension을 추출.
   - 인자가 명시되면 해당 유형으로 직행.
2. **드릴 세트 생성**: 해당 약점을 겨냥한 문제 3개 생성.
   ```bash
   PLUGIN=~/.claude/plugins/marketplaces/toefl/toefl-prep
   EVAL="$PLUGIN/scripts/llm_eval.sh"
   ```
   - 예: `vocab-context` 약점 → "Generate 10 TOEFL vocabulary-in-context
     questions with 4 options each, heavy on academic polysemes. Include
     answer key + the sense used."
3. **즉시 채점**: 사용자가 답안을 제공하면 `/toefl-grade` 경로로 채점.
4. **개선 추적**: 드릴 전후 점수를 `PROGRESS.md`에 쌍으로 기록:
   ```
   | 2026-07-25 | vocab-context | drill 전 2/10 → drill 후 7/10 | +50% |
   ```
5. **루프 안내**: 개선 미미하면 동일 유형 +1세트, 충분하면 다음 약점으로 이동.

## 주차별 추천 약점 (로드맵 연동)

- 1주차: 템플릿 암기 단계 → 약점 식별보다 베이스라인 측정 중심.
- 2주차: `detail-dropped`(LC), `template-overuse`(W) 집중.
- 3주차: 통합형 약점(`development-structure` S, `content-thin` W) 집중.
- 4주차: TPO 결과 기반 최종 약점 정리.

## 정직성 원칙

- 단 1회 드릴 결과로 "극복" 판정 금지 (최소 2회 연속 개선 확인).
- 약점이 식별되지 않으면("모든 영역 균형") 범용 세트 생성하고 거짓 약점 만들지 않음.
