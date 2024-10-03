# Directory for all zsh shell packages
ZSH=~/.zsh/

# Install plugins from oh-my-zsh repository
# source $ZSH/plugins/catimg/catimg.plugin.zsh
# source $ZSH/plugins/fzf/fzf.plugin.zsh
# source $ZSH/plugins/safe-paste/safe-paste.plugin.zsh
# source $ZSH/plugins/sudo/sudo.plugin.zsh
# source $ZSH/plugins/zoxide/zoxide.plugin.zsh
# Plugins from repository
# source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
# source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh

# For machines I haven't bothered to switch over
# ZSH=/usr/share/oh-my-zsh/
# plugins=(catimg git kate safe-paste sudo ufw zsh-256color zsh-autosuggestions zsh-syntax-highlighting)
# source $ZSH/oh-my-zsh.sh

# Save history across all sessions
HISTDUP=erase
HISTFILE=~/.zsh_persistent_history
HISTSIZE=5000
SAVEHIST=5000
setopt APPENDHISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

export PROMPT_EOL_MARk=''
setopt PROMPT_SP

# Auto-completion (case insensitive)
autoload -Uz compinit; compinit
source ~/git/fzf-tab/fzf-tab.plugin.zsh
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':fzf-tab-complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab-complete:cd:*' fzf-preview 'ls --color $realpath'

# Ping a host to determine online status
function check_host {
  local server="$1"
  local count=1
  # Ping the server
  if ping -c $count "$server" > /dev/null 2>&1; then
    echo -e "  \e[38;2;0;255;0m\e[0m $( getent hosts $server )"
  else
    echo -e "  \e[38;2;255;0;0m\e[0m $( getent hosts $server )"
  fi
}

