#!/usr/bin/env bash
# ==============================================================================
# install.sh — Automated Dev Environment & Dotfiles Bootstrap
# Powered by mise (bootstrap, brew/brew-cask, repos, and dotfiles)
# ==============================================================================

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MISE_BIN="${HOME}/.local/bin/mise"
DRY_RUN=false

# Tracks packages that were skipped because they already exist on the system
SKIPPED_PACKAGES=()
# Tracks Homebrew formulae/casks that already exist outside Homebrew so we skip them
CONFLICTING_BREW_KEYS=()
# Tracks Homebrew formulae/casks that need to be installed when conflicts exist
PENDING_BREW_FORMULAE=()
PENDING_BREW_CASKS=()

for arg in "$@"; do
    case "$arg" in
        -n|--dry-run)
            DRY_RUN=true
            ;;
        -h|--help)
            cat <<EOF
Usage: ./install.sh [OPTIONS]

Options:
  -n, --dry-run   Preview all bootstrap steps without making changes
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

# ------------------------------------------------------------------------------
# Logging Helpers
# ------------------------------------------------------------------------------
info()  { printf "\033[1;34m[INFO]\033[0m  %s\n" "$*"; }
ok()    { printf "\033[1;32m[OK]\033[0m    %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m  %s\n" "$*"; }
err()   { printf "\033[1;31m[ERROR]\033[0m %s\n" "$*" >&2; }

run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        printf "\033[0;36m[DRY-RUN]\033[0m %s\n" "$*"
    else
        "$@"
    fi
}

