set valid_options asterisk co-working
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
            ~/.config/sessions/biggeo/asterisk.sh
        case co-working
            ~/.config/sessions/ods/co-working.sh
        case '*'
            echo "Invalid option: $action"
            echo "Valid options are: $valid_options"
            return 1
    end
end
