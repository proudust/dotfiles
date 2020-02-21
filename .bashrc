# Get execution environment infomations
if [ "$(uname)" == 'Darwin' ]; then
  OS='Mac'
elif [ -e /etc/debian_version ]; then
  OS='Debian' # Debian or Ubuntu
else
  echo 'Error: This os not supported.'
  exit 1
fi

IS_WSL=false
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
  IS_WSL=true
fi
# ----

export GOPATH="~/develop"
export PATH=$GOPATH/bin:$PATH
if [ -d '/home/linuxbrew/.linuxbrew' ]; then
  eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
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

if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

function _update_ps1() {
    PS1="$(powerline-go -error $?)"
}

if [ "$TERM" != "linux" ]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi

# ctrl + ] : cd repo
function cd-ghq() {
  local repo="$( ls -d $(ghq root)/*/*/* | peco)"
  if [ -n "$repo" ]; then
    cd "$repo"
  fi
}
bind -x '"\201": cd-ghq'
bind '"\C-]":"\201\C-m"'

if "$IS_WSL"; then
  export DISPLAY=localhost:0.0
  export LIBGL_ALWAYS_INDIRECT=1

  function cmd() {
    cmd.exe /c $@
  }

  function code() {
    if [ $1 ]; then
      local path=$(wslpath -w $1)
    fi
    cmd.exe /c code $path
  }
fi
