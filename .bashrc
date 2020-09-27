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
export PATH="$CARGO_HOME/bin:$PATH"

# Linuxbrew
if [ -d '/home/linuxbrew/.linuxbrew' ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

alias ..="cd .."
type bat >/dev/null 2>&1 && alias cat="bat --paging=never"
type exa >/dev/null 2>&1 && alias ls="exa"
alias npmb='npm run build'
alias npmd='npm run deploy'
alias npmi='npm install'
alias npmid='npm install --save-dev'
alias npml='npm run lint'
alias npms='npm start'
alias npmt='npm test'
alias python="python3"
alias pip="pip3"

if [[ -t 1 ]]; then
  # Prompt
  PROMPT_COMMAND=prompt-command
  prompt-command() {
    local exitcode="$?"

    local darkgray='\[\e[1;30m\]'
    local lightblue='\[\e[1;32m\]'
    local lightgreen='\[\e[1;32m\]'
    local lightred='\[\e[1;31m\]'

    PS1='\n'
    PS1+="$lightblue\w\n"
    PS1+="$darkgray🕙 \$(date '+%Y/%m/%d %H:%M:%S') "
    [ $exitcode == 0 ] && PS1+="$lightgreen$" || PS1+="$lightred$"
    PS1+='\[\e[m\] '
  }

  # ctrl + r : command history
  command-history() {
    local tac cmd
    tac="$(which tac >/dev/null && echo 'tac' || echo 'tail -r')"
    cmd="$(history | $tac | sed '1d' | cut -c 8- | peco --query \""$READLINE_LINE"\")"
    READLINE_LINE="$cmd"
    READLINE_POINT="${#cmd}"
  }
  bind -x '"\C-r": command-history'

  # ctrl + o : open repo with code
  open-repo-with-code() {
    local repo
    repo="$(ghq list | peco --query \""$READLINE_LINE"\")"
    if [ -n "$repo" ]; then
      code "$(ghq root)/$repo" || return
    fi
  }
  bind -x '"\C-o": open-repo-with-code'

  # ctrl + ] : cd repo
  function cd-ghq() {
    local repo
    repo="$(ghq list -p | peco --query \""$READLINE_LINE"\")"
    if [ -n "$repo" ]; then
      cd "$repo" || return
    fi
  }
  bind -x '"\201": cd-ghq'
  bind '"\C-]":"\201\C-m"'
fi

if "$IS_WSL"; then
  export DISPLAY=localhost:0.0
  export LIBGL_ALWAYS_INDIRECT=1

  function cmd() {
    cmd.exe /c "$@"
  }
fi
