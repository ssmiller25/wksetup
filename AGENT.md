# AGENT.md - Workstation Setup Repository

## Repository Overview

This repository contains automated workstation setup scripts designed to bootstrap development environments from a fresh OS installation. The primary goal is to get systems into a "usable" state where additional tooling from [ssmiller25/toolbox](https://github.com/ssmiller25/toolbox) can be deployed.

## Purpose

- **OUT OF BOX**: Run scripts on fresh OS installations without prerequisites
- **MINIMAL**: Focus on essential tools; most work happens in cloud or local containers
- **IDEMPOTENT**: Scripts can be run multiple times safely without side effects
- **SIMPLE**: Prefer one tool that does one thing well, is immediately understandable, and just works

## Guiding Principles (Terminal Environment)

The target terminal environment is deliberately small and simple:

- **Terminal**: Ghostty with the Monofur Nerd Font
- **Editor**: Neovim with LazyVim, run inside the terminal
- **CLI essentials**: `fd`, `ripgrep`, `bat`, `jq`, `yq`
- **Shell**: zsh
- **Git**: SSH-signed commits and tags

See `notes/terminal-environment.md` (in the `lifeos/bjournalob` notes repo) for the full rationale.

## Repository Structure

```
wksetup/
├── setup-mac.sh           # macOS setup script (primary, actively maintained)
├── setup-popos.sh         # Pop!_OS/Ubuntu setup script (legacy)
├── common/                # Shared utility functions
│   ├── common             # Common helper functions (dir_exists, cmd_exists, h1, etc.)
│   ├── setup_ssh          # SSH key generation and setup
│   └── immutabledesktop   # Ansible and immutabledesktop repo setup
├── old/                   # Archived/deprecated scripts
├── AGENT.md               # This file, providing a technical overview of the repository
└── README.md              # User-facing documentation
```

## Key Scripts

### setup-mac.sh (Primary Script)

**Purpose**: Automate macOS workstation setup from fresh install

**Environment Variables**:
- `MYHOSTNAME` - Hostname for the system (default: "rory-mac-2025")
- `MYDOMAIN` - Domain name (default: "r15cookie.lan")

**Usage**:
```sh
curl -fsSL https://raw.githubusercontent.com/ssmiller25/wksetup/main/setup-mac.sh | sh
```

**What It Installs**:

*System Configuration*:
- Sets hostname and domain
- Changes default shell to zsh
- Generates an ed25519 SSH key
- Configures ssh-agent with macOS keychain (no repeated passphrase prompts)
- Configures git for opt-in SSH signing of commits and tags
- Creates ~/tmp directory
- Configures display preferences in menu bar

*Package Manager*:
- Homebrew (with shell environment setup)

*Terminal & CLI Tools*:
- Ghostty (terminal) with Monofur Nerd Font and managed config
- jq (JSON processor)
- yq (YAML processor)
- fd (fast find)
- ripgrep (fast search)
- bat (better cat)
- fzf (fuzzy finder)
- nmap (network scanner)
- ipcalc (IP calculator)
- gh (GitHub CLI)
- bitwarden-cli (password manager)
- opencode (AI code assistant)

*Editor*:
- Neovim
- LazyVim starter configuration (~/.config/nvim)

*Development Tools*:
- Visual Studio Code
- kubectl & helm (Kubernetes)
- Podman & podman-compose (container runtime)
- Podman Desktop
- DevPod (development environments)
- DBeaver (database GUI)
- civo CLI (cloud provider)

*Productivity Apps*:
- Slack
- Discord
- Zoom
- Rectangle (window manager)
- Obsidian (notes)

*Utilities*:
- balenaEtcher (USB creation)
- Ungoogled Chromium (browser)
- Wireguard tools (VPN)

**Important Notes**:
- Script may require multiple runs due to required reboots (especially after hostname changes)
- Docker Desktop section is commented out; Podman is preferred
- iTerm2 section is commented out; Ghostty is preferred
- DevPod setup requires manual configuration (see script comments)
- Script uses idempotency checks (cmd_exists, dir_exists) before each installation

**Git Commit Signing (manual step)**:

The script configures everything locally, but the signing key must be registered
with GitHub manually:

```
GitHub → Settings → SSH and GPG keys → New SSH key → Key type: Signing Key
```

(A signing key is separate from an auth key, though the same key can do both.)

The script sets the following git configuration:

```sh
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers
```

Signing is **opt-in**: the script does not set `commit.gpgsign`/`tag.gpgsign`,
so sign per command with `git commit -S` or `git tag -s`.

It also appends the key to `~/.config/git/allowed_signers` so tags and commits
can be verified locally. To verify a signed tag:

```sh
git tag -s test-signing -m "test signing"
git verify-tag test-signing          # expect: Good "git" signature
git tag -d test-signing              # cleanup
```

GitHub shows a signed tag/commit as **Verified**.

### setup-popos.sh (Legacy Script)

**Purpose**: Automate Pop!_OS 20.04 setup

**Requirements**: Pop!_OS 20.04 (enforced by script)

**What It Does**:
- Verifies Pop!_OS 20.04
- Sets hostname to "rory-mac"
- Generates SSH keys
- Performs OS updates (apt-get)
- Installs Ansible
- Clones immutabledesktop repository

**Usage**: Run as regular user (not root)

## Common Utilities

### common/common
Shared shell functions used by other scripts:
- `dir_exists()`: Checks if a directory exists.
- `cmd_exists()`: Checks if a command is available in the system's PATH.
- `is_root()`: Checks if the script is being run by the root user.
- `h1()`: Prints a formatted header to the console.
- `error_exit()`: Prints an error message to stderr and exits the script.

### common/setup_ssh
- `setup_ssh()`:
  - Checks for the existence of `${HOME}/.ssh/id_ed25519`.
  - If the key does not exist, it generates a new ed25519 SSH key pair.
  - Prompts the user to add the new public key to their GitHub/GitLab accounts.

### common/immutabledesktop
This script contains functions for setting up an "immutable desktop" environment, primarily for Pop!_OS.
- `install_ansible()`: Installs the Ansible configuration management tool using `apt-get`.
- `immutable_repo()`:
  - Clones the `ssmiller25/immutabledesktop` repository from GitHub into `~/git/ssmiller25/immutabledesktop`.
  - Creates the parent directories if they do not exist.
  - Checks if the repository has already been cloned to ensure idempotency.

## Workflow

### macOS Setup Flow
1. User runs curl command to download and execute setup-mac.sh
2. Script sets hostname (may require reboot)
3. User re-runs script after reboot
4. Script generates an ed25519 SSH key and configures git commit/tag signing
5. Script installs Homebrew if not present
6. Script installs all applications and tools, including Ghostty, Neovim/LazyVim, and the streamlined CLI set
7. User manually registers the SSH key as a signing key on GitHub (see Git Commit Signing)
8. User manually configures specific tools (DevPod, Bitwarden, etc.)
9. System is ready for toolbox deployment

### Pop!_OS Setup Flow
1. User runs setup-popos.sh
2. Script verifies OS version
3. Sets hostname (requires reboot)
4. User reboots and re-runs script
5. Generates SSH keys
6. Updates OS packages
7. Installs Ansible
8. Clones immutabledesktop repository
9. Ready for Ansible playbooks

## Design Philosophy

### Idempotency
All scripts check for existing installations before attempting to install. This allows:
- Safe re-execution after failures
- Incremental setup over multiple sessions
- Recovery from interrupted installations

### Minimal Dependencies
- macOS script uses `/bin/sh` (not zsh) for out-of-box compatibility
- Pop!_OS script uses standard apt-get
- No complex dependency chains

### Modular Structure
- Common functions are extracted to shared files
- Platform-specific logic in separate scripts
- Clear separation of concerns

## Integration Points

This repository is part of a larger ecosystem:
- **Upstream**: Fresh OS installation
- **Downstream**: [ssmiller25/toolbox](https://github.com/ssmiller25/toolbox) - Additional tooling and personalized environments
- **Related**: immutabledesktop repository (referenced in Pop!_OS setup)

## Maintenance Notes

### Active Development
- `setup-mac.sh` is actively maintained for current macOS versions
- Script targets personal workstation setup for "rory-mac-2025"

### Legacy/Deprecated
- `setup-popos.sh` targets Pop!_OS 20.04 (2020 release, may be outdated)
- `old/` directory contains archived scripts

### Future Considerations
- Pop!_OS setup marked as TODO in README
- Consider updating Pop!_OS script for newer Ubuntu/Pop!_OS versions
- Potential for additional platform support

## Debugging

Enable debug mode in macOS script:
```sh
# Uncomment line 10 in setup-mac.sh
set -x
```

## Security Considerations

- Scripts download and execute code from GitHub
- SSH keys are generated with ed25519
- User is prompted to import SSH public keys to GitHub/GitLab
- Git commits and tags can be signed via SSH (opt-in); the signing key must be registered manually
- No secrets or credentials stored in repository
- Scripts run with user permissions (sudo only when required)
