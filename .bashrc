eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
export GOPATH="/mnt/d/develop/src/"
export PATH=$GOPATH/bin:$PATH

alias python="python3"
alias pip="pip3"

git config --global ghq.root "$GOPATH/src"
git config --global user.name "Proudust"
git config --global user.email "proudust@gmail.com"

# ghq with poco
function cd-ghq () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N cd-ghq
bindkey '^]' cd-ghq
