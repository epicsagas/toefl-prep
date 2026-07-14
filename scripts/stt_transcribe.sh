#!/usr/bin/env bash
# stt_transcribe.sh — whisper.cpp wrapper for TOEFL speaking evaluation
#
# Transcribes an audio recording (speaking answer) to text + timing metadata.
# The transcript feeds into the LLM speaking rubric (fluency/language use/content);
# transcript quality is an *indirect* proxy for pronunciation clarity (documented limit).
#
# Usage:
#   stt_transcribe.sh <audio-file> [out-transcript.txt]
#
# Env (see config.sh): TOEFL_WHISPER_BIN, TOEFL_WHISPER_MODEL

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=config.sh
. "$SCRIPT_DIR/config.sh"

[[ $# -lt 1 ]] && { echo "Usage: stt_transcribe.sh <audio-file> [out-transcript.txt]" >&2; exit 2; }

audio="$1"
out="${2:-}"

[[ ! -f "$audio" ]] && { echo "ERROR: audio file not found: $audio" >&2; exit 2; }

if ! command -v "$TOEFL_WHISPER_BIN" >/dev/null 2>&1; then
  echo "ERROR: whisper-cli not found. Install: brew install whisper-cpp" >&2
  exit 3
fi

if [[ ! -f "$TOEFL_WHISPER_MODEL" ]]; then
  echo "ERROR: whisper model not found: $TOEFL_WHISPER_MODEL" >&2
  echo "Download:" >&2
  echo "  mkdir -p \"$(dirname "$TOEFL_WHISPER_MODEL")\"" >&2
  echo "  curl -L https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin -o \"$TOEFL_WHISPER_MODEL\"" >&2
  exit 3
fi

# Normalize to 16kHz mono wav (whisper.cpp requirement) into a temp file.
wav_tmp="$(mktemp -d)/norm.wav"
if command -v ffmpeg >/dev/null 2>&1; then
  if ! ffmpeg -y -i "$audio" -ar 16000 -ac 1 -c:a pcm_s16le "$wav_tmp" >/dev/null 2>&1; then
    # ffmpeg failed (unsupported input) — let whisper-cli try the original
    input_file="$audio"
  else
    input_file="$wav_tmp"
  fi
else
  echo "WARN: ffmpeg not found — passing original file to whisper (may fail on some formats)" >&2
  input_file="$audio"
fi

out_prefix="$(mktemp -d)/toefl_stt"

# Transcribe: txt + json (segments/timing) + stderr captured
whisper_rc=0
"$TOEFL_WHISPER_BIN" \
  -m "$TOEFL_WHISPER_MODEL" \
  -f "$input_file" \
  -otxt -of "$out_prefix" \
  -oj \
  >/dev/null 2>"/tmp/toefl_whisper.err" || whisper_rc=$?

txt_file="${out_prefix}.txt"
json_file="${out_prefix}.json"

if [[ ! -f "$txt_file" ]]; then
  echo "ERROR: transcription produced no output" >&2
  cat /tmp/toefl_whisper.err >&2
  rm -rf "$(dirname "$wav_tmp")" "$(dirname "$out_prefix")"
  exit 4
fi

transcript="$(cat "$txt_file")"

# Compute rough fluency metrics from segments (words/sec, pause count) if json present
metrics=""
if [[ -f "$json_file" ]] && command -v jq >/dev/null 2>&1; then
  word_count="$(printf '%s' "$transcript" | wc -w | tr -d ' ')"
  total_dur="$(jq -r '[.transcription.[].segments[].t1 // empty] | (max // 0) - ([.[].t0 // empty] | min // 0)' "$json_file" 2>/dev/null)"
  seg_count="$(jq -r '.transcription.[].segments | length' "$json_file" 2>/dev/null | awk '{s+=$1} END{print s+0}')"
  if [[ -n "$total_dur" && "$total_dur" -gt 0 ]]; then
    wps="$(awk -v w="$word_count" -v d="$total_dur" 'BEGIN{printf "%.2f", w/(d/1000)}')"
    metrics="words=$word_count duration_ms=$total_dur segments=$seg_count words_per_sec=$wps"
  fi
fi

# Output
{
  echo "=== TRANSCRIPT ==="
  echo "$transcript"
  echo
  if [[ -n "$metrics" ]]; then
    echo "=== FLUENCY METRICS (indirect) ==="
    echo "$metrics"
    echo
    echo "NOTE: words_per_sec is an indirect fluency proxy; transcript clarity is an indirect"
    echo "pronunciation proxy. Neither measures true accent/prosody — see speaking rubric."
  fi
} > "${out:-/dev/stdout}"

if [[ -z "$out" ]]; then :; fi

rm -rf "$(dirname "$wav_tmp")" "$(dirname "$out_prefix")"
exit $whisper_rc