# ------------------------------------------------------------------------------
# Package Manager Detection Helper
# Determines which package manager owns an existing binary path
# ------------------------------------------------------------------------------
detect_pkg_manager() {
    local bin_path="$1"
    if [ -z "$bin_path" ]; then
        echo "none"
        return
    fi

    local resolved_path="$bin_path"
    if [ -L "$bin_path" ]; then
        resolved_path="$(readlink "$bin_path" 2>/dev/null || echo "$bin_path")"
    fi

    case "$bin_path:$resolved_path" in
        */opt/homebrew/*|*/usr/local/Cellar/*|*/home/linuxbrew/*)
            echo "homebrew"
            ;;
        */.nix-profile/*|*/nix/store/*|*/run/current-system/sw/*)
            echo "nix"
            ;;
        */.cargo/bin/*)
            echo "cargo"
            ;;
        */.local/share/mise/*|*/mise/installs/*)
            echo "mise-registry"
            ;;
        */opt/local/*)
            echo "macports"
            ;;
        /usr/bin/*|/bin/*)
            echo "system"
            ;;
        *)
            echo "other ($bin_path)"
            ;;
    esac
}

# ------------------------------------------------------------------------------
# Step 1: Ensure Homebrew is in PATH (or install if missing)
# ------------------------------------------------------------------------------
setup_homebrew() {
    info "Checking Homebrew installation..."
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv bash)"
        ok "Homebrew found at /opt/homebrew/bin/brew"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv bash)"
        ok "Homebrew found at /usr/local/bin/brew"
    elif command -v brew >/dev/null 2>&1; then
        ok "Homebrew found at $(command -v brew)"
    else
        info "Homebrew not found. Installing Homebrew..."
        if [ "$DRY_RUN" = true ]; then
            printf "\033[0;36m[DRY-RUN]\033[0m /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"\n"
        else
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            if [ -x /opt/homebrew/bin/brew ]; then
                eval "$(/opt/homebrew/bin/brew shellenv bash)"
            elif [ -x /usr/local/bin/brew ]; then
                eval "$(/opt/homebrew/bin/brew shellenv bash)"
            fi
        fi
    fi
}

# ------------------------------------------------------------------------------
# Step 2: Check Prerequisites (git & unzip — install only if missing)
# ------------------------------------------------------------------------------
check_prerequisites() {
    info "Checking core prerequisites (curl, git, unzip)..."

    if ! command -v curl >/dev/null 2>&1; then
        err "curl is required to bootstrap the system."
        exit 1
    fi

    if command -v git >/dev/null 2>&1; then
        local git_path
        git_path="$(command -v git)"
        local git_mgr
        git_mgr="$(detect_pkg_manager "$git_path")"
        SKIPPED_PACKAGES+=("git (already exists at ${git_path} via ${git_mgr})")
    else
        info "git is missing. Installing git via Homebrew..."
        run_cmd brew install git
    fi

    if command -v unzip >/dev/null 2>&1; then
        local unzip_path
        unzip_path="$(command -v unzip)"
        local unzip_mgr
        unzip_mgr="$(detect_pkg_manager "$unzip_path")"
        SKIPPED_PACKAGES+=("unzip (already exists at ${unzip_path} via ${unzip_mgr})")
    else
        info "unzip is missing. Installing unzip via Homebrew..."
        run_cmd brew install unzip
    fi
}

# ------------------------------------------------------------------------------
# Step 3: Audit Dev Tools Across Package Managers Before Installing
# Skips packages that already exist via another package manager and allows the
# rest of the packages to install normally.
# ------------------------------------------------------------------------------
audit_existing_packages() {
    info "Checking dev environment tools before installation..."

    # Format: "binary_name:brew_formula_name"
    local cli_tools=(
        "bat:bat"
        "eza:eza"
        "fd:fd"
        "fish:fish"
        "fzf:fzf"
        "lazygit:lazygit"
        "nvim:neovim"
        "rg:ripgrep"
        "starship:starship"
        "tmux:tmux"
        "yazi:yazi"
        "zoxide:zoxide"
    )

    for entry in "${cli_tools[@]}"; do
        local bin_name="${entry%%:*}"
        local pkg_name="${entry##*:}"
        local bin_path
        bin_path="$(command -v "$bin_name" 2>/dev/null || true)"

        if [ -z "$bin_path" ]; then
            info "  - ${pkg_name}: queued for installation"
            PENDING_BREW_FORMULAE+=("$pkg_name")
            continue
        fi

        local manager
        manager="$(detect_pkg_manager "$bin_path")"
        if [ "$manager" = "homebrew" ]; then
            SKIPPED_PACKAGES+=("${pkg_name} (already installed via Homebrew at ${bin_path})")
        else
            CONFLICTING_BREW_KEYS+=("brew:${pkg_name}")
            SKIPPED_PACKAGES+=("${pkg_name} (already exists at ${bin_path} via ${manager})")
        fi
    done

    # Check GUI Casks & Fonts
    local installed_casks=""
    if command -v brew >/dev/null 2>&1; then
        installed_casks="$(brew list --cask -1 2>/dev/null || true)"
    fi

    # Format: "cask_short_name:cask_full_name:app_bundle_path"
    local casks=(
        "kitty:kitty:/Applications/kitty.app"
        "aerospace:nikitabobko/tap/aerospace:/Applications/AeroSpace.app"
    )
    for entry in "${casks[@]}"; do
        local cask_short="${entry%%:*}"
        local rest="${entry#*:}"
        local cask_full="${rest%%:*}"
        local app_path="${rest#*:}"

        if grep -qx "$cask_short" <<< "$installed_casks"; then
            SKIPPED_PACKAGES+=("${cask_short} (already installed via Homebrew Cask at ${app_path})")
        elif [ -d "$app_path" ]; then
            CONFLICTING_BREW_KEYS+=("brew-cask:${cask_full}")
            SKIPPED_PACKAGES+=("${cask_short} (already exists at ${app_path} outside Homebrew Cask)")
        else
            info "  - ${cask_short} (cask): queued for installation"
            PENDING_BREW_CASKS+=("$cask_full")
        fi
    done

    if grep -qx "font-caskaydia-cove-nerd-font" <<< "$installed_casks"; then
        SKIPPED_PACKAGES+=("font-caskaydia-cove-nerd-font (already installed via Homebrew Cask)")
    elif ls "${HOME}/Library/Fonts/"*CaskaydiaCove* /Library/Fonts/*CaskaydiaCove* >/dev/null 2>&1; then
        CONFLICTING_BREW_KEYS+=("brew-cask:font-caskaydia-cove-nerd-font")
        SKIPPED_PACKAGES+=("font-caskaydia-cove-nerd-font (already exists in system Fonts directory)")
    else
        info "  - font-caskaydia-cove-nerd-font (cask): queued for installation"
        PENDING_BREW_CASKS+=("font-caskaydia-cove-nerd-font")
    fi
}

# ------------------------------------------------------------------------------
# Step 4: Install mise via curl -fsSL https://mise.run | sh
# Replaces Homebrew mise formula if present
# ------------------------------------------------------------------------------
install_mise() {
    info "Checking mise installation..."

    export PATH="${HOME}/.local/bin:${PATH}"

    local installed_formulae=""
    if command -v brew >/dev/null 2>&1; then
        installed_formulae="$(brew list --formula -1 2>/dev/null || true)"
    fi

    if grep -qx "mise" <<< "$installed_formulae"; then
        warn "mise is currently installed via Homebrew. Removing Homebrew formula before installing standalone mise.run binary..."
        run_cmd brew uninstall mise
    fi

    if [ -x "$MISE_BIN" ]; then
        SKIPPED_PACKAGES+=("mise (standalone binary already exists at ${MISE_BIN})")
    else
        info "Installing mise via https://mise.run ..."
        if [ "$DRY_RUN" = true ]; then
            printf "\033[0;36m[DRY-RUN]\033[0m curl -fsSL https://mise.run | sh\n"
        else
            curl -fsSL https://mise.run | sh
            ok "Installed mise at ${MISE_BIN}"
        fi
    fi
}

# ------------------------------------------------------------------------------
# Step 5: Migrate Legacy GNU Stow Symlinks & Prepare ~/.config Targets
# ------------------------------------------------------------------------------
prepare_dotfiles_targets() {
    info "Preparing ~/.config targets for mise dotfiles..."
    run_cmd mkdir -p "${HOME}/.config" "${HOME}/.config/mise"

    # Handle ~/.config/kitty if GNU Stow created a directory of symlinks
    local kitty_dir="${HOME}/.config/kitty"
    local kitty_handled=false
    if [ -d "$kitty_dir" ] && [ ! -L "$kitty_dir" ]; then
        kitty_handled=true
        local has_non_symlink=false
        for item in "$kitty_dir"/*; do
            [ -e "$item" ] || [ -L "$item" ] || continue
            if [ ! -L "$item" ]; then
                has_non_symlink=true
                break
            fi
        done
        if [ "$has_non_symlink" = false ]; then
            info "Removing legacy Stow symlink directory at ${kitty_dir}..."
            run_cmd rm -rf "$kitty_dir"
        else
            local backup_kitty="${kitty_dir}.bak.$(date +%Y%m%d%H%M%S)"
            warn "Backing up existing ${kitty_dir} directory to ${backup_kitty}"
            run_cmd mv "$kitty_dir" "$backup_kitty"
        fi
    fi

    # Clean up remaining legacy relative Stow symlinks or back up conflicting files
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
        if [ "$target" = "$kitty_dir" ] && [ "$kitty_handled" = true ]; then
            continue
        fi
        if [ -L "$target" ]; then
            local link_dest
            link_dest="$(readlink "$target" || true)"
            case "$link_dest" in
                *".dotfiles/"*)
                    if [ "${link_dest#/}" = "$link_dest" ]; then
                        info "Removing legacy relative Stow symlink: ${target} -> ${link_dest}"
                        run_cmd rm "$target"
                    fi
                    ;;
            esac
        elif [ -e "$target" ]; then
            local backup="${target}.bak.$(date +%Y%m%d%H%M%S)"
            warn "Backing up existing non-symlink target ${target} to ${backup}"
            run_cmd mv "$target" "$backup"
        fi
    done
}

# ------------------------------------------------------------------------------
# Step 6: Run mise bootstrap (Packages -> Repos -> Dotfiles -> Tools)
# If any package already exists outside Homebrew, skips that package while
# installing the rest of the packages and applying repos, dotfiles, and tools.
# ------------------------------------------------------------------------------
run_mise_bootstrap() {
    info "Trusting ${DOTFILES_DIR}/mise.toml and running mise bootstrap..."
    local mise_cmd="${MISE_BIN}"
    if [ ! -x "$mise_cmd" ]; then
        mise_cmd="$(command -v mise)"
    fi

    run_cmd "$mise_cmd" trust "${DOTFILES_DIR}/mise.toml"

    if [ "${#CONFLICTING_BREW_KEYS[@]}" -gt 0 ]; then
        info "Installing non-conflicting packages while skipping already-existing non-Homebrew packages..."
        if [ "${#PENDING_BREW_FORMULAE[@]}" -gt 0 ]; then
            run_cmd brew install --formula "${PENDING_BREW_FORMULAE[@]}"
        fi
        if [ "${#PENDING_BREW_CASKS[@]}" -gt 0 ]; then
            run_cmd brew install --cask "${PENDING_BREW_CASKS[@]}"
        fi

        if [ "$DRY_RUN" = true ]; then
            "$mise_cmd" -C "$DOTFILES_DIR" bootstrap --skip packages --dry-run || "$mise_cmd" -C "$DOTFILES_DIR" dotfiles diff || true
        else
            "$mise_cmd" -C "$DOTFILES_DIR" bootstrap --skip packages --yes --force-dotfiles
            ok "mise bootstrap (repos, dotfiles, tools) completed successfully."
        fi
    else
        if [ "$DRY_RUN" = true ]; then
            "$mise_cmd" -C "$DOTFILES_DIR" bootstrap --dry-run || "$mise_cmd" -C "$DOTFILES_DIR" dotfiles diff || true
        else
            "$mise_cmd" -C "$DOTFILES_DIR" bootstrap --yes --force-dotfiles
            ok "mise bootstrap completed successfully."
        fi
    fi
}

# ------------------------------------------------------------------------------
# Step 7: Post-Bootstrap Tasks (TPM plugins, fish shell check)
# ------------------------------------------------------------------------------
post_bootstrap() {
    info "Running post-bootstrap configuration..."

    local tpm_install="${HOME}/.tmux/plugins/tpm/bin/install_plugins"
    if [ -x "$tpm_install" ]; then
        info "Installing tmux plugins via TPM..."
        run_cmd "$tpm_install"
        ok "Tmux plugins installed."
    elif [ "$DRY_RUN" = true ]; then
        printf "\033[0;36m[DRY-RUN]\033[0m ~/.tmux/plugins/tpm/bin/install_plugins\n"
    else
        warn "TPM install script not found at ${tpm_install}; run <prefix> + I inside tmux."
    fi

    local fish_bin="/opt/homebrew/bin/fish"
    if [ ! -x "$fish_bin" ] && command -v fish >/dev/null 2>&1; then
        fish_bin="$(command -v fish)"
    fi
    if [ -x "$fish_bin" ]; then
        ok "Fish shell is ready at ${fish_bin} (configured as default shell in kitty.conf)."
    fi
}

# ------------------------------------------------------------------------------
# Step 8: End-of-Run Prompt for Skipped / Already-Existing Packages
# ------------------------------------------------------------------------------
print_skipped_summary() {
    if [ "${#SKIPPED_PACKAGES[@]}" -gt 0 ]; then
        printf "\n\033[1;33m==============================================================================\033[0m\n"
        printf "\033[1;33m[NOTICE] Skipped Packages (Already Installed on System)\033[0m\n"
        printf "\033[1;33m==============================================================================\033[0m\n"
        printf "The following packages were not installed because they already exist:\n\n"
        for item in "${SKIPPED_PACKAGES[@]}"; do
            printf "  • %s\n" "$item"
        done
        printf "\033[1;33m==============================================================================\033[0m\n\n"
    fi
}

# ------------------------------------------------------------------------------
# Main Execution Flow
# ------------------------------------------------------------------------------
main() {
    info "Starting dotfiles bootstrap from ${DOTFILES_DIR}..."
    setup_homebrew
    check_prerequisites
    audit_existing_packages
    install_mise
    prepare_dotfiles_targets
    run_mise_bootstrap
    post_bootstrap
    print_skipped_summary
    ok "All done! Restart Kitty or open a new fish shell to enjoy your environment."
}

main "$@"
