eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
export GOPATH="/mnt/d/develop"
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

function code(){
  if [ $1 ]; then
    local path=$(wslpath -w $1)
  fi
  cmd.exe /c code $path
}

function cd-ghq() {
  cd "$( ls -d $(ghq root)/*/*/* | peco)"
}
bind -x '"\201": cd-ghq'
bind '"]":"\201\C-m"'
