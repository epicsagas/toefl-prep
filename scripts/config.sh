#!/usr/bin/env bash
# TOEFL plugin — environment configuration
# Source this file: source "$(dirname "$0")/config.sh"
#
# Defines model selection, endpoints, and paths used by llm_eval.sh and stt_transcribe.sh.
# Override any variable via environment before sourcing.

set -o allexport

# --- Local LLM (Ollama) ---
TOEFL_OLLAMA_HOST="${TOEFL_OLLAMA_HOST:-http://localhost:11434}"
TOEFL_OLLAMA_API="${TOEFL_OLLAMA_HOST}/api/chat"

# Evaluation model priority: user override > recommended (qwen2.5:7b-instruct) > fallback (llama3.1:8b).
# Resolved lazily by llm_eval.sh (checks installed models via `ollama list`).
TOEFL_GRADE_MODEL_PREFERRED="${TOEFL_GRADE_MODEL_PREFERRED:-qwen2.5:7b-instruct}"
TOEFL_GRADE_MODEL_FALLBACK="${TOEFL_GRADE_MODEL_FALLBACK:-llama3.1:8b}"
# Force a specific model (bypass auto-detection). Empty = auto.
TOEFL_GRADE_MODEL="${TOEFL_GRADE_MODEL:-}"

# Generation model (question generation) — can be lighter/faster.
TOEFL_GEN_MODEL_PREFERRED="${TOEFL_GEN_MODEL_PREFERRED:-qwen2.5:7b-instruct}"
TOEFL_GEN_MODEL_FALLBACK="${TOEFL_GEN_MODEL_FALLBACK:-llama3.1:8b}"
TOEFL_GEN_MODEL="${TOEFL_GEN_MODEL:-}"

# LLM sampling params — low temperature for consistent grading.
TOEFL_GRADE_TEMPERATURE="${TOEFL_GRADE_TEMPERATURE:-0.3}"
TOEFL_GEN_TEMPERATURE="${TOEFL_GEN_TEMPERATURE:-0.7}"
TOEFL_TIMEOUT="${TOEFL_TIMEOUT:-180}"   # seconds (long writing responses)

# --- whisper.cpp (STT for speaking) ---
TOEFL_WHISPER_MODEL="${TOEFL_WHISPER_MODEL:-$HOME/.local/share/whisper/ggml-base.en.bin}"
TOEFL_WHISPER_BIN="${TOEFL_WHISPER_BIN:-whisper-cli}"

# --- Paths ---
PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOEFL_RUBRICS_DIR="${PLUGIN_ROOT}/rubrics"
TOEFL_VAULT_DIR="${TOEFL_VAULT_DIR:-$HOME/workspace/SecondBrain/01-Projects/toefl}"
TOEFL_PRACTICE_DIR="${TOEFL_VAULT_DIR}/practice"

set +o allexport

# Resolve model: returns first *installed* model from preferred -> fallback.
# Usage: model=$(toefl_resolve_model grade|gen)
toefl_resolve_model() {
  local kind="$1"
  local forced preferred fallback var

  if [[ "$kind" == "grade" ]]; then
    forced="$TOEFL_GRADE_MODEL"
    preferred="$TOEFL_GRADE_MODEL_PREFERRED"
    fallback="$TOEFL_GRADE_MODEL_FALLBACK"
  else
    forced="$TOEFL_GEN_MODEL"
    preferred="$TOEFL_GEN_MODEL_PREFERRED"
    fallback="$TOEFL_GEN_MODEL_FALLBACK"
  fi

  # Explicit override wins (no install check).
  if [[ -n "$forced" ]]; then
    echo "$forced"; return 0
  fi

  local installed=""
  if command -v ollama >/dev/null 2>&1; then
    installed="$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | tr '\n' ' ')"
  fi

  for m in "$preferred" "$fallback"; do
    if [[ " $installed " == *" $m "* ]]; then
      echo "$m"; return 0
    fi
  done

  # Neither installed — emit preferred and let caller surface the install hint.
  echo "$preferred"
  return 1
}

# Echo install hint for a missing model.
toefl_install_hint() {
  local model="$1"
  echo "Model '$model' not found in 'ollama list'. Install: ollama pull $model" >&2
}
