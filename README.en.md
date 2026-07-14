# toefl-prep

> TOEFL iBT 4-week intensive study plugin — Claude Code · Codex · agy (Antigravity CLI).

Grades all four sections — Reading / Listening / Speaking / Writing — **fully offline** with a local LLM (Ollama) and whisper.cpp. No external API calls: question generation, grading, and score tracking all run on your machine.

## Schedule

| Item | Detail |
|------|--------|
| Study window | 2026-07-15 ~ 08-12 (4 weeks; weekday 3h / weekend 8h) |
| 🚨 Test deadline | 08-08 ~ 08-10 (Home Edition or test center) |
| 🎯 Application deadline | 08-15 (Georgia Tech OMSCS 2027 Spring) |
| Target score | **90** |

## Features

- **Fully offline grading** via local models — no API cost or latency.
- **Per-section evaluation paths**:
  - Reading/Listening — LLM answer-checking + rationale citing passage/script lines
  - Writing — direct ETS 0–5 rubric grading (Content/Org/Language/Mechanics)
  - Speaking — whisper.cpp transcription → LLM rubric (Delivery/Language Use/Topic Development)
- **4-week roadmap** with weekly goals and checklists.
- **Score tracking** with section history for weakness diagnosis and drilling.

## Install

### Claude Code

```bash
/plugin marketplace add epicsagas/toefl-prep
/plugin install toefl-prep@epicsagas
```

### Codex / agy

Clone and link into the host's plugin directory:
```bash
git clone https://github.com/epicsagas/toefl-prep
# Codex: ~/.codex/plugins/toefl-prep -> clone
# agy:   ~/.agy/plugins/toefl-prep -> clone
```

## Prerequisites

```bash
# 1. Ollama (LLM grading / question generation)
brew install ollama
ollama serve &
ollama pull qwen2.5:7b-instruct   # recommended (M2 16GB optimal, best English grading)
# or fallback: ollama pull llama3.1:8b

# 2. whisper.cpp (speaking STT)
brew install whisper-cpp
mkdir -p ~/.local/share/whisper
curl -L https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin \
  -o ~/.local/share/whisper/ggml-base.en.bin

# 3. ffmpeg (audio normalization, recommended)
brew install ffmpeg
```

Scripts auto-select models (qwen2.5:7b preferred, llama3.1:8b fallback) and surface install hints when missing.

## Usage (Claude Code)

| Command | Description |
|---------|-------------|
| `/toefl-roadmap` | Current week's goals & tasks |
| `/toefl-practice [section] [n]` | Generate TOEFL-style questions |
| `/toefl-grade [section] [file]` | Grade answer/recording → accumulate in SCORES.md |
| `/toefl-drill [weakness]` | Focused repetition on weak areas |
| `/toefl-status` | Progress + score trend + gap to target |

> Codex/agy follow SKILL.md's intent→action mapping, invoking the same scripts directly.

## Data storage

Default `~/workspace/SecondBrain/01-Projects/toefl/` (override via `TOEFL_VAULT_DIR`).

## Honest limitations

- **Speaking pronunciation**: whisper.cpp transcript clarity is an *indirect* proxy. True accent/prosody are not measured.
- **Local LLM grading**: 7–8b models differ absolutely from ETS official scoring. Practice estimate — validate with TPO for the real baseline.
- **Listening playback**: audio playback is the user's responsibility. The plugin provides scripts + questions only.

## License

MIT
