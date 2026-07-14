---
description: 토플 학습 현황 요약 — schedule.yaml(D-day/목표점수) + JOURNAL.md/SCORES.md를 파싱하여 진행률, 영역별 점수 추이, 목표 대비 갭, 시험일까지 남은 일수를 표시한다.
argument-hint: ""
allowed-tools: Bash, Read
disable-model-invocation: true
---

# /toefl-status — 학습 현황 대시보드

볼트 데이터 + `schedule.yaml`을 읽어 진행 상황을 요약한다. LLM 채점을 수행하지 않는다(읽기 전용).

## 데이터 소스

```bash
VAULT="${TOEFL_VAULT_DIR:-$HOME/workspace/SecondBrain/01-Projects/toefl}"
JOURNAL="$VAULT/JOURNAL.md"
SCORES="$VAULT/SCORES.md"
PROGRESS="$VAULT/PROGRESS.md"
PLUGIN=~/.claude/plugins/marketplaces/toefl
```

## 출력 항목

1. **시험일 카운트다운 + 목표** (schedule.yaml 기반 — 하드코딩 없음):
   ```bash
   "$PLUGIN/scripts/roadmap.sh" dday       # D-day to test window
   "$PLUGIN/scripts/roadmap.sh" json | jq -r '.target_score, .week'
   ```
   D-day와 목표 점수는 `roadmap.sh`에서 schedule.yaml 값을 그대로 사용 — 하드코딩 금지.
   ```
2. **현재 주차 + 진행도**: `roadmap.sh week`로 주차, `JOURNAL.md`에서 이번 주 학습일 수 카운트.
3. **영역별 최근 점수 + 추이** (`SCORES.md` 파싱):
   - 각 영역 최근 3회 점수를 0–30 환산.
   - 추이 화살표: 상승 ↑ / 하락 ↓ / 정지 →.
4. **목표 대비 갭**: 4영역 합산 추정 점수 vs `schedule.yaml`의 `target_score`.
   ```
   추정: R22 + L18 + S20 + W22 = 82 / 목표 <target_score> → 갭
   ```
5. **최상 약점 2개**: 최근 채점에서 가장 낮은 dimension + 빈도 높은 오류 유형.
6. **다음 추천 액션**: 주차 + 약점 기반으로 `/toefl-drill`, `/toefl-practice` 안내.

## 빈 데이터 처리

- `SCORES.md`에 데이터가 없으면: "아직 채점 기록 없음 — `/toefl-practice` 후 `/toefl-grade`로 베이스라인 측정을 시작하세요."
- 거짓 데이터 생성 금지. 누락 영역은 "—"로 표시.

## 출력 형식 (예시 — 날짜/점수는 schedule.yaml 기반)

```
📊 TOEFL Status | <today> | D-<N> to test

Week <n> — 진행 <m>일
영역별 추정 (최근 점수, 0–30):
  Reading    24 ↑  (was 20)
  Listening  19 ↑  (was 16)
  Speaking   18 →  (전사 기반 추정)
  Writing    22 ↑  (was 19)
  ─────────────────────
  합산 추정   83 / 목표 <target_score>  →  <갭>

최상 약점: Listening detail-dropped (3회 연속)
추천: /toefl-drill detail-dropped
```

## 정직성 원칙

- 추정 점수는 로컬 모델 기반이라 "추정" 표기를 항상 붙인다.
- 데이터가 부족해 통계가 무의미하면(예: 영역당 1회) "샘플 부족, 추이 참고용" 명시.
