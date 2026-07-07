#!/usr/bin/env bash
# oh-my-zsh install (outline §2). Sourced by setup.sh.
# Exposes: step_zsh

step_zsh() {
  if [[ -d "${ZSH:-$HOME/.oh-my-zsh}" ]]; then
    skip "oh-my-zsh already installed"
    return 0
  fi

  if ! has_cmd curl; then
    err "curl not found — cannot install oh-my-zsh"
    return 1
  fi

  # Unattended: don't change the login shell or launch a new zsh session here.
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}
