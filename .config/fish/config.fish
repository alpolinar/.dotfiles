if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -g fish_greeting
set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml

function nvm
  bass source (brew --prefix nvm)/nvm.sh --no-use ';' nvm $argv
end

set -x NVM_DIR ~/.nvm
nvm use default --silent

alias ls="eza --icons=always --color=always --long --no-filesize --no-time --no-user --no-permissions"

alias cat=batcat

starship init fish | source

zoxide init --cmd cd fish | source

