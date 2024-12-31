#!/bin/bash
clear
if [ -f ~/.config/waybar/terminal.sh ]; then
    terminal="$(cat ~/.config/waybar/terminal.sh)"
    echo ":: Installing $terminal"
else
    echo "ERROR: ~/.config/waybar/terminal.sh not found"
fi
sleep 3
