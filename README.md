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

Run the setup interactively on an existing Ubuntu VM:

```bash
./setup-ubuntu
```

Installs required APT packages, Oh My Bash, Homebrew, cross-platform CLI and
developer packages, Node.js 24 through fnm, and pnpm.

For a new cloud-init-enabled Ubuntu VM, pass
`setup-ubuntu.cloud-config.yaml` as the instance's user-data. The configuration
installs the system prerequisites, preserves the image's default user, clones
this repository, and runs the same setup for that user during the first boot.

Wait for provisioning to finish from inside the VM:

```bash
cloud-init status --wait
```

If provisioning fails, inspect `/var/log/cloud-init.log` and
`/var/log/cloud-init-output.log`.

Both scripts are safe to rerun and may prompt for `sudo` access.
