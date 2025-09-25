#!/bin/env bash

on=$(hyprctl -j getoption animations:enabled | jq --raw-output '.int')
if [[ $on -eq 1 ]]; then
  hyprctl keyword animations:enabled 0
  notify-send "   Animations Disabled"
  else
  hyprctl keyword animations:enabled 1
  notify-send "   Animations Enabled"
fi
