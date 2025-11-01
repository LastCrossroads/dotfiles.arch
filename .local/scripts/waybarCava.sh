#!/bin/env bash

bar="▁▂▃▄▅▆▇█"
dict="s/;//g"

# Calculate the length of the bar outside the loop
bar_length=${#bar}

# Create dictionary to replace char with bar
for ((i = 0; i < bar_length; i++)); do
    dict+=";s/$i/${bar:$i:1}/g"
done

# Create cava config
config_file="/tmp/bar_cava_config"
cat >"$config_file" <<EOF
[general]
bars = 13
bar_spacing = 0
framerate = 30
lower_cutoff_freq = 20
higher_cutoff_freq = 20000

[input]
method = pulse
source = auto

[output]
ascii_max_range = 8
channels = mono
mono_option = average
data_format = ascii
method = raw
raw_target = /dev/stdout
show_idle_bar_heads = 0

[smoothing]
gravity = 150
monstercat = 1
noise_reduction = 66
waves = 1
waveform = 1
EOF

# Kill cava if it's already running
pkill -f "cava -p $config_file"

# Read stdout from cava and perform substitution in a single sed command
# $HOME/.local/bin/cava -p "$config_file" | sed -u "$dict"
/usr/bin/cava -p "$config_file" | sed -u "$dict"
