#!/usr/bin/env bash
# Shared helpers: logging, guards, idempotency utilities.
# Sourced by setup.sh and every scripts/*.sh — do not execute directly.

# Continue on non-fatal errors (no `-e`); catch unset vars and pipe failures.
set -uo pipefail

# --- Colors (disabled when not a TTY) ---------------------------------------
if [[ -t 1 ]]; then
  _C_RESET=$'\033[0m'; _C_BLUE=$'\033[34m'; _C_GREEN=$'\033[32m'
  _C_YELLOW=$'\033[33m'; _C_RED=$'\033[31m'; _C_DIM=$'\033[2m'
else
  _C_RESET=''; _C_BLUE=''; _C_GREEN=''; _C_YELLOW=''; _C_RED=''; _C_DIM=''
fi

log()  { printf '%s==>%s %s\n'   "$_C_BLUE"   "$_C_RESET" "$*"; }
ok()   { printf '%s  ✓%s %s\n'   "$_C_GREEN"  "$_C_RESET" "$*"; }
skip() { printf '%s  •%s %s\n'   "$_C_DIM"    "$_C_RESET" "$*"; }
warn() { printf '%s  ! %s%s\n'   "$_C_YELLOW" "$*" "$_C_RESET" >&2; }
err()  { printf '%s  ✗ %s%s\n'   "$_C_RED"    "$*" "$_C_RESET" >&2; }

# --- Guards / helpers -------------------------------------------------------

# has_cmd <name> — true if a command exists on PATH.
has_cmd() { command -v "$1" >/dev/null 2>&1; }

# app_installed <bundle-id> — true if an app with this bundle id is installed.
app_installed() {
  local bid="$1"
  [[ -n "$bid" ]] || return 1
  # mdfind is fast when Spotlight indexing is on; osascript is the fallback.
  if mdfind "kMDItemCFBundleIdentifier == '$bid'" 2>/dev/null | grep -q .; then
    return 0
  fi
  osascript -e "id of application id \"$bid\"" >/dev/null 2>&1
}

# run_step <label> <function> — run a step, trapping failures so the overall
# run continues (aligns with "continue on non-fatal errors").
run_step() {
  local label="$1" fn="$2"
  log "$label"
  if "$fn"; then
    ok "$label — done"
  else
    err "$label — failed (continuing)"
    STEP_FAILURES+=("$label")
  fi
}
STEP_FAILURES=()
