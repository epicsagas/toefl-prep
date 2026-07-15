# toefl-prep

**[English](README.md)** | [한국어](docs/i18n/ko/README.md) | [日本語](docs/i18n/ja/README.md) | [简体中文](docs/i18n/zh-Hans/README.md) | [繁體中文](docs/i18n/zh-Hant/README.md) | [Español](docs/i18n/es/README.md) | [Français](docs/i18n/fr/README.md) | [Deutsch](docs/i18n/de/README.md) | [Português](docs/i18n/pt/README.md) | [Русский](docs/i18n/ru/README.md) | [Italiano](docs/i18n/it/README.md)

> TOEFL iBT study plugin — **Claude Code · Codex · agy (Antigravity CLI)**. Grades all four sections **fully offline** with a local LLM (Ollama) and whisper.cpp.

Grade Reading / Listening / Speaking / Writing with no external API — question generation, scoring, and score tracking all run on your machine. The study roadmap is **user-customizable**: set your own dates, study days, time windows, and weekly goals.

## Features

- **Fully offline grading** — local models only, no API cost or latency, nothing leaves your machine.
- **Per-section evaluation paths**:
  - Reading/Listening — LLM answer-checking + rationale citing passage/script lines
  - Writing — direct ETS 0–5 rubric grading (Content / Organization / Language / Mechanics)
  - Speaking — whisper.cpp transcription → LLM rubric (Delivery / Language Use / Topic Development)
- **Customizable roadmap** — `schedule.yaml` drives dates, study days, hours, and weekly goals. Nothing is hardcoded.
- **Score tracking** — section history for weakness diagnosis and focused drilling.
- **3-host support** — Claude Code (slash commands), Codex, agy (script-driven workflow).

## Install

### Claude Code

```bash
claude plugin marketplace add epicsagas/toefl-prep
claude plugin install epicsagas@toefl-prep
```

> Also available from the `epicsagas/plugins` suite marketplace:
> `claude plugin marketplace add epicsagas/plugins` then `claude plugin install epicsagas@toefl-prep`.

### Codex

```bash
codex plugin marketplace add epicsagas/toefl-prep
codex plugin add epicsagas@toefl-prep
```

### agy (Antigravity CLI)

agy installs directly from the GitHub repo URL (no `.git` suffix):

```bash
agy plugin install https://github.com/epicsagas/toefl-prep
agy plugin enable toefl-prep
```

> Prerequisites (PyYAML for the roadmap) are not auto-installed by Codex/agy (no SessionStart hook).
> Run `pip3 install pyyaml` before first use if roadmap features are needed.

## Prerequisites

```bash
# 1. Ollama (LLM grading / question generation)
brew install ollama
ollama serve &
ollama pull qwen2.5:7b-instruct   # recommended (best English grading on M-series 16GB)
# fallback: ollama pull llama3.1:8b

# 2. whisper.cpp (speaking STT)
brew install whisper-cpp
mkdir -p ~/.local/share/whisper
curl -L https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin \
  -o ~/.local/share/whisper/ggml-base.en.bin

# 3. ffmpeg (audio normalization, recommended) + PyYAML (roadmap)
brew install ffmpeg
pip3 install pyyaml
```

Scripts auto-select models (qwen2.5:7b preferred, llama3.1:8b fallback) and surface install hints when missing.

## Set your schedule

Data lives in your OS Documents folder by default (`~/Documents/toefl-prep/`); override with `TOEFL_DATA_DIR`.

On first run, `roadmap.sh` **asks** before creating `schedule.yaml` (it never auto-writes):

```bash
scripts/roadmap.sh all          # prompts: "Scaffold schedule.yaml? [Y/n]"
```

Answer `Y` to scaffold from the template, then edit `schedule.yaml` (start_date, test_window_*, study_days, hours, target_score, weeks). Everything the roadmap shows comes from that file.

## Usage (Claude Code)

| Command | Description |
|---------|-------------|
| `/toefl-roadmap` | Current week's goals & today's plan |
| `/toefl-practice [section] [n]` | Generate TOEFL-style questions |
| `/toefl-grade [section] [file]` | Grade answer/recording → accumulate in SCORES.md |
| `/toefl-drill [weakness]` | Focused repetition on weak areas |
| `/toefl-status` | Progress + score trend + gap to target |

> Codex/agy follow SKILL.md's intent→action mapping, calling the same scripts directly.

## Honest limitations

- **Speaking pronunciation**: whisper.cpp transcript clarity is an *indirect* proxy. True accent/prosody are not measured.
- **Local LLM grading**: 7–8B models differ absolutely from ETS official scoring. Practice estimate — validate with TPO for the real baseline.
- **Listening playback**: audio playback is the user's responsibility. The plugin provides scripts + questions only.

## Project structure

```
toefl-prep/
├── plugin.json                 # agy direct-load
├── .claude-plugin/             # Claude Code (marketplace + manifest)
├── .codex-plugin/              # Codex
├── skills/toefl/SKILL.md       # authoritative workflow (shared by all hosts)
│   └── schedule.example.yaml   # roadmap template
├── commands/                   # Claude Code slash commands (5)
├── scripts/                    # config.sh, llm_eval.sh, stt_transcribe.sh, roadmap.sh
├── rubrics/                    # reading/listening/speaking/writing (ETS-aligned)
├── docs/i18n/                  # 10-language README
└── AGENTS.md                   # shared agent guidance
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). English `README.md` is the source of truth — translations must not get ahead of it.

## License

MIT
