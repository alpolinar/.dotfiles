set valid_options asterisk co-working ft100
function session
    set action $argv[1]
    if not contains $action $valid_options
        if set -q action
            set action undefined
        end
        echo "Invalid option: $action"
        echo "Valid options are: $valid_options"
        return 1
    end
    switch $action
        case asterisk
            ~/.config/sessions/asterisk/asterisk.fish
        case co-working
            ~/.config/sessions/ods/co-working.fish
        case ft100
            ~/.config/sessions/ft100/ft100.fish
        case '*'
            echo "Invalid option: $action"
            echo "Valid options are: $valid_options"
            return 1
    end
end
