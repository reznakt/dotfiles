# if not running interactively, don't do anything
if [ -z "$PS1" ]; then
    return
fi

# source aliases
if [ -f "$HOME/.bash_aliases" ]; then
    . "$HOME/.bash_aliases"
fi

# set cursor to blinking underline
echo -en "\033[3 q"

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
exit_code() {
    local EXIT_CODE="$?"

    if [ "$EXIT_CODE" = "0" ]; then
        echo -en "$COLOR_LIGHT_GREEN"
    else
        echo -en "$COLOR_LIGHT_RED"
    fi

    echo -en "${EXIT_CODE}${COLOR_RESET}"
}

# escape ansi color escape sequence for use in PS1
_ps_color() {
    if [ -z "$1" ]; then
        echo "error: missing argument"
        return 1
    fi

    echo "\[$1\]"
}

# update shell prompt
update_prompt() {
    local PROMPT_COLOR

    if [ -n "$SSH_CONNECTION" ]; then
        PROMPT_COLOR=$(_ps_color "$COLOR_LIGHT_RED")
    else
        PROMPT_COLOR=$(_ps_color "$COLOR_LIGHT_GREEN")
    fi

    export PS1="\[\e[1m\]$PROMPT_COLOR\u@\h\[\e[0m\]:\[\e[1m\]\[\e[34m\]\w\[\e[0m\]\$ [\$(exit_code)] "
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
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.scripts:$PATH"

# pnpm global store
export PATH="$HOME/.local/share/pnpm:$PATH"

# valgrind aliases
if command -v colour-valgrind &> /dev/null; then
    alias valgrind='colour-valgrind --tool=memcheck --leak-check=full --show-leak-kinds=all --track-origins=yes --show-reachable=yes --track-fds=yes -s'
    alias stackusage='colour-valgrind --tool=drd --show-stack-usage=yes'
fi

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
update_prompt
