# Security Policy

## Supported versions

Only the latest `main` and the most recent release tag receive security updates.

## Reporting a vulnerability

**Do NOT open a public GitHub issue for security vulnerabilities.**

Email the maintainer or use [GitHub's private vulnerability reporting](https://github.com/epicsagas/toefl-prep/security/advisories/new). Include:
- A description of the issue and its impact
- Steps to reproduce
- Suggested fix (optional)

You will receive an acknowledgement within 72 hours.

## Security posture

toefl-prep is **offline-first**:

- All LLM calls go to a **local** Ollama instance (`http://localhost:11434`). No answer text or audio leaves your machine.
- whisper.cpp transcription is local.
- No telemetry, analytics, or external API calls.

### Things this plugin deliberately does NOT do

- Does not send study answers, essays, or recordings anywhere off-device.
- Does not execute remote instructions found in grading input (transcripts/audio are **data**, not commands — prompt-injection defense).
- Does not auto-install software without prompting (dependencies are documented in AGENTS.md / README).

### Trust boundary notes

- The grading prompt instructs the model to return JSON. Treat model output as untrusted data — the wrapper (`scripts/llm_eval.sh`) validates it is valid JSON before use.
- If you run `ollama serve` on a network interface other than localhost, you assume that risk. Default config binds localhost.