# In case a command is not found, try to find the package that has it
function command_not_found_handler {
  local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
  printf 'zsh: command not found: %s\n' "$1"
  local entries=( ${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"} )
  if (( ${#entries[@]} )) ; then
    printf "${bright}$1${reset} may be found in the following packages:\n"
    local pkg
    for entry in "${entries[@]}" ; do
      local fields=( ${(0)entry} )
      if [[ "$pkg" != "${fields[2]}" ]] ; then
        printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
      fi
      printf '    /%s\n' "${fields[4]}"
      pkg="${fields[2]}"
    done
  fi
  return 127
}

# Fuction to cd to 'x' times to previous directory
function dup {
  local counter=${1:-1}
  local dirup="../"
  local out=""
  while (( counter > 0)); do
    let counter--
    out="$(out)$dirup"
  done
  cd $out
}

# Function to display non-localhost IP addresses with their network interfaces
function show_local_ips {
  # For IPv4
  ip -4 addr show | awk '
  /inet/ && $2 != "127.0.0.1/8" {
    split($2, ip, "/")
    if ( NF > 7 ) {
      print "  " $9 ": " ip[1]
    } else {
      print "  " $7 "$: " ip[1]
    }
    echo -n
  }'

  # For IPv6
  ip -6 addr show | awk '
  /inet6/ && $2 != "::1/128" {
    split($2, ip, "/")
    print "  " ip[1]
  }'
}

# Detect the AUR wrapper
if pacman -Qi yay &>/dev/null ; then
   aurhelper="yay"
elif pacman -Qi paru &>/dev/null ; then
   aurhelper="paru"
fi

function in {
  local pkg="$1"
  if pacman -Si "$pkg" &>/dev/null ; then
    sudo pacman -S "$pkg"
  else
    "$aurhelper" -S "$pkg"
  fi
}

# Helpful aliases
alias un='$aurhelper -Rns' # uninstall package
alias up='$aurhelper -Syu' # update system/package/aur
alias pl='$aurhelper -Qs' # list installed package
alias pa='$aurhelper -Ss' # list availabe package
alias pc='$aurhelper -Sc' # remove unused cache
alias po='$aurhelper -Qtdq | $aurhelper -Rns -' # remove unused packages, also try > $aurhelper -Qqd | $aurhelper -Rsu --print -

alias cat='bat'
alias chgrp='chgrp --preserve-root'
alias chmod='chmod --preserve-root'
alias chown='chown --preserve-root'
alias iid='identify -format "%wx%h"'
alias diff='colordiff'
alias df='df -B M'
# WARNING: Force CFLAGS for aggressive AMD Ryzen optimizations
# alias gcc='/usr/bin/gcc "$@" -O3 -march=znver4 -mtune=znver4'
alias hx='helix'
alias ls='lsd -a'
alias nano='nano -i -l -q -x -_ --tabsize=2 --tabstospaces'
alias rm='trash'
alias rmdir='trash'
alias sudo='doas '
alias syslog='journalctl -f -x --no-full --no-hostname --output=short-precise'
alias vc='code --disable-gpu'
alias cwal='$HOME/.config/hypr/scripts/wallpaper.sh'

# History search rebinds
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^n' history-search-forward
bindkey '^p' history-search-backward

# Load secret exports
source ~/.zsh_secrets

# Exports
export ASAN_OPTIONS=abort_on_error=1:halt_on_error=1
export AVATAR="$HOME/Pictures/Logos/lc.png"
export AVATAR_HYPRLOCK="$HOME/Pictures/Logos/lc_black.png"
export BROWSER="zen-browser"
export CFLAGS="-O2 -march=znver2 -mtune=znver2 -D_FORTIFY_SOURCE=2 -D_GLIBCXX_ASSERTIONS -fasynchronous-unwind-tables -fexceptions -fpie -Wl,-pie -fpic -shared -fplugin-annobin -fstack-clash-protection -fstack-protector-strong -g -grecord-gcc-switches -mcet -fcf-protection -Wall -Werror -Werror=format-security -Werror=implicit-function-declaration -Wl,-z,defs -Wl,-z,now -Wl,-z,relro -Wpedantic"
export DOCKER_CONTEXT="sigma13"
export DOTFILES="$GHREPOS/dotfiles"
export EDITOR="helix"
export FILEMANAGER="nautilus"
export GHREPOS="$REPOS/github.com/$GITUSER"
export GITUSER="lastcrossroads"
export LIBVIRT_DEFAULT_URI="qemu:///system"
export PATH="$HOME/.scripts:$HOME/.bin:$PATH"
export PROMPT_EOL_MARKER="\n"
export QT_QPA_PLATFORM="xcb" # Deal with OBS/Wayland fuckery
export QT_QPA_PLATFORMTHEME="qt6ct"
export REPOS="$HOME/repos"
export SCRIPTS="$DOTFILES/scripts"
export TERM="tmux-256color"
export UBSAN_OPTIONS=abort_on_error=1:halt_on_error=1
export VISUAL="helix"
export WINEDLLOVERRIDES="d3dcompiler_47=;dxgi=n,b"

# Oops! I did it again
eval $(thefuck --alias)

# fzf start
eval "$(fzf --zsh)"

# Zoxide start
eval "$(zoxide init --cmd cd zsh)"

# Atuin start
eval "$(atuin init zsh --disable-up-arrow)"

# Prompt rice
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/lc.omp.json)"

# Adjust monitor brightness
monitor () {
  ddcutil --display=1 setvcp 10 $1 $2
}

# Terminal start
clear
TERMINAL_PROGRAM="kitty"
TERMINAL_INSTANCE=$(pgrep -x "$TERMINAL_PROGRAM" | wc -l)

TMUX_INSTANCE=$(pgrep -x tmux | wc -l)
if (( TERMINAL_INSTANCE > 1 )) || (( TMUX_INSTANCE > 1 )) > /dev/null ; then
  hostname | figlet -f Graffiti | lolcat -p 1.5
else
  hostname | figlet -f Graffiti | tte beams --beam-row-symbols ▂ ▁ _ --beam-column-symbols ▌ ▍ ▎ ▏ --beam-delay 1 --beam-row-speed-range 10-40 --beam-column-speed-range 6-10 --beam-gradient-stops ffffff 00D1FF 8A008A --beam-gradient-steps 2 8 --beam-gradient-frames 2 --final-gradient-stops 8A008A 00D1FF ffffff --final-gradient-steps 12 --final-gradient-frames 5 --final-gradient-direction vertical --final-wipe-speed 1 ;
  fastfetch --kitty $HOME/Pictures/Logos/arch-kanji.jpg --logo-padding-left 2 --logo-padding-top 2 --logo-height 14 --logo-width 28;
  fortune -s | tte slide --movement-speed 0.5 --grouping row --final-gradient-stops 833ab4 fd1d1d fcb045 --final-gradient-steps 12 --final-gradient-frames 10 --final-gradient-direction vertical --gap 3 --reverse-direction --merge --movement-easing OUT_QUAD ;
  kusa lastcrossroads
  check_host ares-mobile
  check_host enchiridion
  check_host entropy
  check_host ereshkigal
  check_host kappa10
  # check_host systemXI
  check_host XXII
  nmcli connection show
  echo -n "    "
  curl 'wttr.in/Baltimore?u&format=%l:+%c+%w+%t+%h+%m+%S+%s\n'
  echo -n "    "
  curl 'wttr.in/Harrogate?u&format=%l:+%c+%w+%t+%h\n'
  curl 'wttr.in/Alice_Springs?u&format=%l:+%c+%w+%t+%h\n'
  echo -n "        "
  curl 'wttr.in/Tokyo?u&format=%l:+%c+%w+%t+%h\n'
  # tmux
fi
