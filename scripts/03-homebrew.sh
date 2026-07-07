#!/usr/bin/env bash
# Homebrew install + `brew bundle` (outline §3, §4). Sourced by setup.sh.
# Exposes: step_homebrew
# Requires: REPO_DIR (set by setup.sh)

# Locate brew across Apple Silicon (/opt/homebrew) and Intel (/usr/local).
_brew_shellenv() {
  local prefix
  for prefix in /opt/homebrew /usr/local; do
    if [[ -x "$prefix/bin/brew" ]]; then
      eval "$("$prefix/bin/brew" shellenv)"
      return 0
    fi
  done
  return 1
}

step_homebrew() {
  # --- Install Homebrew if missing ----------------------------------------
  if ! has_cmd brew && ! _brew_shellenv; then
    log "installing Homebrew"
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
      || { err "Homebrew install failed"; return 1; }
    _brew_shellenv || { err "brew not found after install"; return 1; }
  else
    _brew_shellenv || true
    skip "Homebrew already installed"
  fi

  # --- Persist shellenv to ~/.zprofile (idempotent) -----------------------
  local brew_bin; brew_bin="$(command -v brew)"
  local shellenv_line="eval \"\$(${brew_bin} shellenv)\""
  if ! grep -qF "$shellenv_line" "$HOME/.zprofile" 2>/dev/null; then
    printf '\n%s\n' "$shellenv_line" >> "$HOME/.zprofile"
    ok "added brew shellenv to ~/.zprofile"
  fi

  # --- Install packages from the Brewfile ---------------------------------
  local brewfile="$REPO_DIR/Brewfile"
  if [[ -f "$brewfile" ]]; then
    log "brew bundle (bottles, casks, fonts)"
    brew bundle --file="$brewfile" || warn "some brew bundle entries failed"
  else
    warn "no Brewfile at $brewfile — skipping package install"
  fi

  post_brew
}

# Post-install follow-ups (outline §4.1). Extend as needed.
post_brew() {
  # Example follow-ups (uncomment / add as your setup grows):
  # [[ -x "$(brew --prefix)/bin/zsh" ]] && sudo sh -c "echo $(brew --prefix)/bin/zsh >> /etc/shells"
  :
}
