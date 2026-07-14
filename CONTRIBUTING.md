# Contributing to toefl-prep

Thanks for your interest in improving toefl-prep! This plugin grades TOEFL iBT practice offline with local models (Ollama + whisper.cpp).

## Ways to contribute

- **Rubric accuracy** — improve `rubrics/*.md` to better match ETS scoring.
- **Local model support** — add adapters for LM Studio / llama.cpp / MLX in `scripts/`.
- **Translations** — see `docs/i18n/` (10 languages). Keep English (`README.md`) authoritative.
- **Bug reports** — grading errors, script failures, model fallback issues.

## Setup

```bash
git clone https://github.com/epicsagas/toefl-prep
cd toefl-prep
# Prerequisites: ollama, whisper-cpp, ffmpeg, python3 + pyyaml
ollama pull qwen2.5:7b-instruct   # recommended grading model
```

## Development workflow

1. Create a branch: `feat/<topic>` or `fix/<topic>`.
2. Make minimal, surgical changes — match existing style (Korean comments in scripts, English in docs).
3. If you change grading logic, run a smoke test:
   ```bash
   echo "sample essay text" > /tmp/essay.txt
   scripts/llm_eval.sh grade /tmp/essay.txt rubrics/writing.md
   ```
   Verify the JSON has `score`, `dimensions`, `evidence`.
4. Commit with [Conventional Commits](https://www.conventionalcommits.org): `type(scope): description`.
5. Open a PR. For rubric changes, include before/after grading output on a fixed sample.

## Translation guidelines

- English `README.md` is the source of truth. Translations must not get ahead of it.
- Each `docs/i18n/<lang>/README.md` declares at the top that English is authoritative.
- Use ISO 639-1 codes: `ko`, `ja`, `zh-Hans`, `zh-Hant`, `es`, `fr`, `de`, `pt`, `ru`, `it`.
- Do **not** translate code blocks, URLs, or shell commands.

## Honest-grading principle

Any change that inflates scores or hides model limitations will be rejected. Local LLM grades are practice estimates — keep the limitation notices intact.
