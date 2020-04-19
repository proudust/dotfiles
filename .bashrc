#!/bin/bash

# Get execution environment infomations
IS_WSL=false
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
  IS_WSL=true
fi
# ----

# Golang
export GOPATH="$HOME/develop"
export PATH="$GOPATH/bin:$PATH"

# Rust
export CARGO_HOME="$HOME/.cargo"
export OPENSSL_DIR='/home/linuxbrew/.linuxbrew/opt/openssl@1.1'
export RUST_BACKTRACE=1
# shellcheck source=/dev/null
source "$HOME/.cargo/env"

# Linuxbrew
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
    repo="$(ghq list -p | peco)"
    if [ -n "$repo" ]; then
      cd "$repo" || return
    fi
  }
  bind -x '"\201": cd-ghq'
fi
bind '"\C-]":"\201\C-m"'

if "$IS_WSL"; then
  WINDOWS_ATTR=$(grep nameserver </etc/resolv.conf | awk '{print $2; exit;}')
  export DISPLAY=$WINDOWS_ATTR:0.0
  export LIBGL_ALWAYS_INDIRECT=1

  export GTK_IM_MODULE=fcitx
  export QT_IM_MODULE=fcitx
  export XMODIFIERS="@im=fcitx"
  export DefaultIMModule=fcitx
  xset -r 49

  function cmd() {
    cmd.exe /c "$@"
  }
fi
