eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
export GOPATH="/mnt/d/develop"
export PATH=$GOPATH/bin:$PATH

alias ..="cd .."
alias python="python3"
alias pip="pip3"

git config --global ghq.root "$GOPATH/src"
git config --global user.name "Proudust"
git config --global user.email "proudust@gmail.com"

function code(){
  if [ $1 ]; then
    local path=$(wslpath -w $1)
  fi
  cmd.exe /c code $path
}

function cd-ghq() {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    cd ${selected_dir}
  fi
}
bind -x '"]": cd-ghq'
