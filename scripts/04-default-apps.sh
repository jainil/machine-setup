#!/usr/bin/env bash
# Default browser & editor handlers (outline §5). Sourced by setup.sh.
# Exposes: step_default_apps
# Uses: duti, defaultbrowser (installed via the Brewfile).

step_default_apps() {
  # --- Default browser (Helium) -------------------------------------------
  if ! app_installed "$BROWSER_BUNDLE_ID"; then
    warn "browser ($BROWSER_BUNDLE_ID) not installed — skipping default browser"
  elif has_cmd duti; then
    # Set both http and https URL schemes to the browser.
    duti -s "$BROWSER_BUNDLE_ID" http  all
    duti -s "$BROWSER_BUNDLE_ID" https all
    ok "default browser → $BROWSER_BUNDLE_ID"
  else
    warn "duti not found — cannot set default browser"
  fi

  # --- Default editor (Gram) for code files -------------------------------
  if ! app_installed "$EDITOR_BUNDLE_ID"; then
    warn "editor ($EDITOR_BUNDLE_ID) not installed — skipping default editor"
  elif has_cmd duti; then
    local ext
    for ext in "${EDITOR_EXTENSIONS[@]}"; do
      duti -s "$EDITOR_BUNDLE_ID" ".$ext" all 2>/dev/null \
        || warn "could not associate .$ext"
    done
    # Also claim the plain-text UTI for extensionless text files.
    duti -s "$EDITOR_BUNDLE_ID" public.plain-text all 2>/dev/null || true
    ok "default editor → $EDITOR_BUNDLE_ID (${#EDITOR_EXTENSIONS[@]} extensions)"
  else
    warn "duti not found — cannot set default editor"
  fi
}
