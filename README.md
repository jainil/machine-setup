# Machine setup

Standalone, repeatable setup scripts for a new Mac or Ubuntu VM.

## macOS

```bash
./setup-mac
```

Configures keyboard, text input, Spotlight, trackpad, and Dock preferences;
then installs Oh My Zsh, Homebrew, command-line tools, applications, fonts, and
developer packages. Log out and back in afterward to apply all preferences.

## Ubuntu VM

```bash
./setup-ubuntu
```

Installs required APT packages, Oh My Bash, Homebrew, cross-platform CLI and
developer packages, Node.js 24 through fnm, and pnpm.

Both scripts are safe to rerun and may prompt for `sudo` access.
