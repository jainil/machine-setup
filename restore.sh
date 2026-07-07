#!/usr/bin/env bash
# ============================================================================
#  Restore system settings changed by scripts/01-system.sh back to macOS
#  defaults, so you can test setup.sh repeatedly.
#
#  Usage:
#    ./restore.sh              # revert system settings (§1) + remove configured login items
#    ./restore.sh system       # revert only system settings
#    ./restore.sh startup      # remove only the configured login items
#
#  Strategy: `defaults delete` a key removes your override so macOS falls back
#  to its built-in default — cleaner than hardcoding "the default value".
#
#  NOT reverted (not "system settings", and not safely auto-undoable):
#    - Homebrew / installed packages   (use `brew uninstall` / `brew bundle cleanup`)
#    - oh-my-zsh                        (rm -rf ~/.oh-my-zsh)
#    - default browser/editor handlers  (reassign via System Settings or duti)
# ============================================================================

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO_DIR

# shellcheck source=lib/common.sh
source "$REPO_DIR/lib/common.sh"
# shellcheck source=config.sh
source "$REPO_DIR/config.sh"

# `defaults delete <domain> <key>` but don't treat "key was absent" as an error.
_ddelete() { defaults delete "$@" >/dev/null 2>&1 || true; }

restore_system() {
  # --- 1.1 Keyboard repeat -------------------------------------------------
  _ddelete NSGlobalDomain KeyRepeat
  _ddelete NSGlobalDomain InitialKeyRepeat
  _ddelete -g ApplePressAndHoldEnabled
  ok "keyboard: repeat & press-and-hold reset to defaults"

  # --- 1.2 Autocorrect / text substitutions -------------------------------
  _ddelete NSGlobalDomain NSAutomaticSpellingCorrectionEnabled
  _ddelete NSGlobalDomain NSAutomaticCapitalizationEnabled
  _ddelete NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled
  _ddelete NSGlobalDomain NSAutomaticDashSubstitutionEnabled
  _ddelete NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled
  ok "text: autocorrect & substitutions reset to defaults"

  # --- 1.3 Spotlight shortcut (⌘-Space = keys 64 & 65) --------------------
  # Re-enable both hotkeys. Full effect after logout/login.
  local hotkeys="$HOME/Library/Preferences/com.apple.symbolichotkeys.plist"
  local key
  for key in 64 65; do
    /usr/libexec/PlistBuddy \
      -c "Set :AppleSymbolicHotKeys:$key:enabled true" "$hotkeys" 2>/dev/null \
      || warn "could not re-enable Spotlight hotkey $key (may already be default)"
  done
  ok "spotlight: ⌘-Space shortcut re-enabled (log out/in to fully apply)"

  # --- 1.3b Spotlight indexing ----------------------------------------------
  if sudo mdutil -a -i on >/dev/null 2>&1; then
    ok "spotlight: indexing re-enabled on all volumes (will re-index)"
  else
    warn "could not re-enable Spotlight indexing (needs sudo)"
  fi

  # --- 1.4 Tap to click ----------------------------------------------------
  _ddelete com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking
  _ddelete -currentHost NSGlobalDomain com.apple.mouse.tapBehavior
  _ddelete NSGlobalDomain com.apple.mouse.tapBehavior
  _ddelete com.apple.AppleMultitouchTrackpad Clicking
  ok "trackpad: tap-to-click reset to default (off)"

  # --- 1.5 & 1.6 Dock ------------------------------------------------------
  # Deleting the whole dock domain restores macOS's default pinned apps AND
  # resets autohide/animation timings in one shot.
  _ddelete com.apple.dock
  ok "dock: reset to macOS defaults (pinned apps restored, autohide off)"

  killall Dock >/dev/null 2>&1 || true
  killall SystemUIServer >/dev/null 2>&1 || true
}

restore_startup() {
  if [[ ${#STARTUP_APPS[@]} -eq 0 ]]; then
    skip "no startup apps configured — nothing to remove"
    return 0
  fi
  local app
  for app in "${STARTUP_APPS[@]}"; do
    if osascript -e \
      "tell application \"System Events\" to delete login item \"$app\"" \
      >/dev/null 2>&1; then
      ok "removed login item: $app"
    else
      skip "login item not present: $app"
    fi
  done
}

main() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    err "macOS only"; exit 1
  fi
  sudo -v 2>/dev/null || warn "could not acquire sudo (Spotlight indexing restore will be skipped)"

  local steps=("$@")
  if [[ ${#steps[@]} -eq 0 ]]; then
    steps=(system startup)
  fi

  local s
  for s in "${steps[@]}"; do
    case "$s" in
      system)  run_step "Restore system settings" restore_system ;;
      startup) run_step "Remove login items"       restore_startup ;;
      *)       err "unknown step: $s (valid: system startup)" ;;
    esac
  done

  echo
  ok "Restore complete. Log out/in for keyboard & Spotlight changes to fully apply."
}

main "$@"
