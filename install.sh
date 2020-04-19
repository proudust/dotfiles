#!/bin/bash

function info() {
  printf "\r  [\033[00;34mINFO \033[0m] %s\n" "$1"
}

function warn() {
  printf "\r  [\033[00;33mWARN \033[0m] %s\n" "$1"
}

function error() {
  printf "\r  [\033[00;31mERROR\033[0m] %s\n" "$1"
}

mkdir -p /tmp/dotfiles/
echo >/tmp/dotfiles/brew.log

# Get execution environment infomations
if [ "$(uname)" = 'Darwin' ]; then
  OS='Mac'
elif [ -e /etc/debian_version ]; then
  OS='Debian' # Debian or Ubuntu
else
  error 'This os not supported.'
  exit 1
fi

IS_WSL=false
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
  IS_WSL=true
fi
# ----

# Install Homebrew or Linuxbrew
BREW_NAME="$(test "$OS" = 'Mac' && echo 'Homebrew' || echo 'Linuxbrew')"
FOUND_BREW="$(type brew >/dev/null 2>&1 && echo 'true' || echo 'false')"
if ! "$FOUND_BREW"; then
  if [ "$OS" = 'Mac' ]; then
    info 'Install Homebrew'
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" </dev/null >>/tmp/dotfiles/brew.log 2>&1

  elif [ "$OS" = 'Debian' ]; then
    info 'Install Linuxbrew dependencies using apt-get'
    sudo apt-get -qqy update
    sudo apt-get -qqy install build-essential curl file gcc git

    info 'Install Linuxbrew'
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)" </dev/null >>/tmp/dotfiles/brew.log 2>&1
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    brew install gcc >>/tmp/dotfiles/brew.log 2>&1
  fi
fi

info "Check $BREW_NAME"
if ! brew doctor; then
  error "$BREW_NAME has error"
  exit 1
fi

info "Update $BREW_NAME"
brew update
# ----

# Clone dotfiles repo
if [ ! -d ~/dotfiles/.git ]; then
  info 'Clone dotfiles repo'
  git clone https://github.com/proudust/dotfiles.git ~/dotfiles --quiet
else
  info 'Update dotfiles repo'
  git -C ~/dotfiles fetch origin --quiet
  git -C ~/dotfiles pull origin --quiet
fi

if [ -z "$CHECKOUT_REF" ]; then
  info "Checkout '$(git -C ~/dotfiles rev-parse --abbrev-ref HEAD)'"
else
  info "Checkout '$CHECKOUT_REF'"
  git -C ~/dotfiles checkout "$CHECKOUT_REF"
fi
# ----

# Setup bash
info 'Install newest version bash'
brew instal bash >>/tmp/dotfiles/brew.log 2>&1

info 'Set default shell to bash'
grep "$(which bash)" /etc/shells >/dev/null || which bash | sudo tee -a /etc/shells >/dev/null
chsh -s "$(which bash)"

info 'Install .bashrc dependencies'
brew instal bat exa ghq peco starship >>/tmp/dotfiles/brew.log 2>&1

info 'Install command line utility'
brew instal coreutils jq unzip yq zip >>/tmp/dotfiles/brew.log 2>&1

info 'Make symbolic links to ~/.bashrc'
ln -sf ~/dotfiles/.bashrc ~
if [ "$OS" = 'Mac' ]; then
  info 'Make simple ~/.bash_profile'
  printf 'if [ -f ~/.bashrc ]; then\n  . ~/.bashrc\nfi\n' >~/.bash_profile
fi

info 'Make symbolic links to ~/starship.toml'
ln -sf ~/dotfiles/starship.toml ~/.config/
# ----

# Setup git
info 'Install newest version bash'
brew instal git >>/tmp/dotfiles/brew.log 2>&1

info 'Make symbolic links to ~/.gitconfig'
ln -sf ~/dotfiles/.gitconfig ~

mkdir -p ~/develop/bin ~/develop/pkg ~/develop/src
# ----

# Setup code
if [ "$OS" = 'Mac' ]; then
  info 'Install Visual Studio Code'
  brew cask install font-cica visual-studio-code

  info 'Make symbolic links to ~/Library/Application Support/Code/User/settings.json'
  mkdir -p ~/Library/Application Support/Code/User
  ln -sf ~/dotfiles/.vscode/settings.json ~/Library/Application Support/Code/User/
else
  info 'Make symbolic links to ~/.config/Code/User/settings.json'
  mkdir -p ~/.config/Code/User
  ln -sf ~/dotfiles/.vscode/settings.json ~/.config/Code/User/
fi
# ----

# Setup Node development environment
info 'Install Node'
brew install npm >>/tmp/dotfiles/brew.log 2>&1
info 'Install Node utility'
npm install -g npm-check-updates
# ----

# Setup Python development environment
info 'Install Python 3'
brew install python >>/tmp/dotfiles/brew.log 2>&1
# ----

# Setup Rust development environment
info 'Install Rust'
brew install rustup >>/tmp/dotfiles/brew.log 2>&1
echo | rustup-init
# shellcheck source=/dev/null
source "$HOME/.cargo/env"
rustup target add x86_64-unknown-linux-musl
# ----

# Setup mac
if [ "$OS" = 'Mac' ]; then
  info "Install Browser"
  brew cask install google-chrome >>/tmp/dotfiles/brew.log 2>&1

  info "Install Google Backup and Sync"
  brew cask install google-backup-and-sync >>/tmp/dotfiles/brew.log 2>&1

  info "Install Google IME"
  brew cask install google-japanese-ime >>/tmp/dotfiles/brew.log 2>&1
fi
# ----

# Setup wsl
if "$IS_WSL"; then
  info 'Install wsl utils'
  sudo apt-get -qqy install ubuntu-wsl

  info 'Make symbolic links to /usr/share/fonts/windows'
  sudo ln -s /mnt/c/Windows/Fonts /usr/share/fonts/windows

  info "Install Mozc"
  sudo apt-get -qqy install fcitx-mozc fontconfig dbus-x11 x11-xserver-utils
  sudo fc-cache -fv

  info "Install Jetbrains Toolbox"
  curl -sL raw.githubusercontent.com/nagygergo/jetbrains-toolbox-install/master/jetbrains-toolbox.sh | bash
  sudo apt-get install -qqy libnss3 libxcursor1 libasound2 libatk1.0 libatk-bridge2.0
  wslusc --env 'source ~/.bashrc;' jetbrains-toolbox

  info "Install GitKraken"
  wget -O /tmp/gitkraken-amd64.deb -q https://release.gitkraken.com/linux/gitkraken-amd64.deb
  sudo dpkg -i /tmp/gitkraken-amd64.deb
  sudo apt-get install -qqyf
  sudo apt-get install -qqy libasound2 libxss1
  wslusc --env 'source ~/.bashrc;' gitkraken
fi
# ----
