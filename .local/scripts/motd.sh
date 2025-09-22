#!/usr/bin/env zsh

function check_host {
  local server="$1"
  local count=1
  if ping -c $count "$server" > /dev/null 2>&1; then
    echo -e "  \e[38;2;0;255;0m\e[0m $( getent hosts $server )"
  else
    echo -e "  \e[38;2;255;0;0m\e[0m $( getent hosts $server )"
  fi
}
clear
hostname | figlet -f Graffiti | tte beams --beam-row-symbols ▂ ▁ _ --beam-column-symbols ▌ ▍ ▎ ▏ --beam-delay 1 --beam-row-speed-range 10-40 --beam-column-speed-range 6-10 --beam-gradient-stops ffffff 00D1FF 8A008A --beam-gradient-steps 2 8 --beam-gradient-frames 2 --final-gradient-stops 8A008A 00D1FF ffffff --final-gradient-steps 12 --final-gradient-frames 5 --final-gradient-direction vertical --final-wipe-speed 1 ;
fastfetch --kitty $HOME/Pictures/Logos/kappa10-cyan.png --logo-height 14 --logo-padding-left 2 --logo-padding-top 2 --logo-width 28
fortune -s | tte slide --movement-speed 0.5 --grouping row --final-gradient-stops 833ab4 fd1d1d fcb045 --final-gradient-steps 12 --final-gradient-frames 10 --final-gradient-direction vertical --gap 3 --reverse-direction --merge --movement-easing OUT_QUAD ;
kusa lastcrossroads
check_host ares-mobile
check_host enchiridion
check_host epsilon11
check_host ereshkigal
check_host gojira-1
#check_host kappa10
check_host tiamat
check_host systemXI
check_host XXII
nmcli connection show | tte rain
echo -n "    "
curl 'wttr.in/Baltimore?u&format=%l:+%c+%w+%t+%h+%m+%S+%s\n'
echo -n "    "
curl 'wttr.in/Harrogate?u&format=%l:+%c+%w+%t+%h\n'
curl 'wttr.in/Alice_Springs?u&format=%l:+%c+%w+%t+%h\n'
echo -n "        "
curl 'wttr.in/Tokyo?u&format=%l:+%c+%w+%t+%h\n'
