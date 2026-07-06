#!/usr/bin/env bash
# Batch generator for the OSHW SystemVerilog LLM benchmark.
#
# For each (DUT, testbench) pair listed in the input JSON, this script:
#   1. pickles the reference RTL, the testbench, and a golden (RTL+TB) file with a
#      single `bender pickle` invocation each (reachability-trimmed via --top, comments
#      stripped, newlines squashed);
#   2. normalizes module/testbench identifiers to TopModule / TopTestbench;
#   3. generates a natural-language specification per DUT via scripts/spec-gen (litellm),
#      running all designs concurrently.
#
# It is idempotent: designs whose bench artifacts already exist are skipped unless
# --force is given. Per-design failures are collected and reported at the end instead of
# aborting the whole run.
set -uo pipefail

SCRIPT_NAME="$(basename "$0")"
REPO_ROOT="$(pwd)"

# -------- parameter defaults (env can override) --------
: "${OUT_DIR:=out}"
BENCH_DIR="${OUT_DIR}/bench"
JSON_PATH="${JSON_PATH:-}"              # must be provided via CLI

: "${PROVIDER:=openai}"
: "${MODEL:=gpt-4o-2024-08-06}"
: "${KEY_CFG_PATH:=${REPO_ROOT}/key.cfg}"
: "${MAX_TOKEN:=8192}"
: "${TOKENS:=60000}"
: "${TEMPERATURE:=0.8}"
: "${TOP_P:=0.95}"
: "${CONCURRENCY:=8}"
: "${REVIEW:=1}"                        # 1 = run spec quality/leakage review pass
FORCE=0
PICKLE_ONLY=0                           # 1 = stop after pickling (no spec-gen / no LLM)

# How to run spec-gen. Prefer `uv run` so the litellm venv is used; fall back to
# executing the script directly if uv is unavailable.
if command -v uv >/dev/null 2>&1; then
  SPEC_GEN_RUN=(uv run "$REPO_ROOT/scripts/spec-gen")
else
  SPEC_GEN_RUN=("$REPO_ROOT/scripts/spec-gen")
fi

print_help() {
  cat <<EOF
${SCRIPT_NAME} — generate the OSHW SystemVerilog LLM benchmark (bender pickle -> spec-gen).

USAGE:
  ${SCRIPT_NAME} --json <config.json> [--out out/] [options]
  ${SCRIPT_NAME} --help

INPUT JSON SHAPE:
{
  "assets/common_cells": [
    ["fifo_v3", "fifo_v3.sv", "fifo_tb.sv"]
  ]
}

Each tuple is: [<top_module_name>, <rtl_file_path>, <tb_file_path?>]
- <tb_file_path> is optional; leave "" if the design has no testbench.
- Paths are relative to the asset directory (the JSON key).

OPTIONS:
  -j, --json PATH        Path to the JSON config (required)
  -o, --out DIR          Output folder (default: $OUT_DIR)
      --provider NAME    LLM provider (default: $PROVIDER)
      --model NAME       LLM model (default: $MODEL)
      --key-cfg PATH     Path to API key config (default: $KEY_CFG_PATH)
      --max-token N      Max tokens per response (default: $MAX_TOKEN)
      --tokens N         Total token budget for prompt+inputs (default: $TOKENS)
      --temperature F    Sampling temperature (default: $TEMPERATURE)
      --top-p F          Nucleus sampling parameter (default: $TOP_P)
      --concurrency N    Max concurrent LLM requests (default: $CONCURRENCY)
      --no-review        Disable the spec quality/leakage review pass
      --force            Regenerate even if bench artifacts already exist
      --pickle-only      Only pickle + normalize the .sv files; skip spec generation
                         (no LLM call). Useful for CI and offline validation.
  -h, --help             Show this help

ENVIRONMENT:
  BENDER_BIN   Path to a bender >= 0.32 with the 'slang' feature (has 'pickle').
               e.g. export BENDER_BIN=./bender-x86_64-unknown-linux-gnu/bender
EOF
}

log() { printf '[%s] %s\n' "$(date +'%Y-%m-%d %H:%M:%S')" "$*"; }

# -------- utility helpers --------
need_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "ERROR: '$1' not found in PATH." >&2; exit 1; }
}
need_file() {
  [[ -r "$1" ]] || { echo "ERROR: required file not found/readable: $1" >&2; exit 1; }
}

