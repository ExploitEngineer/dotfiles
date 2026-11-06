#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

export PATH="$HOME/.local/bin:$PATH"
. "$HOME/.cargo/env"

# Theme-driven tool config written by the wallbash hooks
[ -f "$HOME/.config/shell/wallbash-env.sh" ] && . "$HOME/.config/shell/wallbash-env.sh"
