# mac-setup

Modular, **idempotent** scripts to bring a fresh Mac to a known-good state.
Implements the checklist in [`macsetup-outline.md`](./macsetup-outline.md).

## Quick start

```bash
git clone <this repo> ~/mac-setup && cd ~/mac-setup

# 1. Edit your preferences (the only file you normally touch):
$EDITOR config.sh      # bundle IDs, startup apps, keyboard/dock values
$EDITOR Brewfile       # packages to install

# 2. Run everything:
./setup.sh

# ...or run individual sections:
./setup.sh system zsh
```

Steps: `system`, `zsh`, `homebrew`, `apps`, `startup`. Every step checks before
acting, so re-running is safe.

## What each step does

| Step       | Outline | Actions |
|------------|---------|---------|
| `system`   | §1 | Fast key repeat, disable autocorrect/substitutions, disable ⌘-Space Spotlight shortcut and all Spotlight indexing, tap-to-click, clear pinned dock icons, autohide dock with no animation |
| `zsh`      | §2 | Installs oh-my-zsh unattended (skips if present) |
| `homebrew` | §3–4 | Installs Homebrew (Apple Silicon & Intel), then `brew bundle` from the `Brewfile` |
| `apps`     | §5 | Sets default browser (Helium) and code-file editor (Gram) via `duti` |
| `startup`  | §6 | Adds configured apps as login items |

## Layout

```
setup.sh            orchestrator (run all or named steps)
config.sh           user-editable knobs
Brewfile            packages (bottles / casks / fonts)
lib/common.sh       logging + idempotency helpers
scripts/01-05*.sh   one file per section
```

## Notes & caveats

- **Log out/in** for the Spotlight shortcut and keyboard changes to fully apply.
- **Spotlight indexing is disabled system-wide** (`mdutil -a -i off`, needs sudo — `setup.sh`
  prompts for it up front). This makes `mdfind`/Spotlight search stop returning results;
  `app_installed()` in `lib/common.sh` falls back to `osascript` when that happens.
  Run `./restore.sh system` to re-enable indexing (triggers a re-index, which takes a while).
- **Helium / Gram**: default-app wiring uses **bundle IDs** in `config.sh`. Verify them with
  `osascript -e 'id of app "Helium"'`. If either app isn't a Homebrew cask, install it manually —
  step `apps` skips gracefully until the app is present.
- Non-fatal errors don't abort the run; a summary of failed steps prints at the end.
- Requires macOS with Xcode Command Line Tools (the script prompts to install them if missing).
