unalias -a

unset -f ls
unset -f pstree
unset -f git
unset -f nvim

# use lsd instead of ls if available
ls() {
  if command -v lsd &> /dev/null; then
    command lsd "$@"
  else
    command ls "$@"
  fi
}

# colored pstree
pstree() {
  command pstree -U "$@" | sed '
      s/[-a-zA-Z]\+/\x1B[32m&\x1B[0m/g
      s/[{}]/\x1B[31m&\x1B[0m/g
      s/[─┬─├─└│]/\x1B[34m&\x1B[0m/g
  '
}

# better git log
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

# restore cursor caret to blinking underline at nvim exit
nvim() {
  command nvim "$@"
  echo -en "\033[3 q"
}

# enable colors for various commands
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias ip='ip --color=auto'
alias ls='ls --color=auto'

# common ls aliases
alias la='ls -A'
alias ll='ls -l'
alias lla='ll -A'

# misc
alias update='topgrade'

