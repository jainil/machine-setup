#!/usr/bin/env bash
# Login items / startup apps (outline §6). Sourced by setup.sh.
# Exposes: step_startup_apps

step_startup_apps() {
  if [[ ${#STARTUP_APPS[@]} -eq 0 ]]; then
    skip "no startup apps configured (edit STARTUP_APPS in config.sh)"
    return 0
  fi

  local app existing
  existing="$(osascript -e \
    'tell application "System Events" to get the name of every login item' 2>/dev/null)"

  for app in "${STARTUP_APPS[@]}"; do
    if [[ ",$existing," == *", $app,"* ]] || [[ "$existing" == *"$app"* ]]; then
      skip "login item already present: $app"
      continue
    fi
    if osascript -e \
      "tell application \"System Events\" to make login item at end with properties {path:\"/Applications/$app.app\", hidden:false}" \
      >/dev/null 2>&1; then
      ok "added login item: $app"
    else
      warn "could not add login item: $app (is /Applications/$app.app present?)"
    fi
  done
}
