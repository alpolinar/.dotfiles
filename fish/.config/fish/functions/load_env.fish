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
