#!/usr/bin/env bash
# llm_eval.sh — Ollama evaluation wrapper
#
# Sends a grading prompt (+ rubric) to a local Ollama model and returns JSON.
# Falls back across models; surfaces install hints on missing models.
#
# Usage:
#   llm_eval.sh grade|gen <prompt-file> [rubric-file] [out-json-file]
#   llm_eval.sh grade|gen --inline "prompt text" [rubric-file] [out-json-file]
#
# Env (see config.sh): TOEFL_OLLAMA_API, TOEFL_GRADE_*, TOEFL_GEN_*, TOEFL_TIMEOUT

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=config.sh
. "$SCRIPT_DIR/config.sh"

usage() {
  cat <<EOF
Usage: llm_eval.sh grade|gen <prompt-file|--inline "text"> [rubric-file] [out-json-file]
  grade  = low-temperature grading (rubric-driven, JSON output)
  gen    = higher-temperature generation (question creation)
EOF
  exit 2
}

[[ $# -lt 2 ]] && usage

kind="$1"; shift
case "$kind" in
  grade|gen) ;;
  *) echo "ERROR: first arg must be 'grade' or 'gen'" >&2; usage ;;
esac

prompt_input="$1"; shift || true
rubric_file=""
out_file=""

if [[ "$prompt_input" == "--inline" ]]; then
  [[ $# -lt 1 ]] && { echo "ERROR: --inline requires prompt text" >&2; exit 2; }
  prompt_text="$1"; shift
else
  prompt_file="$prompt_input"
  [[ ! -f "$prompt_file" ]] && { echo "ERROR: prompt file not found: $prompt_file" >&2; exit 2; }
  prompt_text="$(cat "$prompt_file")"
fi

[[ $# -ge 1 ]] && rubric_file="$1" && shift
[[ $# -ge 1 ]] && out_file="$1" && shift

if [[ -n "$rubric_file" ]]; then
  [[ ! -f "$rubric_file" ]] && { echo "ERROR: rubric file not found: $rubric_file" >&2; exit 2; }
  rubric_text="$(cat "$rubric_file")"
else
  rubric_text=""
fi

if ! command -v ollama >/dev/null 2>&1; then
  echo "ERROR: ollama not installed. Install: brew install ollama && ollama serve" >&2
  exit 3
fi

# Health check
if ! curl -sfm 5 "$TOEFL_OLLAMA_HOST/api/tags" >/dev/null 2>&1; then
  echo "ERROR: Ollama not reachable at $TOEFL_OLLAMA_HOST. Run: ollama serve" >&2
  exit 3
fi

# Resolve model
if ! model="$(toefl_resolve_model "$kind" 2>/dev/null)"; then
  # toefl_resolve_model returned non-zero (model missing) but still echoes preferred name
  preferred=""
  if [[ "$kind" == "grade" ]]; then
    preferred="$TOEFL_GRADE_MODEL_PREFERRED"
    fallback="$TOEFL_GRADE_MODEL_FALLBACK"
  else
    preferred="$TOEFL_GEN_MODEL_PREFERRED"
    fallback="$TOEFL_GEN_MODEL_FALLBACK"
  fi
  echo "WARN: neither '$preferred' nor '$fallback' installed." >&2
  toefl_install_hint "$preferred"
  model="$preferred"
fi

if [[ "$kind" == "grade" ]]; then
  temp="$TOEFL_GRADE_TEMPERATURE"
else
  temp="$TOEFL_GEN_TEMPERATURE"
fi

# Build system prompt: rubric + strict JSON instruction
sys="You are an expert TOEFL examiner. Evaluate strictly and fairly per the provided rubric."
if [[ -n "$rubric_text" ]]; then
  sys="$sys

--- RUBRIC ---
$rubric_text
--- END RUBRIC ---"
fi
sys="$sys

Respond ONLY with a single JSON object (no markdown fences, no prose outside JSON) using this schema:
{
  \"score\": <number 0-5, one decimal allowed>,
  \"band\": \"<LOW|FAIR|GOOD|ADVANCED>\",
  \"dimensions\": { \"<dimension_name>\": <number>, ... },
  \"strengths\": [\"...\"],
  \"weaknesses\": [\"...\"],
  \"feedback\": \"<actionable improvement advice in Korean>\",
  \"evidence\": [\"<quote or specific reference from the answer>\"]
}"

# Escape for JSON
esc() { python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))' 2>/dev/null || jq -Rs .; }

user_json="$(printf '%s' "$prompt_text" | esc)"
sys_json="$(printf '%s' "$sys" | esc)"

payload="{\"model\":\"$model\",\"temperature\":$temp,\"stream\":false,\"format\":\"json\",\"messages\":[{\"role\":\"system\",\"content\":$sys_json},{\"role\":\"user\",\"content\":$user_json}]}"

tmp="$(mktemp)"
code=0
if ! curl -sfm "$TOEFL_TIMEOUT" -X POST "$TOEFL_OLLAMA_API" \
     -H "Content-Type: application/json" -d "$payload" -o "$tmp"; then
  echo "ERROR: Ollama request failed (model=$model, timeout=${TOEFL_TIMEOUT}s)" >&2
  rm -f "$tmp"; exit 4
fi

# Extract assistant content; Ollama /api/chat returns {message:{content:"..."}}
content="$(jq -r '.message.content // .response // empty' "$tmp" 2>/dev/null)"
rm -f "$tmp"

if [[ -z "$content" ]]; then
  echo "ERROR: empty response from model" >&2; exit 5
fi

# Validate JSON (strip accidental fences)
clean="$(printf '%s' "$content" | sed 's/^```json//; s/^```//; s/```$//' | jq . 2>/dev/null)"
if [[ -z "$clean" ]]; then
  # Not valid JSON — wrap raw text so caller still gets feedback
  jq -n --arg m "$model" --arg r "$content" '{score:null,error:"non-json-response",model:$m,raw:$r}'
  code=6
else
  # Annotate model used
  printf '%s' "$clean" | jq --arg m "$model" '. + {model:$m}'
fi

# Write to file if requested
if [[ -n "$out_file" ]]; then
  mkdir -p "$(dirname "$out_file")"
  { printf '%s' "$content"; } > "$out_file"
fi

exit $code
