#!/bin/bash
# Change directory aliases
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias activate="source ./.venv/bin/activate"
alias gdb="gdb -q"
alias clear='clear -x'
alias clc='clear -x'
alias c='clear -x'
alias mv='mv -i -v'
alias cp='cp -v'
alias rm='rm -i -v'
alias ln='ln -i'

# some more ls aliases
alias l='ls -CF'
alias lr='ls -t | head -n 5'
alias la='ls -Alh' # show hidden files
alias lu='du -sh * | sort -h' 
alias ll='ls -Fls' # long listing format

alias watch='watch -n1'
alias diff='diff --color'
alias ports='nmap localhost'
alias untar='tar -zxvf'

alias cdtmp='cd $(mktemp -d)'
alias venv='python3 -m venv .venv; source ./.venv/bin/activate'
alias serve='python3 -m http.server 8000'

alias copy='xclip -i'
alias paste='xclip -o'
alias copywd='pwd | xclip -i'
alias pastewd='cd $(xclip -o)'

alias more='less'
alias chx='chmod +x'

alias ip4='ip -o -4 addr show | awk "{print NR\": \"\$2\": \"\$4}"'
alias ipa='ip -o -4 addr show | awk "{print NR\": \"\$2\": \"\$4}"'

alias tmuxatt='tmux attach -t'

# wsl cd fix

cd() {
    if [ $# -eq 1 ] && echo "$1" | grep -qE '^[a-zA-Z]:[/\\]'; then
        builtin cd "$(wslpath "$1")"
    else
        builtin cd "$@"
    fi
}