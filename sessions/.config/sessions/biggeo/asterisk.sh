#!/usr/bin/env fish

set PACKAGE_ROOT "$ASTERISK_DIR/packages"
set SESSIONS \
    "editor:cd $ASTERISK_DIR" \
    "root:cd $ASTERISK_DIR" \
    "docker:cd $ASTERISK_DIR/datascape-dev" \
    "files:cd ~/Documents" \
    "datascape:cd $PACKAGE_ROOT" \
    "studio:cd $PACKAGE_ROOT" \
    "etl:cd $PACKAGE_ROOT/bg-etl" \
    "basilisk:cd $PACKAGE_ROOT"

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
    if test $NAME = "root"
      tmux send-keys "$COMMAND" C-m
    else if test $NAME = "docker"
      tmux split-window -h
      tmux send-keys -t 1 "$COMMAND" C-m
      tmux send-keys -t 2 "$COMMAND && lazydocker" C-m
    else if test $NAME = "datascape"
      tmux split-window -h
      tmux send-keys -t 1 "$COMMAND/bg-sf-server" C-m
      tmux send-keys -t 2 "$COMMAND/bg-spa-frontend" C-m
    else if test $NAME = "studio"
      tmux split-window -h
      tmux send-keys -t 1 "$COMMAND/bg-studio-server" C-m
      tmux send-keys -t 2 "$COMMAND/bg-studio" C-m
    else if test $NAME = "editor"
      tmux send-keys "$COMMAND && nvim" C-m
    else if test $NAME = "basilisk"
      tmux split-window -h
      tmux send-keys -t 1 "$COMMAND/bg-basilisk-board" C-m
      tmux send-keys -t 2 "$COMMAND/bg-basilisk-consumer" C-m
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
