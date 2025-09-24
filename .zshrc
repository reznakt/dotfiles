if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

EDITOR=nvim

less_termcap[md]=$(tput bold; tput setaf 4)   # primary - blue, bold
less_termcap[me]=$(tput sgr0)                 # primary end - reset
less_termcap[us]=$(tput bold; tput setaf 2)   # secondary - green, bold
less_termcap[ue]=$(tput sgr0)                 # secondary end - reset
less_termcap[so]=$(tput bold; tput setaf 1)   # status line - red, bold
less_termcap[se]=$(tput rmso; tput sgr0)      # status line end - reset

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
