#!/usr/bin/env bash
# roadmap.sh — compute current week, today's schedule, and D-day from schedule.yaml
#
# Usage:
#   roadmap.sh week [YYYY-MM-DD]      # current week number (0=before, N=after)
#   roadmap.sh today [YYYY-MM-DD]     # today's day-name + planned hours + window
#   roadmap.sh dday [YYYY-MM-DD]      # days until test_window_start
#   roadmap.sh all [YYYY-MM-DD]       # human-readable summary (default)
#   roadmap.sh json [YYYY-MM-DD]      # machine-readable JSON
#
# Reads ${TOEFL_DATA_DIR}/schedule.yaml (default: ~/Documents/toefl-prep).
# If missing, offers to scaffold one (interactive) or exits with a hint.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=config.sh
. "$SCRIPT_DIR/config.sh"

mkdir -p "$TOEFL_DATA_DIR"
SCHEDULE="${TOEFL_DATA_DIR}/schedule.yaml"
TEMPLATE="${SCRIPT_DIR}/../skills/toefl/schedule.example.yaml"

# If schedule.yaml is missing, offer to scaffold one interactively (when a TTY
# is available) or exit with a clear hint (non-interactive / CI).
if [[ ! -f "$SCHEDULE" ]]; then
  if [[ -t 0 ]]; then
    cat >&2 <<EOF
schedule.yaml not found at:
  $SCHEDULE

Default data dir: ~/Documents/toefl-prep (override with TOEFL_DATA_DIR).

Scaffold one now from the template? [Y/n]
EOF
    read -r answer </dev/tty
    if [[ "${answer:-Y}" =~ ^[Yy]?$ ]]; then
      cp "$TEMPLATE" "$SCHEDULE"
      echo "Created: $SCHEDULE" >&2
      echo "Edit it (start_date, test_window_*, study_days, hours, target_score, weeks), then re-run." >&2
      echo "Then open: \$EDITOR \"\$SCHEDULE\"" >&2
    else
      echo "Aborted. Create it manually: cp \"$TEMPLATE\" \"$SCHEDULE\"" >&2
    fi
    exit 2
  else
    cat >&2 <<EOF
ERROR: schedule.yaml not found at $SCHEDULE
Default data dir: ~/Documents/toefl-prep (override with TOEFL_DATA_DIR).
Create it:
  cp "$TEMPLATE" "$SCHEDULE"
Then set start_date, test_window_start, study_days, hours, and weekly goals.
EOF
    exit 2
  fi
fi

mode="${1:-all}"
when="${2:-$(date +%Y-%m-%d)}"

python3 - "$SCHEDULE" "$mode" "$when" <<'PYEOF'
import sys, datetime as dt

path, mode, when = sys.argv[1], sys.argv[2], sys.argv[3]

try:
    import yaml
    with open(path, encoding="utf-8") as fh:
        text = fh.read()
    # Strip optional YAML frontmatter (--- ... ---) so vault-tagged files parse cleanly.
    if text.lstrip().startswith("---"):
        end = text.find("\n---", 3)
        if end != -1:
            text = text[end + 4:]
    cfg = yaml.safe_load(text)
except ImportError:
    sys.exit("ERROR: PyYAML required. Install: pip3 install pyyaml")
except Exception as e:
    sys.exit(f"ERROR: cannot parse {path}: {e}")

start = dt.date.fromisoformat(str(cfg["start_date"]))
test = dt.date.fromisoformat(str(cfg.get("test_window_start", cfg["start_date"])))
today = dt.date.fromisoformat(when)

days_from_start = (today - start).days
week_num = days_from_start // 7 + 1 if days_from_start >= 0 else 0

d_test = (test - today).days
d_report = (dt.date.fromisoformat(str(cfg.get("reporting_deadline", cfg["start_date"]))) - today).days

DOW = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
dow = DOW[today.weekday()]
sd = cfg.get("study_days", {}) or {}
weekday_days = sd.get("weekdays", []) or []
weekend_days = sd.get("weekend", []) or []
hours = cfg.get("hours", {}) or {}

if dow in weekend_days:
    today_hours = hours.get("weekend", 0)
    today_window = hours.get("weekend_window", "—")
elif dow in weekday_days:
    today_hours = hours.get("weekday", 0)
    today_window = hours.get("weekday_window", "—")
else:
    today_hours = 0
    today_window = "—"

weeks = sorted((cfg.get("weeks", []) or []), key=lambda w: w.get("week", 0))
cur = next((w for w in weeks if w.get("week") == week_num), None)

if mode == "week":
    print(week_num)
elif mode == "today":
    if today_hours > 0:
        print(f"{dow} · {today_hours}h · {today_window}")
    else:
        print(f"{dow} · rest day (not in study_days)")
elif mode == "dday":
    print(d_test)
elif mode == "json":
    import json
    out = {
        "today": today.isoformat(), "dow": dow, "week": week_num,
        "days_from_start": days_from_start, "dday_test": d_test, "dday_report": d_report,
        "today_hours": today_hours, "today_window": today_window,
        "target_score": cfg.get("target_score"),
        "current_week": cur,
    }
    print(json.dumps(out, ensure_ascii=False))
else:  # all
    print(f"📅 TOEFL — {today.isoformat()} ({dow})")
    if week_num == 0:
        print(f"학습 시작 전 (D{d_test} to test window)")
    elif cur:
        print(f"Week {cur['week']} — {cur.get('focus','')}")
        for t in cur.get("tasks", []) or []:
            print(f"  [ ] {t}")
    else:
        print("학습 기간 종료 후")
    if week_num == 0:
        print("오늘: 학습 시작 전 (아직 계획 미적용)")
    elif today_hours > 0:
        print(f"오늘 계획: {today_hours}h · {today_window}")
    else:
        print("오늘: rest day (study_days에 없는 요일)")
    print(f"시험까지 D{d_test} (test window {cfg.get('test_window_start')}~{cfg.get('test_window_end')})")
    print(f"리포팅 마감 D{d_report} · 목표 {cfg.get('target_score')}점 · {cfg.get('purpose','')}")
PYEOF
