if status is-interactive
    # Commands to run in interactive sessions can go here
end

load_env

set -g fish_greeting
set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml
set -g VISUAL nvim
set -g EDITOR nvim
set -g WEBKIT_DISABLE_COMPOSITING_MODE 1

function nvm
    bass source $NVM_PATH/nvm.sh --no-use ';' nvm $argv
end

set -x NVM_DIR ~/.nvm
nvm use default --silent

starship init fish | source

zoxide init --cmd cd fish | source

function ls
    eza --icons=always --color=always --long --no-filesize --no-time --no-user $argv
end

function cat
    bat $argv
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# pnpm
set -gx PNPM_HOME "/home/aru/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end

# go
set --export PATH /usr/local/go/bin $PATH

# depot
set --export DEPOT_INSTALL_DIR "/home/alpolinar/.depot/bin"
set --export PATH "$DEPOT_INSTALL_DIR:$PATH"
