#!/usr/bin/env fish

set PACKAGE_ROOT "$FT100_WORKING_DIR/packages"
set SESSIONS \
    "editor:cd $FT100_WORKING_DIR" \
    "apps:cd $FT100_WORKING_DIR/packages"
# Iterate over the sessions
for SESSION in $SESSIONS
    # Split the session name and the command
    set NAME (echo $SESSION | cut -d ':' -f 1)
    set COMMAND (echo $SESSION | cut -d ':' -f 2-)
    # Check if the session already exists
    if tmux list-sessions | grep -q "^$NAME:"
        echo "Session $NAME already exists. Skipping."
    else
        tmux new-session -d -s "$NAME"
        if test $NAME = editor
            tmux send-keys "$COMMAND && nvim" C-m
        else if test $NAME = apps
            tmux split-window -h
            tmux send-keys -t 1 "$COMMAND/server" C-m
            tmux send-keys -t 2 "$COMMAND/frontend" C-m
        else
            tmux send-keys "$COMMAND" C-m
        end
        echo "Created tmux session: $NAME"
    end
end

# Attach to the first session
set FIRST_SESSION (echo $SESSIONS[1] | cut -d ':' -f 1)
echo "Attaching to the first session: $FIRST_SESSION"
tmux attach-session -t "$FIRST_SESSION"
