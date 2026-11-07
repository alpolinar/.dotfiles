function ls --wraps=eza --description "Enhanced ls via eza"
    echo "This is an enhanced version of ls. Use with care."
    eza --icons=always --color=always --long --no-filesize --no-time --no-user $argv
end