# Changelog

All notable changes to this project are documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-07-15

### Added
- User-customizable study schedule via `schedule.yaml` (timeline, study days, time windows, weekly goals).
- `scripts/roadmap.sh` — computes current week, today's plan, and D-day from `schedule.yaml`.
- 10-language README under `docs/i18n/` (ko, ja, zh-Hans, zh-Hant, es, fr, de, pt, ru, it).
- Community files: CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, issue/PR templates, dependabot config.
- 3-host support: Claude Code (`.claude-plugin`), Codex (`.codex-plugin`), agy (root `plugin.json`).
- Host-discovery skill copies in `.claude/skills/` and `.codex/skills/`.

### Changed
- `/toefl-roadmap` and `/toefl-status` now read from `schedule.yaml` instead of hardcoded dates.

## [0.1.0] - 2026-07-14

### Added
- Initial plugin: 4-week TOEFL prep with local LLM (Ollama) + whisper.cpp.
- 4 sections graded offline: Reading/Listening (answer-check), Writing (rubric), Speaking (STT + rubric).
- Scripts: `config.sh` (model auto-select), `llm_eval.sh` (Ollama wrapper), `stt_transcribe.sh` (whisper.cpp).
- ETS-aligned rubrics (reading, listening, speaking, writing).
- 5 slash commands: roadmap, practice, grade, drill, status.
