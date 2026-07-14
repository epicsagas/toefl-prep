---
description: 이번 주 토플 학습 로드맵/과제 표시 — schedule.yaml에서 사용자가 지정한 학습 기간·요일·시간대·주차별 목표를 읽어 현재 날짜 기준으로 안내한다.
argument-hint: "[YYYY-MM-DD|week-N]"
allowed-tools: Bash, Read
disable-model-invocation: true
---

# /toefl-roadmap — 주차별 학습 로드맵 (사용자 커스텀 일정)

`schedule.yaml`에서 학습 계획을 읽어 현재 날짜에 맞는 주차/오늘의 스케줄/시험 D-day를 보여준다.
**날짜는 하드코딩되지 않는다** — 모두 사용자가 `schedule.yaml`에 설정한다.

## 스케줄 설정 (최초 1회)

`schedule.yaml`이 없으면 먼저 생성한다:
```bash
PLUGIN=~/.claude/plugins/marketplaces/toefl
VAULT="${TOEFL_VAULT_DIR:-$HOME/workspace/SecondBrain/01-Projects/toefl}"
[[ -f "$VAULT/schedule.yaml" ]] || cp "$PLUGIN/skills/toefl/schedule.example.yaml" "$VAULT/schedule.yaml"
```

사용자가 편집할 항목 (`schedule.yaml`):
- `start_date` / `end_date` — 학습 기간
- `test_window_start` / `test_window_end` — 시험 마지노선
- `reporting_deadline` — 성적 리포팅 마감
- `target_score` / `purpose` — 목표 점수·용도
- `study_days.weekdays` / `study_days.weekend` — 학습 요일 (원하는 요일만)
- `hours.weekday` / `hours.weekend` — 요일별 학습 시간
- `hours.weekday_window` / `hours.weekend_window` — 선호 시간대
- `weeks: []` — 주차별 focus + tasks (순서 = 주차 순서, start_date 기준 자동 정렬)

## 실행 단계

1. 인자 파싱:
   - 없음 → 오늘 날짜
   - `YYYY-MM-DD` → 해당 날짜
   - `week-N` → N주차 대표일(시작일 + (N-1)*7일)로 변환
2. `roadmap.sh all <date>` 실행:
   ```bash
   "$PLUGIN/scripts/roadmap.sh" all "$date"
   ```
3. `JOURNAL.md`가 있으면 이번 주 진행도(체크 항목 수)를 추가 표시.
4. 주차별 추천 명령 안내 (current_week.focus 기반):
   - 시스템 파악류 focus → `/toefl-practice reading 1` 베이스라인
   - 라이팅/리스닝 집중 focus → `/toefl-grade writing` 매일
   - 통합형/취약 focus → `/toefl-drill <weakness>`
   - 모의고사 focus → TPO + `/toefl-status`
5. 의존성 안내: `roadmap.sh`는 PyYAML 필요 — 없으면 `pip3 install pyyaml`.

## 정직성 원칙

- `schedule.yaml`에 정의되지 않은 주차/날짜는 "해당 없음"으로 표시, 추정하지 않는다.
- 시험일이 과거면 D-day를 음수로 표시하고 "시험일 경과" 경고.
- 목표 점수는 `schedule.yaml`의 값 그대로 표시 (기본값 가정 금지).
