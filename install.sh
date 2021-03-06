#!/bin/sh

# Get execution environment infomations
if [ "$(uname)" = 'Darwin' ]; then
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

# Install dependencies
if [ "$OS" = 'Mac' ]; then
  echo 'Install dependencies [Mac]'
  if ! (type brew >/dev/null 2>&1); then
    echo '- Homebrew'
    sudo chown -R "$USER" /usr/local
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" </dev/null
  else
    echo '- Homebrew [skip]'
  fi
elif [ "$OS" = 'Debian' ]; then
  echo 'Install dependencies [Linux - Debian]'
  echo '- apt update'
  sudo apt update -qqy
  echo '- apt install build-essential curl file gcc git'
  sudo apt install -qqy build-essential curl file gcc git
  echo '- apt autoremove'
  sudo apt autoremove -qqy
  if ! (type brew >/dev/null 2>&1); then
    echo '- Linuxbrew'
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)" </dev/null
  else
    echo '- Linuxbrew [skip]'
  fi
else
  echo 'Error: This os not supported.'
  exit 1
fi
echo
# ----

# Clone dotfiles repo
if [ ! -d ~/dotfiles/.git ]; then
  echo 'Clone dotfiles repo'
  git clone https://github.com/proudust/dotfiles.git ~/dotfiles
else
  echo 'Update dotfiles repo'
  git -C ~/dotfiles fetch origin
  git -C ~/dotfiles pull origin
fi
if [ -z "$CHECKOUT_REF" ]; then
  echo "Checkout '$(git -C ~/dotfiles rev-parse --abbrev-ref HEAD)'"
else
  echo "Checkout '$CHECKOUT_REF'"
  git -C ~/dotfiles checkout "$CHECKOUT_REF"
fi
echo
# ----

echo 'Make symbolic links'
echo '- ~/.bashrc'
ln -sf ~/dotfiles/.bashrc ~
if [ "$OS" = 'Mac' ]; then
  echo '- ~/.bash_profile'
  printf 'if [ -f ~/.bashrc ]; then\n  . ~/.bashrc\nfi\n' >~/.bash_profile
fi

echo '- ~/.gitconfig'
ln -sf ~/dotfiles/.gitconfig ~

echo '- ~/.config/starship.toml'
ln -sf ~/dotfiles/starship.toml ~/.config/

mkdir -p ~/develop/bin ~/develop/pkg ~/develop/src

if "$IS_WSL"; then
  echo '- /usr/share/fonts/windows'
  sudo ln -s /mnt/c/Windows/Fonts /usr/share/fonts/windows
fi

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo
# ----

echo 'Install packages'
echo '- Utility'
brew install bash-completion bat coreutils exa ghq jq peco shellcheck starship unzip yq zip
echo '- Golang'
brew install golang
echo '- Node (npm, npm-check-updates)'
brew install npm
npm install -g npm-check-updates
echo '- Python (2, 3)'
brew install python3 python@2
echo '- Rust (rustup)'
brew install rustup
rustup-init
"$HOME/.cargo/bin/rustup" target add x86_64-unknown-linux-musl
if [ "$OS" = 'Mac' ]; then
  echo "- GUI"
  brew cask install font-cica google-backup-and-sync google-chrome google-japanese-ime visual-studio-code
fi
echo
# ----