# Prefer env override BENDER_BIN; then repo-local build; then PATH.
find_bin() {
  local name="${1:?binary name required}"
  local env_var="${name^^}_BIN"     # e.g. bender -> BENDER_BIN
  local candidates=()

  if [[ -n "${!env_var:-}" ]]; then candidates+=("${!env_var}"); fi
  # Prebuilt release layout, then a local source build, then PATH.
  candidates+=("$REPO_ROOT/$name-x86_64-unknown-linux-gnu/$name")
  candidates+=("$REPO_ROOT/bender/target/release/$name")
  candidates+=("$name")

  for c in "${candidates[@]}"; do
    if [[ -x "$c" ]]; then echo "$c"; return 0; fi
    if command -v "$c" >/dev/null 2>&1; then command -v "$c"; return 0; fi
  done
  echo "ERROR: could not find executable for '$name'. Tried: ${candidates[*]}" >&2
  return 1
}

rtl_basename() { echo "${1##*/}"; }
tb_stem()      { local p="${1##*/}"; echo "${p%.*}"; }
escape_re()    { printf '%s' "$1" | sed -e 's/[.[\()*^$\\]/\\&/g'; }

# -------- CLI parsing --------
while [[ $# -gt 0 ]]; do
  case "$1" in
    -j|--json) JSON_PATH="$2"; shift 2;;
    -o|--out)  OUT_DIR="$2"; BENCH_DIR="${OUT_DIR}/bench"; shift 2;;
    --provider)    PROVIDER="$2"; shift 2;;
    --model)       MODEL="$2"; shift 2;;
    --key-cfg)     KEY_CFG_PATH="$2"; shift 2;;
    --max-token)   MAX_TOKEN="$2"; shift 2;;
    --tokens)      TOKENS="$2"; shift 2;;
    --temperature) TEMPERATURE="$2"; shift 2;;
    --top-p)       TOP_P="$2"; shift 2;;
    --concurrency) CONCURRENCY="$2"; shift 2;;
    --no-review)   REVIEW=0; shift;;
    --force)       FORCE=1; shift;;
    --pickle-only) PICKLE_ONLY=1; shift;;
    -h|--help) print_help; exit 0;;
    *) echo "Unknown argument: $1" >&2; print_help; exit 1;;
  esac
done

[[ -n "$JSON_PATH" ]] || { echo "ERROR: --json is required." >&2; print_help; exit 1; }

# -------- tool guardrails --------
need_cmd jq
# The API key is only needed for spec generation; --pickle-only runs offline.
[[ $PICKLE_ONLY -eq 1 ]] || need_file "$KEY_CFG_PATH"

BENDER="$(find_bin bender)" || exit 1
log "Using bender: $BENDER"
("$BENDER" --version || true) 2>/dev/null | sed 's/^/[bender] /' || true

# Confirm this bender has the slang-backed 'pickle' subcommand.
if ! "$BENDER" pickle --help >/dev/null 2>&1; then
  cat >&2 <<EOF
ERROR: the resolved bender ($BENDER) does not support the 'pickle' subcommand.
       You need bender >= 0.32 with the 'slang' feature. The simplest route is a
       prebuilt release binary, then point BENDER_BIN at it:
         curl -fsSL https://github.com/pulp-platform/bender/releases/download/v0.32.0/bender-x86_64-unknown-linux-gnu.tar.xz | tar xJ
         export BENDER_BIN=\$PWD/bender-x86_64-unknown-linux-gnu/bender
       (Or 'cargo install --git https://github.com/pulp-platform/bender --tag v0.32.0',
        which recompiles slang and needs a C++20 compiler + CMake.)
EOF
  exit 1
fi

[[ -x "$REPO_ROOT/scripts/spec-gen" ]] || { echo "ERROR: scripts/spec-gen not found or not executable." >&2; exit 1; }

mkdir -p "$OUT_DIR" "$BENCH_DIR"

