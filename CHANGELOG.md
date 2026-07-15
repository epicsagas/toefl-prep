# Changelog

All notable changes to this project are documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.1] - 2026-07-15

### Changed
- Default data location moved to OS Documents folder (`~/Documents/toefl-prep/`), not a hardcoded local vault path. `TOEFL_DATA_DIR` overrides; `TOEFL_VAULT_DIR` kept as a legacy alias.
- `schedule.yaml` is **never auto-created**. On first run `roadmap.sh` prompts interactively (`Y/n`) before scaffolding from the template. Non-TTY/CI environments get a hint only (exit 2). Linux uses `$XDG_DOCUMENTS_DIR`.

### Fixed
- Removed all hardcoded `~/workspace/SecondBrain/...` paths from the public repo (config.sh, scripts, commands, SKILL.md, AGENTS.md, all 11 READMEs).
- Codex/agy install steps corrected to use plugin managers (`codex plugin add`, `agy plugin install`), not manual git-clone — matching the marketplace.json structure.

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
