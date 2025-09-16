# Check for tpm installation
#if "test ! -d ~/.tmux/plugins/tpm" \
#   "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"

#if ! [[ -d ~/git/fzf-tab ]]; then
#  git clone https://github.com/Aloxaf/fzf-tab ~/git

# Auto-suggestions plug-in
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh

# Syntax highlighting plug-in
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
ZSH_HIGHLIGHT_STYLES[arg0]=fg=cyan
ZSH_HIGHLIGHT_STYLES[assign]=none
ZSH_HIGHLIGHT_STYLES[autodirectory]=fg=green,underline
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=magenta,bold
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=magenta,bold
ZSH_HIGHLIGHT_STYLES[bracket-error]=fg=red,bold
ZSH_HIGHLIGHT_STYLES[bracket-level-1]=fg=blue,bold
ZSH_HIGHLIGHT_STYLES[bracket-level-2]=fg,green,bold
ZSH_HIGHLIGHT_STYLES[bracket-level-3]=fg=magenta,bold
ZSH_HIGHLIGHT_STYLES[bracket-level-4]=fg=yellow,bold
ZSH_HIGHLIGHT_STYLES[bracket-level-5]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[command-substitution]=none
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=magenta,bold
ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold
ZSH_HIGHLIGHT_STYLES[comment]=fg=black,bold
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]=standout
ZSH_HIGHLIGHT_STYLES[default]=none
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=magenta,bold
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=yellow
ZSH_HIGHLIGHT_STYLES[double-qouted-argument]=fg=yellow
ZSH_HIGHLIGHT_STYLES[global-alias]=fg=green,bold
ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue,bold
ZSH_HIGHLIGHT_STYLES[named-fd]=none
ZSH_HIGHLIGHT_STYLES[numeric-fd]=none
ZSH_HIGHLIGHT_STYLES[path]=bold
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=
ZSH_HIGHLIGHT_STYLES[precommand]=fg=green,underline
ZSH_HIGHLIGHT_STYLES[process-substitution]=none
ZSH_HIGHLIGHT_STYLES[process-substitution]=fg=magenta,bold
ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=magenta
ZSH_HIGHLIGHT_STYLES[redirection]=fg=blue,bold
ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=green,underline
ZSH_HIGHLIGHT_STYLES[unknown-token]=underline

# GCC Colors
GCC_COLORS=''
GCC_COLORS+="error=${c[raw_bold]};${c[raw_red]}"
GCC_COLORS+=":warning=${c[raw_bold]};${c[raw_yellow]}"
GCC_COLORS+=":note=${c[raw_bold]};${c[raw_white]}"
GCC_COLORS+=":caret=${c[raw_bold]};${c[raw_white]}"
GCC_COLORS+=":locus=${c[raw_bg_black]};${c[raw_bold]};${c[raw_magenta]}"
GCC_COLORS+=":quote=${c[raw_bold]};${c[raw_yellow]}"
export GCC_COLORS

# Save history across all sessions
HISTDUP=erase
HISTFILE=~/.zsh_persistent_history
HISTSIZE=5000
SAVEHIST=5000
setopt APPENDHISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

export PROMPT_EOL_MARk=''
setopt PROMPT_SP

# Auto-completion (case insensitive)
autoload -Uz compinit
compinit -d ~/.zcompdump
source ~/git/fzf-tab/fzf-tab.plugin.zsh
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer_expand_complete
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu yes
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt %SScrolling active: currect selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
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
function dup() {
    # Check if the argument is a number
    if [[ $1 =~ ^[0-9]+$ ]]; then
        # Build a path to go up 'x' directories
        local count=$1
        local path=""
        for ((i=1; i<=count; i++)); do
            path="../$path"
        done
        # Use zoxide to cd into that path
        zoxide cd "$path"
    else
        echo "Usage: dup <number of directories>"
    fi
}

# git repository greeter
last_repository=
check_directory_for_new_repository() {
	current_repository=$(git rev-parse --show-toplevel 2> /dev/null)
	
	if [ "$current_repository" ] && \
	   [ "$current_repository" != "$last_repository" ]; then
		onefetch --churn-pool-size=0 --hide-token --nerd-fonts --no-art --no-color-palette --no-title --number-of-authors=0 --number-of-file-churns=0
	fi
	last_repository=$current_repository
}
chpwd() {
	check_directory_for_new_repository
}

