echo 'Install dependencies'
sudo apt update -qy
sudo apt install -qy build-essential curl file gcc git

echo 'Clone dotfiles repo'
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ] && [ ! -d $(wslupath -H)/dotfiles/.git ]; then
  ln -sf $(wslupath -H)/dotfiles ~/
elif [ ! -d ~/dotfiles/.git ]; then
  git clone https://github.com/proudust/dotfiles.git ~/dotfiles
else
  git -C ~/dotfiles fetch origin
  git -C ~/dotfiles pull origin
fi

echo 'Make symbolic links'
ln -sf ~/dotfiles/.bashrc ~
ln -sf ~/dotfiles/.gitconfig ~
mkdir -p ~/.config/Code/User
ln -sf ~/dotfiles/.vscode/settings.json ~/.config/Code/User/

# If you can't find brew command, install linuxbrew
if !(type brew >/dev/null 2>&1); then
  echo "Install linuxbrew"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)" </dev/null
else
  echo "Find linuxbrew"
fi
source ~/.bashrc

echo "Install packages"
brew install golang npm python3 python@2
brew install bat coreutils exa ghq jq peco powerline-go unzip yq zip

npm install -g npm-check-updates

# WSL only
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
  sudo ln -s /mnt/c/Windows/Fonts /usr/share/fonts/windows
fi
