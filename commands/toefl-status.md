---
description: 토플 학습 현황 요약 — JOURNAL.md/SCORES.md를 파싱하여 진행률, 영역별 점수 추이, 목표(90점) 대비 갭, 시험일까지 남은 일수를 표시한다.
argument-hint: "[week-number]"
allowed-tools: Bash, Read
disable-model-invocation: true
---

# /toefl-status — 학습 현황 대시보드

볼트 데이터를 읽어 진행 상황을 요약한다. LLM 채점을 수행하지 않는다(읽기 전용).

## 데이터 소스

```bash
VAULT="$HOME/workspace/SecondBrain/01-Projects/toefl"
JOURNAL="$VAULT/JOURNAL.md"
SCORES="$VAULT/SCORES.md"
PROGRESS="$VAULT/PROGRESS.md"
```

## 출력 항목

1. **시험일 카운트다운**:
   ```bash
   test_date="20260808"
   echo "D-$(( ( $(date -d 0808 +%s 2>/dev/null || date -j -f %m%d 0808 +%s) - $(date +%s) ) / 86400 )) to test window (8/8)"
   ```
2. **현재 주차 + 진행도**: `JOURNAL.md`에서 이번 주 학습일 수 카운트.
3. **영역별 최근 점수 + 추이** (`SCORES.md` 파싱):
   - 각 영역 최근 3회 점수를 0–30 환산.
   - 추이 화살표: 상승 ↑ / 하락 ↓ / 정지 →.
4. **목표 대비 갭**: 4영역 합산 추정 점수 vs 목표 90점.
   ```
   추정: R22 + L18 + S20 + W22 = 82 / 목표 90 → -8 (2점/영역 부족)
   ```
5. **최상 약점 2개**: 최근 채점에서 가장 낮은 dimension + 빈도 높은 오류 유형.
6. **다음 추천 액션**: 주차 + 약점 기반으로 `/toefl-drill`, `/toefl-practice` 안내.

## 빈 데이터 처리

- `SCORES.md`에 데이터가 없으면: "아직 채점 기록 없음 — `/toefl-practice` 후 `/toefl-grade`로 베이스라인 측정을 시작하세요."
- 거짓 데이터 생성 금지. 누락 영역은 "—"로 표시.

## 출력 형식

```
📊 TOEFL Status | 2026-07-25 | D-14 to test (8/8)

Week 2/4 — 진행 5/7일
영역별 추정 (최근 점수, 0–30):
  Reading    24 ↑  (was 20)
  Listening  19 ↑  (was 16)
  Speaking   18 →  (전사 기반 추정)
  Writing    22 ↑  (was 19)
  ─────────────────────
  합산 추정   83 / 목표 90  →  -7

최상 약점: Listening detail-dropped (3회 연속)
추천: /toefl-drill detail-dropped
```

## 정직성 원칙

- 추정 점수는 로컬 모델 기반이라 "추정" 표기를 항상 붙인다.
- 데이터가 부족해 통계가 무의미하면(예: 영역당 1회) "샘플 부족, 추이 참고용" 명시.
