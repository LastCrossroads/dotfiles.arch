#!/usr/bin/env bash

current_layout$(hyprctl -j getoption general:layout | jq -r .str)

if [ "$current_layout" = "dwindle" ]; then
  hyprctl keyword general:layout "scrolling"
elif [ "$current_layout" = "scrolling"]; then
  hyprctl keyword general:layout "dwindle"
fi
