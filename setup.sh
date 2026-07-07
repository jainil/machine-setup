#!/usr/bin/env bash
# ============================================================================
#  Mac first-time setup — orchestrator.
#
#  Usage:
#    ./setup.sh                 # run every step, in order
#    ./setup.sh system zsh      # run only the named steps
#
#  Steps: system | zsh | homebrew | apps | startup
#  Safe to re-run: each step is idempotent and skips work already done.
# ============================================================================

# Resolve repo dir regardless of where it's invoked from.
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO_DIR

# shellcheck source=lib/common.sh
source "$REPO_DIR/lib/common.sh"
# shellcheck source=config.sh
source "$REPO_DIR/config.sh"

# shellcheck source=scripts/01-system.sh
source "$REPO_DIR/scripts/01-system.sh"
# shellcheck source=scripts/02-zsh.sh
source "$REPO_DIR/scripts/02-zsh.sh"
# shellcheck source=scripts/03-homebrew.sh
source "$REPO_DIR/scripts/03-homebrew.sh"
# shellcheck source=scripts/04-default-apps.sh
source "$REPO_DIR/scripts/04-default-apps.sh"
# shellcheck source=scripts/05-startup-apps.sh
source "$REPO_DIR/scripts/05-startup-apps.sh"

# --- Preflight: this is macOS, and keep sudo warm for the run ---------------
preflight() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    err "this script is for macOS only"; exit 1
  fi
  # Xcode Command Line Tools are needed by Homebrew, git, etc.
  if ! xcode-select -p >/dev/null 2>&1; then
    log "installing Xcode Command Line Tools (follow the GUI prompt, then re-run)"
    xcode-select --install 2>/dev/null || true
  fi
  # `system` step needs sudo (mdutil); prompt once up front instead of mid-run.
  sudo -v 2>/dev/null || warn "could not acquire sudo (Spotlight indexing step will be skipped)"
}

# --- Step registry: name -> function ----------------------------------------
run_named_step() {
  case "$1" in
    system)   run_step "System settings"    step_system ;;
    zsh)      run_step "oh-my-zsh"           step_zsh ;;
    homebrew) run_step "Homebrew & packages" step_homebrew ;;
    apps)     run_step "Default apps"        step_default_apps ;;
    startup)  run_step "Startup apps"        step_startup_apps ;;
    *)        err "unknown step: $1 (valid: system zsh homebrew apps startup)"; return 1 ;;
  esac
}

main() {
  preflight

  local steps=("$@")
  if [[ ${#steps[@]} -eq 0 ]]; then
    steps=(system zsh homebrew apps startup)
  fi

  local s
  for s in "${steps[@]}"; do
    run_named_step "$s"
  done

  echo
  if [[ ${#STEP_FAILURES[@]} -eq 0 ]]; then
    ok "All steps completed."
  else
    warn "Completed with ${#STEP_FAILURES[@]} failed step(s): ${STEP_FAILURES[*]}"
  fi
  log "Some changes (Spotlight shortcut, keyboard) fully apply after logout/login."
}

main "$@"
