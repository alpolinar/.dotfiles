#!/usr/bin/env fish

set WORK_DIR "~/Documents/dev/bg-search-demo"
set PACKAGE_ROOT "$WORK_DIR/packages"
set SESSIONS \
    "editor:cd $WORK_DIR" \
    "root:cd $WORK_DIR" \
    "docker:cd $WORK_DIR/datascape-dev" \
    "files:cd ~/Documents" \
    "datascape:cd $PACKAGE_ROOT" \
    "studio:cd $PACKAGE_ROOT" \
    "etl:cd $PACKAGE_ROOT/bg-etl"

# Iterate over the sessions
for SESSION in $SESSIONS
  # Split the session name and the command
  set NAME (echo $SESSION | cut -d ':' -f 1)
  set COMMAND (echo $SESSION | cut -d ':' -f 2-)
  # Check if the session already exists
  if tmux list-sessions | grep -q "^$NAME:" ^/dev/null
    echo "Session $NAME already exists. Skipping."
  else
    # Create a new session and start a shell
    tmux new-session -d -s "$NAME"
    if test $NAME = "root"
      tmux split-window -h
      tmux send-keys -t 1 "$COMMAND" C-m
      tmux send-keys -t 2 "$COMMAND && lazygit" C-m
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
