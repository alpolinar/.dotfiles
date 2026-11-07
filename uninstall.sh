#!/usr/bin/env bash
# ==============================================================================
# uninstall.sh — Teardown & Unlink Script for Dotfiles & Dev Environment
# ==============================================================================

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MISE_BIN="${HOME}/.local/bin/mise"
DRY_RUN=false
REMOVE_PACKAGES=false
REMOVE_MISE=false

for arg in "$@"; do
    case "$arg" in
        -n|--dry-run)
            DRY_RUN=true
            ;;
        --packages)
            REMOVE_PACKAGES=true
            ;;
        --all)
            REMOVE_PACKAGES=true
            REMOVE_MISE=true
            ;;
        -h|--help)
            cat <<EOF
Usage: ./uninstall.sh [OPTIONS]

Default behavior:
  Unlinks dotfiles deployed by mise and removes Tmux Plugin Manager (TPM).

Options:
  -n, --dry-run   Preview all uninstall steps without making changes
  --packages      Also uninstall Homebrew formulae and casks from mise.toml
  --all           Uninstall dotfiles, TPM, Homebrew packages, and mise itself
  -h, --help      Show this help message
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $arg" >&2
            exit 1
            ;;
    esac
done

info()  { printf "\033[1;34m[INFO]\033[0m  %s\n" "$*"; }
ok()    { printf "\033[1;32m[OK]\033[0m    %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m  %s\n" "$*"; }

run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        printf "\033[0;36m[DRY-RUN]\033[0m %s\n" "$*"
    else
        "$@"
    fi
}

# ------------------------------------------------------------------------------
# Step 1: Unapply Dotfiles Managed by mise
# ------------------------------------------------------------------------------
unapply_dotfiles() {
    info "Unlinking dotfiles managed by mise..."
    export PATH="${HOME}/.local/bin:${PATH}"

    # Clean up ~/.config/kitty if it is a directory of legacy Stow symlinks
    local kitty_dir="${HOME}/.config/kitty"
    if [ -d "$kitty_dir" ] && [ ! -L "$kitty_dir" ]; then
        local has_non_symlink=false
        for item in "$kitty_dir"/*; do
            [ -e "$item" ] || [ -L "$item" ] || continue
            if [ ! -L "$item" ]; then
                has_non_symlink=true
                break
            fi
        done
        if [ "$has_non_symlink" = false ]; then
            info "Removing legacy Stow symlink directory: ${kitty_dir}"
            run_cmd rm -rf "$kitty_dir"
        fi
    fi

    # Remove any symlinks pointing to DOTFILES_DIR or legacy ~/.dotfiles
    local targets=(
        "${HOME}/.config/aerospace"
        "${HOME}/.config/fish"
        "${HOME}/.config/kitty"
        "${HOME}/.config/lazygit"
        "${HOME}/.config/nvim"
        "${HOME}/.config/sessions"
        "${HOME}/.config/starship"
        "${HOME}/.config/tmux"
        "${HOME}/.config/yazi"
        "${HOME}/.config/mise/config.toml"
    )

    for target in "${targets[@]}"; do
        if [ -L "$target" ]; then
            local dest
            dest="$(readlink "$target" || true)"
            case "$dest" in
                *"${DOTFILES_DIR}"*|*".dotfiles"*)
                    info "Removing symlink: ${target} -> ${dest}"
                    run_cmd rm "$target"
                    ;;
            esac
        fi
    done

    local mise_cmd=""
    if [ -x "$MISE_BIN" ]; then
        mise_cmd="$MISE_BIN"
    elif command -v mise >/dev/null 2>&1; then
        mise_cmd="$(command -v mise)"
    fi

    if [ -n "$mise_cmd" ]; then
        if [ "$DRY_RUN" = true ]; then
            "$mise_cmd" -C "$DOTFILES_DIR" dotfiles unapply --dry-run 2>/dev/null || true
        else
            "$mise_cmd" -C "$DOTFILES_DIR" dotfiles unapply --yes 2>/dev/null || true
        fi
    fi

    ok "Dotfiles unlinked."
}

# ------------------------------------------------------------------------------
# Step 2: Remove Tmux Plugin Manager (TPM)
# ------------------------------------------------------------------------------
remove_tpm() {
    local tpm_dir="${HOME}/.tmux/plugins/tpm"
    if [ -d "$tpm_dir" ]; then
        info "Removing Tmux Plugin Manager at ${tpm_dir}..."
        run_cmd rm -rf "$tpm_dir"
        ok "Removed ${tpm_dir}"
    else
        info "TPM directory (${tpm_dir}) not present — skipping."
    fi
}

# ------------------------------------------------------------------------------
# Step 3: Optionally Uninstall Bootstrapped Homebrew Packages & Casks
# ------------------------------------------------------------------------------
uninstall_packages() {
    if [ "$REMOVE_PACKAGES" = false ]; then
        info "Skipping Homebrew package removal (pass --packages or --all to uninstall packages)."
        return
    fi

    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv bash)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv bash)"
    fi

    if ! command -v brew >/dev/null 2>&1; then
        warn "Homebrew not found; skipping package uninstall."
        return
    fi

    local installed_formulae
    installed_formulae="$(brew list --formula -1 2>/dev/null || true)"
    local installed_casks
    installed_casks="$(brew list --cask -1 2>/dev/null || true)"

    local formulae=(
        bat eza fd fish fzf lazygit neovim ripgrep starship tmux yazi zoxide
    )
    local casks=(
        font-caskaydia-cove-nerd-font kitty aerospace
    )

    info "Uninstalling bootstrapped Homebrew formulae..."
    for pkg in "${formulae[@]}"; do
        if grep -qx "$pkg" <<< "$installed_formulae"; then
            run_cmd brew uninstall --formula "$pkg"
        fi
    done

    info "Uninstalling bootstrapped Homebrew casks..."
    for cask in "${casks[@]}"; do
        if grep -qx "$cask" <<< "$installed_casks"; then
            run_cmd brew uninstall --cask "$cask"
        fi
    done

    ok "Bootstrapped Homebrew packages uninstalled."
}

# ------------------------------------------------------------------------------
# Step 4: Optionally Remove mise
# ------------------------------------------------------------------------------
uninstall_mise() {
    if [ "$REMOVE_MISE" = false ]; then
        return
    fi

    info "Removing mise binary and data directories..."
    if [ -x "$MISE_BIN" ]; then
        run_cmd rm -f "$MISE_BIN"
    fi
    run_cmd rm -rf "${HOME}/.local/share/mise" "${HOME}/.local/state/mise" "${HOME}/.cache/mise"
    ok "Removed mise."
}

main() {
    info "Starting uninstall for ${DOTFILES_DIR}..."
    unapply_dotfiles
    remove_tpm
    uninstall_packages
    uninstall_mise
    ok "Uninstall complete."
}

main "$@"
