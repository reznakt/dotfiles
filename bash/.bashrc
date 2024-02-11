#!/usr/bin/env bash

#     _               _              
#    | |__   __ _ ___| |__  _ __ ___ 
#    | '_ \ / _` / __| '_ \| '__/ __|
#   _| |_) | (_| \__ \ | | | | | (__ 
#  (_)_.__/ \__,_|___/_| |_|_|  \___|
#                                    
#

# if not running interactively, don't do anything
[ -z "$PS1" ] && return

# ANSI escape sequences for colors
export COLOR_RESET='\e[0m'
export COLOR_BLACK='\e[0;30m'
export COLOR_GRAY='\e[1;30m'
export COLOR_RED='\e[0;31m'
export COLOR_LIGHT_RED='\e[1;31m'
export COLOR_GREEN='\e[0;32m'
export COLOR_LIGHT_GREEN='\e[1;32m'
export COLOR_BROWN='\e[0;33m'
export COLOR_YELLOW='\e[1;33m'
export COLOR_BLUE='\e[0;34m'
export COLOR_LIGHT_BLUE='\e[1;34m'
export COLOR_PURPLE='\e[0;35m'
export COLOR_LIGHT_PURPLE='\e[1;35m'
export COLOR_CYAN='\e[0;36m'
export COLOR_LIGHT_CYAN='\e[1;36m'
export COLOR_LIGHT_GRAY='\e[0;37m'
export COLOR_WHITE='\e[1;37m'

# display a colored exit code of last process
function exit-code() {
    local EXIT_CODE="$?"

    if [ "$EXIT_CODE" = "0" ]; then
        echo -en "$COLOR_LIGHT_GREEN"
    else
        echo -en "$COLOR_LIGHT_RED"
    fi

    echo -en "${EXIT_CODE}${COLOR_RESET}"
}

# escape ansi color escape sequence for use in PS1
function _ps-color() {
    if [ -z "$1" ]; then
        echo "error: missing argument"
        return 1
    fi

    echo "\[$1\]"
}

# update shell prompt
function update-prompt() {
    local PROMPT_COLOR

    if [ -n "$SSH_CONNECTION" ]; then
        PROMPT_COLOR=$(_ps-color "$COLOR_LIGHT_RED")
    else
        PROMPT_COLOR=$(_ps-color "$COLOR_LIGHT_GREEN")
    fi

    export PS1="\[\e[1m\]$PROMPT_COLOR\u@\h\[\e[0m\]:\[\e[1m\]\[\e[34m\]\w\[\e[0m\]\$ [\$(exit-code)] "
}

# add modules
function update-modules() {
    for module in $(cat $HOME/.modules); do
        module add "$module"
    done
}

# adds module name to ~/.modules
function module-add-permanent() {
    if [ -z "$1" ]; then
        echo "error: missing argument"
        return 1
    fi

    if grep -q "^$1\$" ~/.modules; then
        echo "error: module $1 already exists in ~/.modules"
        return 1
    else
        echo "$1" >> "$HOME/.modules"
        update-modules
    fi
}

# restore cursor caret to blinking underline at nvim exit
function nvim() {
    command nvim "$@"
    echo -en "\033[3 q"
}

# improved git log
function git() {
    if [ "$1" = "log" ]; then
        shift 1
        command git log \
                --graph \
                --abbrev-commit \
                --decorate \
                --format=format:"%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)" \
                --all \
                "$@"
        return
    fi

    command git "$@"
}

# colored pstree
function pstree() {
    command pstree -U "$@" | sed '
        s/[-a-zA-Z]\+/\x1B[32m&\x1B[0m/g
        s/[{}]/\x1B[31m&\x1B[0m/g
        s/[─┬─├─└│]/\x1B[34m&\x1B[0m/g
    '
}


# colored man pages
LESS_TERMCAP_md=$(tput bold; tput setaf 4)   # primary - blue, bold
LESS_TERMCAP_me=$(tput sgr0)                 # primary end - reset
LESS_TERMCAP_us=$(tput bold; tput setaf 2)   # secondary - green, bold
LESS_TERMCAP_ue=$(tput sgr0)                 # secondary end - reset
LESS_TERMCAP_so=$(tput bold; tput setaf 1)   # status line - red, bold
LESS_TERMCAP_se=$(tput rmso; tput sgr0)      # status line end - reset

export LESS_TERMCAP_md LESS_TERMCAP_me LESS_TERMCAP_us LESS_TERMCAP_ue \
    LESS_TERMCAP_so LESS_TERMCAP_se

# prepend to PATH
export PATH="/usr/sbin:/sbin:/usr/etc:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# pnpm global store
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# add .script to PATH
export PATH="$HOME/.script:$PATH"

# clear all predefined aliases
unalias -a

# enable colors on common commands
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias ls='ls --color=auto'

# ls aliases
alias la='ls -A'
alias ll='ls -oF --si --group-directories-first --time-style="+%Y-%m-%d %H:%M:%S"'
alias lla='ll -A'

# common aliases
alias ipython='ptipython --vi'
alias ta='[ -z "$TMUX"  ] && { tmux attach || exec tmux new-session; clear; }'
alias td='clear && tmux detach && clear'
alias valgrind='colour-valgrind --tool=memcheck --leak-check=full --show-leak-kinds=all --track-origins=yes --show-reachable=yes --track-fds=yes -s'
alias stackusage='colour-valgrind --tool=drd --show-stack-usage=yes'
alias untar='tar -xvf'
alias cc='gcc'
alias ssh='ssh -kY 2> /dev/null'
alias where='whereis'
alias ip='ip --color=auto'
alias whois='whois -H'


# set default editor to neovim
export VISUAL="nvim"
export EDITOR="$VISUAL"

# don't save duplicates to history
export HISTCONTROL="ignoredups:ignorespace"

# disable ^S and ^Q
stty -ixon

# enable autocd - write dirname to cd into it
shopt -s autocd

# correct minor mistakes while using cd
shopt -s cdspell

# save multiline commands to history
shopt -s cmdhist

# append to the history file, don't overwrite it
shopt -s histappend

# check window size after each command and update LINES and COLUMNS
shopt -s checkwinsize

# disable core files
ulimit -c 0

# list jobs before logout (only on SSH)
if [ -n "$SSH_CONNECTION" ]; then
    shopt -s checkjobs
fi

# enable programmable completion features
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# set up shell prompt
update-prompt

# Aisa-specific
if [ "$HOSTNAME" = "aisa.fi.muni.cz" ]; then
    # aliases
    alias kontr='/home/kontr/odevzdavam'
    
    # initialize module system and load modules
    . /packages/run/modules-2.0/init/bash 2> /dev/null
    update-modules
fi

