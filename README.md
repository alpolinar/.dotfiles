# dotfiles config

This repository contains the configuration files and automated bootstrap setup for my macOS development environment, powered by [**mise**](https://mise.jdx.dev/) (`mise bootstrap` & `mise dotfiles`) and **Homebrew**.

## Included Applications & Tools

All workstation tools, GUI apps, fonts, and runtimes are declaratively configured in [`mise.toml`](./mise.toml):

### Core Prerequisites (Installed if missing)
- `git`
- `unzip`

### Homebrew Formulae (`[bootstrap.packages]`)
- `bat`
- `btop`
- `colima`
- `docker`
- `docker-buildx`
- `docker-compose`
- `eza`
- `fastfetch`
- `fd`
- `fish` (configured as the default shell in `kitty.conf`)
- `fzf`
- `gh`
- `lazydocker`
- `lazygit`
- `neovim` (LazyVim)
- `rift` (`acsandmann/tap/rift`)
- `ripgrep`
- `starship`
- `tmux` (with [TPM](https://github.com/tmux-plugins/tpm) via `[bootstrap.repos]`)
- `yazi`
- `zoxide`

### Homebrew Casks & Fonts (`[bootstrap.packages]`)
- `kitty`
- `font-caskaydia-cove-nerd-font`

### Language Runtimes (`[tools]`)
- `node = "lts"` (used by Neovim Mason LSP and web tooling)

---

## Automated Installation (`install.sh`)

Clone this repository and run `./install.sh`:

```bash
git clone git@github.com:alpolinar/.dotfiles.git ~/Dev/.dotfiles
cd ~/Dev/.dotfiles
./install.sh
```

### What `install.sh` does (in order):
1. **Homebrew & Core Prerequisites**: Ensures Homebrew is installed and checks for `git` and `unzip` (installing them only if missing).
2. **Package Audit**: Checks if any target tools already exist on the system (via Homebrew or another package manager). Already-installed packages are skipped while allowing the rest of the packages to install, and a summary prompt is displayed at the end of the run.
3. **Standalone `mise` Installation**: Removes Homebrew's `mise` formula if present and installs the official standalone binary via `curl -fsSL https://mise.run | sh`.
4. **Legacy GNU Stow Migration**: Cleanly migrates any legacy GNU Stow symlinks in `~/.config` and backs up conflicting files.
5. **`mise bootstrap`**:
   - Installs all `brew` formulae and `brew-cask` GUI apps/fonts.
   - Clones Tmux Plugin Manager (`tpm`) to `~/.tmux/plugins/tpm`.
   - Symlinks all dotfiles defined under `[dotfiles]` into `~/.config`.
6. **Post-Bootstrap Setup**:
   - Installs all configured `tmux` plugins headlessly via `~/.tmux/plugins/tpm/bin/install_plugins`.
   - Installs and starts the **Rift** window manager launchd service (`rift service install` & `rift service start`). On first run, grant macOS Accessibility permissions in **System Settings → Privacy & Security → Accessibility**, run `rift service restart`, and press `Alt + Z` to activate window tiling on the current space.

To preview what `install.sh` will do without making any changes:
```bash
./install.sh --dry-run
```

---

## Day-to-Day Usage with `mise`

Because `~/.config/mise/config.toml` is symlinked to `mise.toml`, you can run `mise` commands from anywhere:

```bash
# Check status of packages, repos, and dotfiles
mise bootstrap status
mise dotfiles status

# Apply changes after editing mise.toml
mise bootstrap

# Add a new Homebrew formula or cask to mise.toml
mise bootstrap packages use brew:jq
mise bootstrap packages use brew-cask:raycast

# Preview dotfile symlink differences
mise dotfiles diff
```

---

## ENV Variables

Create an environment file called `env` in `~/.config/sessions/env` and add the following:
 - `WORK_DIR=/your/work/dir/path`

Relative path works.

## tmux

[Tmux Plugin Manager (TPM)](https://github.com/tmux-plugins/tpm) is automatically cloned to `~/.tmux/plugins/tpm` and plugins are installed during `./install.sh`.
To manually reload or install plugins inside `tmux`, press `<prefix> + I` (configured prefix: `ctrl-s + I`).

## neovim

To install `mason LSP`, make sure `node` and `npm` are installed (e.g., via `mise use node@lts`).

---

## Uninstallation (`uninstall.sh`)

To unlink all managed dotfiles and remove TPM while keeping your installed applications:

```bash
./uninstall.sh
```

Additional flags:
- `./uninstall.sh --dry-run` — Preview what will be unlinked/removed without making changes.
- `./uninstall.sh --packages` — Also uninstall the Homebrew formulae and casks declared in `mise.toml`.
- `./uninstall.sh --all` — Unlink dotfiles, remove TPM, uninstall the Homebrew packages, and remove `mise`.
