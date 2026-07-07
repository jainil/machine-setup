#!/usr/bin/env bash
# ============================================================================
#  User-editable configuration. This is the only file you should normally
#  need to change. Sourced by setup.sh before any step runs.
# ============================================================================

# --- Default apps (outline §5) ----------------------------------------------
# Bundle IDs are used so a wrong app name is a one-line fix. Find one with:
#   osascript -e 'id of app "Helium"'
# Steps skip gracefully if the app isn't installed.
BROWSER_BUNDLE_ID="net.imput.helium"   # Helium browser — VERIFY on your machine
EDITOR_BUNDLE_ID="com.gram.Gram"        # Gram editor    — VERIFY on your machine

# File extensions the editor should own (used by `duti`).
EDITOR_EXTENSIONS=(
  txt md markdown log
  js jsx ts tsx json
  py rb go rs java c h cpp
  sh bash zsh
  html css scss yaml yml toml ini conf
)

# --- Startup / login items (outline §6) -------------------------------------
# App names (as shown in /Applications) to launch at login. Edit freely.
STARTUP_APPS=(
  # "Rectangle"
  # "Raycast"
)

# --- Keyboard (outline §1.1, §1.2) ------------------------------------------
KEY_REPEAT=1          # lower = faster (1 is the fastest the UI exposes as ~2)
INITIAL_KEY_REPEAT=15 # lower = shorter delay before repeat kicks in

# --- Dock (outline §1.5, §1.6) ----------------------------------------------
DOCK_AUTOHIDE=true            # hide the dock
DOCK_AUTOHIDE_TIME=0          # show/hide animation duration (0 = instant)
DOCK_AUTOHIDE_DELAY=0         # delay before it shows on hover (0 = instant)
DOCK_CLEAR_PINNED=true        # remove all default pinned app icons
