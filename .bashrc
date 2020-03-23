#!/bin/bash

# Get execution environment infomations
IS_WSL=false
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
  IS_WSL=true
fi
# ----

export GOPATH="$HOME/develop"
export PATH=$GOPATH/bin:$PATH
if [ -d '/home/linuxbrew/.linuxbrew' ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

alias ..="cd .."
alias cat="bat --paging=never"
alias ls="exa"
alias npmb='npm run build'
alias npmd='npm run deploy'
alias npmi='npm install'
alias npmid='npm install --save-dev'
alias npms='npm start'
alias npmt='npm test'
alias python="python3"
alias pip="pip3"

eval "$(starship init bash)"

if [[ -t 1 ]]; then
  # ctrl + ] : cd repo
  function cd-ghq() {
    local repo
    repo="$(ghq list | peco)"
    if [ -n "$repo" ]; then
      cd "$repo" || return
    fi
  }
  bind -x '"\201": cd-ghq'
fi
  bind '"\C-]":"\201\C-m"'

if "$IS_WSL"; then
  export DISPLAY=localhost:0.0
  export LIBGL_ALWAYS_INDIRECT=1

  function cmd() {
    cmd.exe /c "$@"
  }

  function code() {
    if [ "$1" ]; then
      local path
      path=$(wslpath -w "$1")
    fi
    cmd.exe /c code "$path"
  }
fi
