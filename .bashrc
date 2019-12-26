eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
  export GOPATH="/mnt/d/develop"
else
  export GOPATH="~/develop"
fi
export PATH=$GOPATH/bin:$PATH

alias ..="cd .."
alias ls="exa"
alias npmb='npm run build'
alias npmd='npm run deploy'
alias npmi='npm install'
alias npmid='npm install --save-dev'
alias npms='npm start'
alias npmt='npm test'
alias python="python3"
alias pip="pip3"

function _update_ps1() {
    PS1="$(powerline-go -error $?)"
}

if [ "$TERM" != "linux" ] && !(type "powerline-go" > /dev/null 2>&1); then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi

if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
  function code() {
    if [ $1 ]; then
      local path=$(wslpath -w $1)
    fi
    cmd.exe /c code $path
  }
fi

function cd-ghq() {
  cd "$( ls -d $(ghq root)/*/*/* | peco)"
}
bind -x '"\201": cd-ghq'
bind '"]":"\201\C-m"'
