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

# Install Homebrew dependencies
if [ "$(uname)" = 'Darwin' ]; then
  true
elif type apt-get >/dev/null 2>&1; then
  echo "$ apt-get install build-essential procps curl file git"
  sudo apt-get install build-essential procps curl file git
  echo
elif type dnf >/dev/null 2>&1; then
  echo "$ dnf groupinstall 'Development Tools'"
  sudo dnf groupinstall 'Development Tools'
  echo
  echo "$ dnf install procps-ng curl file git"
  sudo dnf install procps-ng curl file git
  echo
elif type pacman >/dev/null 2>&1; then
  echo "$ pacman -Syu base-devel procps-ng curl file git"
  sudo pacman -Syu base-devel procps-ng curl file git
  echo
else
  echo 'Error: This os not supported.'
  exit 1
fi

# Install Homebrew
# shellcheck disable=SC2016
if ! (type brew >/dev/null 2>&1); then
  echo '$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/null'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/null
  echo
fi

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
ln -sf ~/dotfiles/.gitconfig_linux_mac ~/.gitconfig_shared

echo '- ~/.config/git/ignore'
ln -sf ~/dotfiles/.gitignore ~/.config/git/ignore

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
brew install bash-completion bat coreutils exa ghq jq peco shellcheck unzip yq zip
echo '- Node.js (with volta, npm-check-updates)'
brew install volta
volta install node@lts
npm install -g npm-check-updates
echo '- Python (2, 3)'
brew install python3 python@2
echo '- Rust (rustup)'
brew install rustup
rustup-init
"$HOME/.cargo/bin/rustup" target add x86_64-unknown-linux-musl
if [ "$OS" = 'Mac' ]; then
  echo "- GUI"
  brew tap homebrew/cask-fonts
  brew install --cask font-cica visual-studio-code
fi
echo
# ----
