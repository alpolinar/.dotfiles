if status is-interactive
    # Commands to run in interactive sessions can go here
end

function load_env
    while read -la line
        if echo $line | grep -q '^\s*#'
            continue
        end
        if test -z "$line"
            continue
        end
        set key (echo $line | cut -d '=' -f 1)
        set value (echo $line | cut -d '=' -f 2-)
        set key (string trim $key)
        set value (string trim $value)
        set -gx $key $value
    end <~/.config/sessions/env
end

load_env

set -g fish_greeting
set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml
set -gx LD_LIBRARY_PATH ~/.extra/sos
set -g VISUAL nvim
set -g EDITOR nvim
set -g WEBKIT_DISABLE_COMPOSITING_MODE 1
set -gx PATH /opt/homebrew/bin $PATH

function nvm
    bass source $NVM_PATH/nvm.sh --no-use ';' nvm $argv
end

set -x NVM_DIR ~/.nvm
nvm use default --silent

alias duckdb="~/.duckdb/duckdb"

starship init fish | source

zoxide init --cmd cd fish | source

function ls
    eza --icons=always --color=always --long --no-filesize --no-time --no-user $argv
end

function cat
    bat $argv
end

function boot
    pnpm bootstrap:clean
end

function build
    pnpm build:all
end

function check
    pnpm tsc:check
end

function bb
    boot && build
end

function bck
    build && check
end

function bbc
    bb && check
end

function sd
    pnpm start:dev
end

function bw
    pnpm build:watch
end

function gt
    pnpm gt:gen
end

function syncent
    pnpm build:ent:sync
end

function genmigration
    pnpm sequelize migration:generate --name $argv[1]
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
