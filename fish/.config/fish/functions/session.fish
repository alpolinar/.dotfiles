set valid_options biggeo
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
        case biggeo
            ~/.config/sessions/bg_asterisk/bg_asterisk.sh
        case '*'
            echo "Invalid option: $action"
            echo "Valid options are: $valid_options"
            return 1
    end
end