# optional, greet also when opening shell directly in repository directory
# adds time to startup
check_directory_for_new_repository
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
alias cwal='$HOME/.config/hypr/scripts/wallpaper.sh'
alias iid='identify -format "%wx%h"'
alias diff='colordiff'
alias df='df -B M'
alias egrep='egrep --color=auto'
alias fastfetch='fastfetch --kitty $HOME/Pictures/Logos/kappa10-cyan.png --logo-height 14 --logo-padding-left 2 --logo-padding-top 2 --logo-width 28'
alias fgrep='fgrep --color=auto'
alias fps="mangohud /usr/bin/steam"
# WARNING: Force CFLAGS for aggressive AMD Ryzen optimizations
# alias gcc='/usr/bin/gcc "$@" -O3 -march=znver4 -mtune=znver4'
# alias gcc='/usr/bin/gcc "$@" -O3 -march-znver2 -mtune=znver2 -fdiagnostics-color=always'
alias grep='grep --color=auto'
alias hx='helix'
alias iid='identify -format "%wx%h"'
alias ip='ip --color=auto'
alias kmon='sudo kmon -a cyan'
alias less='moar'
alias ls='lsd -a'
alias nano='nano -i -l -q -x -_ --tabsize=2 --tabstospaces'
alias rm='trash'
alias rmdir='trash'
alias sudo='doas '
alias syslog='journalctl -f -x --no-full --no-hostname --output=short-precise'
alias ticker='ticker --config $HOME/.config/ticker.yaml'
alias tmatrix='tmatrix -C blue -t ""'
alias tmux='tmux -f $HOME/.config/tmux/tmux.conf'
alias vc='code --disable-gpu'

# History search rebinds
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^n' history-search-forward
bindkey '^p' history-search-backward

# Load secret exports
# source ~/.zsh_secrets

# Exports
export ASAN_OPTIONS=abort_on_error=1:halt_on_error=1
export AVATAR="$HOME/Pictures/Logos/lc.png"
export AVATAR_HYPRLOCK="$HOME/Pictures/Logos/lc_black.png"
export BROWSER="zen-browser"
#export CFLAGS="-O2 -march=znver2 -mtune=znver2 -D_FORTIFY_SOURCE=2 -D_GLIBCXX_ASSERTIONS -fasynchronous-unwind-tables -fdiagnostics-color=always -fexceptions -fpie -Wl,-pie -fpic -shared -fplugin-annobin -fstack-clash-protection -fstack-protector-strong -g -grecord-gcc-switches -mcet -fcf-protection -Wall -Werror -Werror=format-security -Werror=implicit-function-declaration -Wl,-z,defs -Wl,-z,now -Wl,-z,relro -Wpedantic"
#export CPPFLAGS=" -march=znver2 -mtune=znver2 -O2 -Wp,-D_FORTIFY_SOURCE=3 -fasynchronous-unwind-tables -fexceptions -fno-plt -fsanitize=thread -fsanitize=integer-divide-by-zero -fsanitize=null -Wl,--as-needed -Wl,-z,now -Wl,-z,pack-relative-relocs, -Wl,-z,relco"
export DOCKER_CONTEXT="setec31"
export DOTFILES="$GHREPOS/dotfiles"
export EDITOR="helix"
export FILEMANAGER="nautilus"
#export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS
#  --color fg:7,bg:0,hl:1,fg+:232,bg+:1,hl+:255
#  --color info:7,prompt:2',spinner:1,pointer:232,marker:1"
export GHREPOS="$REPOS/github.com/$GITUSER"
export GITUSER="lastcrossroads"
# Kernel flags. (and yes, I know CPPFLAGS should suffice. blow me)
# export KCFLAGS=" -march=znver2 -mtune=znver2 -O2 -fsanitize=kernel-address -Wp,-D_FORTIFY_SOURCE=3 -fno-plt"
# export KCPPFLAGS=" -march=znver2 -mtune=znver2 -O2 -fsanitize=kernel-address -Wp,-D_FORTIFY_SOURCE=3 -fno-plt"
export LIBVIRT_DEFAULT_URI="qemu:///system"
export PATH="$HOME/.local/scripts:$HOME/.local/bin:$PATH"
export PROMPT_EOL_MARKER="\n"
export QT_QPA_PLATFORM="xcb" # Deal with OBS/Wayland fuckery
export QT_QPA_PLATFORMTHEME="qt6ct"
export REPOS="$HOME/git"
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
#clear
# TERMINAL_PROGRAM="kitty"
# TERMINAL_INSTANCE=$(pgrep -x "$TERMINAL_PROGRAM" | wc -l)

# TMUX_INSTANCE=$(pgrep -x tmux | wc -l)
# if (( TERMINAL_INSTANCE > 2 )) || (( TMUX_INSTANCE > 1 )) > /dev/null ; then
   # hostname | figlet -f Graffiti | lolcat -p 1.5
   hostname | figlet -f Graffiti | tte expand
   kotofetch --source false
   echo
# else
#   motd.sh
# fi
# [[ $commands[kubectl] ]] && source <(kubectl completion zsh) # add autocomplete permanently to your zsh shell
