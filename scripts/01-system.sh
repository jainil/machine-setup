#!/usr/bin/env bash
# System Settings via `defaults` (outline §1). Sourced by setup.sh.
# Exposes: step_system

step_system() {
  # --- 1.1 Fast keyboard repeat -------------------------------------------
  defaults write NSGlobalDomain KeyRepeat -int "$KEY_REPEAT"
  defaults write NSGlobalDomain InitialKeyRepeat -int "$INITIAL_KEY_REPEAT"
  # Disable press-and-hold accent menu so keys repeat instead.
  defaults write -g ApplePressAndHoldEnabled -bool false
  ok "keyboard: fast repeat (KeyRepeat=$KEY_REPEAT, InitialKeyRepeat=$INITIAL_KEY_REPEAT)"

  # --- 1.2 Disable completions (autocorrect / text substitutions) ---------
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  ok "text: disabled autocorrect & substitutions"

  # --- 1.3 Disable Spotlight shortcut (⌘-Space = keys 64 & 65) ------------
  # Full effect requires logout/login.
  local hotkeys="$HOME/Library/Preferences/com.apple.symbolichotkeys.plist"
  local key
  for key in 64 65; do
    /usr/libexec/PlistBuddy \
      -c "Set :AppleSymbolicHotKeys:$key:enabled false" "$hotkeys" 2>/dev/null \
      || /usr/libexec/PlistBuddy \
        -c "Add :AppleSymbolicHotKeys:$key:enabled bool false" "$hotkeys" 2>/dev/null \
      || warn "could not disable Spotlight hotkey $key"
  done
  ok "spotlight: ⌘-Space shortcut disabled (log out/in to fully apply)"

  # --- 1.3b Disable Spotlight indexing on all volumes ---------------------
  # Stops mdworker from indexing entirely (not just the ⌘-Space UI). Needs
  # sudo; app_installed()'s mdfind lookup falls back to osascript when this
  # is off.
  if sudo mdutil -a -i off >/dev/null 2>&1; then
    ok "spotlight: indexing disabled on all volumes"
  else
    warn "could not disable Spotlight indexing (needs sudo)"
  fi

  # --- 1.4 Enable tap to click --------------------------------------------
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  # Built-in trackpad domain (some Macs use this instead of the Bluetooth one).
  defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true 2>/dev/null || true
  ok "trackpad: tap-to-click enabled"

  # --- 1.5 Remove all default pinned dock icons and hide recents ----------
  if [[ "$DOCK_CLEAR_PINNED" == true ]]; then
    defaults write com.apple.dock persistent-apps -array
    defaults write com.apple.dock show-recents -bool false
    ok "dock: cleared pinned app icons"
  fi

  # --- 1.6 Dock hidden + no show/hide animation ---------------------------
  defaults write com.apple.dock autohide -bool "$DOCK_AUTOHIDE"
  defaults write com.apple.dock autohide-time-modifier -float "$DOCK_AUTOHIDE_TIME"
  defaults write com.apple.dock autohide-delay -float "$DOCK_AUTOHIDE_DELAY"
  ok "dock: autohide=$DOCK_AUTOHIDE, no show/hide animation"

  # --- Apply ---------------------------------------------------------------
  killall Dock >/dev/null 2>&1 || true
  killall SystemUIServer >/dev/null 2>&1 || true
}
