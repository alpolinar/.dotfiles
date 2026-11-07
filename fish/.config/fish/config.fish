# ==============================================================================
# Environment Variables & PATH
# ==============================================================================
set -gx VISUAL nvim
set -gx EDITOR nvim
set -gx STARSHIP_CONFIG "$HOME/.config/starship/starship.toml"
set -gx WEBKIT_DISABLE_COMPOSITING_MODE 1
set -gx PNPM_HOME "$HOME/.local/share/pnpm"

# fish_add_path deduplicates and silently skips directories that do not exist
fish_add_path -g \
    /opt/homebrew/bin \
    /opt/homebrew/sbin \
    "$HOME/.local/bin" \
    "$PNPM_HOME" \
    "$HOME/.antigravity/antigravity/bin" \
    "$HOME/.antigravity-ide/antigravity-ide/bin"

# ==============================================================================
# Interactive Session Configuration
# ==============================================================================
if status is-interactive
    set -g fish_greeting

    command -q starship; and starship init fish | source
    command -q zoxide; and zoxide init --cmd cd fish | source
    command -q mise; and mise activate fish | source
end
