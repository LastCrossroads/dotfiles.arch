#!/usr/bin/env bash

SESSIONS=$(echo $(find /usr/share/xsessions/ /usr/share/wayland-sessions/ -type f))

for session in $SESSIONS; do
	cat $session | grep -oP 'Name=\K.*'
done

