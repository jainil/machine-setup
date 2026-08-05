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

Installs required APT packages, Oh My Zsh, Homebrew, and cross-platform CLI and
developer packages. It skips macOS preferences, GUI applications, fonts, and
editor extensions.

Both scripts are safe to rerun and may prompt for `sudo` access.
