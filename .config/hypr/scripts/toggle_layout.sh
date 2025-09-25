#!/usr/bin/env bash

current_layout=$(hyprctl -j getoption general:layout | jq -r .str)

if [ "$current_layout" = "dwindle" ]; then
  hyprctl keyword general:layout "scrolling"
  notify-send "   Layout: Scrolling"
elif [ "$current_layout" = "scrolling" ]; then
  hyprctl keyword general:layout "dwindle"
  notify-send "   Layout: Dwindle"
fi
