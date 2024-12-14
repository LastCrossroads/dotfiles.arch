#!/bin/sh

layout="$(bat /etc/vconsole.conf | awk -F'=' '{print toupper($2)}')"
printf " %s " "$layout"