# -------- load JSON worklist --------
# Each record: <submodule> <top> <rtl> <tb>  (tab-free, unit-separator joined)
mapfile -t LINES < <(jq -r 'to_entries[] | .key as $sub | .value[] | [$sub, .[0], .[1], (.[2] // "")] | join("")' "$JSON_PATH")
(( ${#LINES[@]} > 0 )) || { echo "No work found in JSON. Exiting."; exit 0; }

log "Parsed ${#LINES[@]} design(s) from $JSON_PATH"

# -------- pickle + rename loop --------
# Builds a JSONL worklist for spec-gen (one line per DUT to spec) and collects failures.
BATCH_JSONL="$(mktemp "${TMPDIR:-/tmp}/specgen.XXXXXX.jsonl")"
declare -a PICKLE_FAILED=()
declare -a SKIPPED=()
SPEC_COUNT=0

cleanup() { rm -f "$BATCH_JSONL"; }
trap cleanup EXIT

pickle() {
  # pickle <submodule> <output.sv> <top> [targets...]
  local submod="$1"; local outfile="$2"; local top="$3"; shift 3
  local targs=()
  local t
  for t in "$@"; do targs+=(-t "$t"); done
  "$BENDER" -d "$submod" pickle "${targs[@]}" --top "$top" \
      --strip-comments --squash-newlines -o "$outfile"
}

idx=0
for line in "${LINES[@]}"; do
  IFS=$'\x1f' read -r SUBMOD TOP_NAME RTL TB <<<"$line"
  PROB_ID=$(printf "Prob%03d" "$idx")
  ((++idx))

  if [[ -z "$TOP_NAME" || -z "$RTL" ]]; then
    log "Skipping tuple with missing TOP or RTL under '$SUBMOD'."
    SKIPPED+=("$PROB_ID (malformed)")
    continue
  fi
  if [[ ! -d "$SUBMOD" ]]; then
    log "ERROR: asset folder '$SUBMOD' does not exist (submodules initialized?)."
    PICKLE_FAILED+=("$PROB_ID:$TOP_NAME (missing asset '$SUBMOD')")
    continue
  fi

  TOP_FILE="$(rtl_basename "$RTL")"
  TOP_BASE="${TOP_FILE%.*}"
  TB_PRESENT=0
  TB_STEM_VAL=""
  if [[ -n "${TB:-}" ]]; then TB_PRESENT=1; TB_STEM_VAL="$(tb_stem "$TB")"; fi

  RTL_SV="$BENCH_DIR/${PROB_ID}_${TOP_NAME}_ref.sv"
  TB_SV="$BENCH_DIR/${PROB_ID}_${TOP_NAME}_test.sv"
  RTLTB_SV="$BENCH_DIR/${PROB_ID}_${TOP_NAME}_test_golden.sv"
  PROMPT_TXT="$BENCH_DIR/${PROB_ID}_${TOP_NAME}_prompt.txt"

  log "=== ${PROB_ID} ${TOP_NAME} (asset=$SUBMOD, rtl=$RTL, tb=${TB:-none}) ==="

  # Resume: skip if the key artifacts already exist.
  if [[ $FORCE -eq 0 && -f "$RTL_SV" && -f "$PROMPT_TXT" ]]; then
    log "  already generated; skipping (use --force to regenerate)."
    SKIPPED+=("$PROB_ID:$TOP_NAME")
    continue
  fi

  # -------- pickle reference RTL and (optional) golden testbench --------
  # _ref.sv: the reference DUT, reachable modules only.
  if ! pickle "$SUBMOD" "$RTL_SV" "$TOP_BASE" rtl; then
    log "  pickle failed for RTL top '$TOP_BASE'."
    PICKLE_FAILED+=("$PROB_ID:$TOP_NAME (pickle rtl)")
    rm -f "$RTL_SV"
    continue
  fi

  if [[ $TB_PRESENT -eq 1 ]]; then
    # _test_golden.sv: testbench + reference DUT (rtl+test+simulation), reachable from
    # the TB top. The TB instantiates the DUT, so slang pulls it in — this is the golden.
    if ! pickle "$SUBMOD" "$RTLTB_SV" "$TB_STEM_VAL" rtl test simulation; then
      log "  pickle failed for golden top '$TB_STEM_VAL' (rtl/test/simulation)."
      PICKLE_FAILED+=("$PROB_ID:$TOP_NAME (pickle golden)")
      rm -f "$RTL_SV" "$RTLTB_SV"
      continue
    fi
  fi

  # -------- normalize identifiers (TopModule / TopTestbench) --------
  TOP_NAME_RE="$(escape_re "$TOP_NAME")"
  perl -0777 -i -pe "s/\b${TOP_NAME_RE}\b/TopModule/g" -- "$RTL_SV"
  if [[ $TB_PRESENT -eq 1 ]]; then
    if [[ -n "$TB_STEM_VAL" ]]; then
      TB_STEM_RE="$(escape_re "$TB_STEM_VAL")"
      perl -0777 -i -pe "s/\b${TOP_NAME_RE}\b/TopModule/g; s/\b${TB_STEM_RE}\b/TopTestbench/g" -- "$RTLTB_SV"
    else
      perl -0777 -i -pe "s/\b${TOP_NAME_RE}\b/TopModule/g" -- "$RTLTB_SV"
    fi

    # _test.sv: the golden with the reference DUT definition removed, so the assessed
    # LLM supplies its own `module TopModule`. The TB keeps instantiating TopModule; we
    # only drop the reference `module TopModule ... endmodule` definition block.
    # NB: only horizontal whitespace ([ \t]) after `endmodule` — using \s would eat the
    # following newline and swallow the next module's declaration line.
    cp -f -- "$RTLTB_SV" "$TB_SV"
    perl -0777 -i -pe 's/\bmodule\s+TopModule\b.*?\bendmodule\b[ \t]*(?::[ \t]*\w+)?[ \t]*\n?//s' -- "$TB_SV"
    if grep -qE '\bmodule\s+TopModule\b' "$TB_SV"; then
      log "  WARNING: could not strip reference TopModule from $(basename "$TB_SV") (test == golden)."
    fi
  fi

  # -------- queue spec generation for this DUT --------
  # spec-gen writes <out>.md/.txt; we point it at the prompt path (minus extension).
  SPEC_OUT="$BENCH_DIR/${PROB_ID}_${TOP_NAME}_prompt.md"
  jq -nc --arg top "TopModule" --arg rtl "$RTL_SV" --arg out "$SPEC_OUT" \
     '{top:$top, rtl:$rtl, out:$out}' >> "$BATCH_JSONL"
  ((++SPEC_COUNT))
done

# -------- generate specs (concurrently) --------
SPEC_STATUS=0
if [[ $PICKLE_ONLY -eq 1 ]]; then
  log "--pickle-only: skipping spec generation ($SPEC_COUNT DUT(s) would be queued)."
elif [[ $SPEC_COUNT -gt 0 ]]; then
  log "Generating $SPEC_COUNT specification(s) with spec-gen (provider=$PROVIDER, model=$MODEL, concurrency=$CONCURRENCY)..."
  SPEC_ARGS=(
    --batch "$BATCH_JSONL"
    --provider "$PROVIDER"
    --model "$MODEL"
    --key-cfg "$KEY_CFG_PATH"
    --max-token "$MAX_TOKEN"
    --tokens "$TOKENS"
    --temperature "$TEMPERATURE"
    --top-p "$TOP_P"
    --concurrency "$CONCURRENCY"
  )
  [[ "$REVIEW" -eq 0 ]] && SPEC_ARGS+=(--no-review)

  if ! "${SPEC_GEN_RUN[@]}" "${SPEC_ARGS[@]}"; then
    SPEC_STATUS=1
    log "spec-gen reported one or more failures (see above)."
  fi
  # spec-gen writes <base>_prompt.md and <base>_prompt.txt directly at the target
  # paths: the .txt is the benchmark prompt, the .md is a human-readable companion.
else
  log "No specs to generate (all skipped or pickle-only failures)."
fi

# -------- summary --------
echo
log "==================== SUMMARY ===================="
log "Designs parsed : ${#LINES[@]}"
log "Skipped        : ${#SKIPPED[@]}${SKIPPED:+ (${SKIPPED[*]})}"
log "Pickle failed  : ${#PICKLE_FAILED[@]}${PICKLE_FAILED:+ (${PICKLE_FAILED[*]})}"
log "Specs queued   : ${SPEC_COUNT}"
log "Output dir     : ${BENCH_DIR}"
log "================================================="

# Exit non-zero if anything failed.
if [[ ${#PICKLE_FAILED[@]} -gt 0 || $SPEC_STATUS -ne 0 ]]; then
  exit 1
fi
exit 0
