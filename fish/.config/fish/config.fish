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
    echo "This is an enhanced version of ls. Use with care."
    eza --icons=always --color=always --long --no-filesize --no-time --no-user $argv
end

function cat
    echo "This is an enhanced version of cat. Use with care."
    bat $argv
end

set -gx PNPM_HOME "$HOME/.local/share/pnpm"
set -gx fish_user_paths $PNPM_HOME $fish_user_paths

switch (uname)
    case Darwin
        set -gx fish_user_paths /opt/homebrew/bin $fish_user_paths
end

mise activate fish | source
