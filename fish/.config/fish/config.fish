if status is-interactive
    # Commands to run in interactive sessions can go here
end

load_env

set -g fish_greeting
set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml
set -g VISUAL nvim
set -g EDITOR nvim
set -g WEBKIT_DISABLE_COMPOSITING_MODE 1

starship init fish | source

zoxide init --cmd cd fish | source

function ls
    eza --icons=always --color=always --long --no-filesize --no-time --no-user $argv
end

function cat
    bat $argv
end

set -Ux PNPM_HOME "$HOME/.local/share/pnpm"
set -Ua fish_user_paths $PNPM_HOME

mise activate fish | source
