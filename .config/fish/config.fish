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

alias ls="eza --icons=always --color=always --long --no-filesize --no-time --no-user" 

alias duckdb="~/.duckdb/duckdb"
alias cat=bat

starship init fish | source

zoxide init --cmd cd fish | source

function boot
  fortune | pokesay && yarn bootstrap:clean
end

function build
  fortune | pokesay && yarn build:all
end

function check
  fortune | pokesay && yarn tsc:check
end

function bb
  fortune | pokesay && boot && build
end

function bck
  fortune | pokesay && build && check
end

function bbc
  fortune | pokesay && bb && check
end

function sd
  fortune| pokesay && yarn start:dev
end

function bw
  fortune | pokesay && yarn build:watch
end

function typegen
  fortune | pokesay && yarn gt:gen
end

function syncent
  fortune | pokesay && yarn build:ent:sync
end

function genmigration
  fortune | pokesay && yarn sequelize migration:generate --name $argv[1]
end

function dockerUp
  docker compose --env-file=.env.development -f docker-compose-dev.yml up
end

function dockerPull
  docker compose --env-file=.env.development -f docker-compose-dev.yml pull
end


