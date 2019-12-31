sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
  DOTFILES_REPO=$(wslupath -H)/dotfiles
else
  DOTFILES_REPO="~/dotfiles"
fi
if [ ! -d $DOTFILES_REPO/.git ]; then
  git clone https://github.com/proudust/dotfiles.git $DOTFILES_REPO
else
  git -C $DOTFILES_REPO fetch origin
  git -C $DOTFILES_REPO pull origin
fi
ln -sf $DOTFILES_REPO/.bashrc ~/.bashrc
ln -sf $DOTFILES_REPO/.gitconfig ~/.gitconfig

sudo apt install -y build-essential curl file gcc git
type brew >/dev/null 2>&1 || sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
source ~/.bashrc

brew install golang npm python3 python@2
brew install bat coreutils exa ghq jq peco powerline-go unzip yq zip

npm install -g npm-check-updates

if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
  # WSL only
  sudo ln -s /mnt/c/Windows/Fonts /usr/share/fonts/windows
  sudo apt install -y libasound2 libxss1
  $DOTFILES_REPO/installer/gitkraken.sh
else
  # other
  sudo apt install -y keepass2
  $DOTFILES_REPO/installer/cica-font.sh
  $DOTFILES_REPO/installer/code.sh
  $DOTFILES_REPO/installer/gitkraken.sh
  $DOTFILES_REPO/installer/steam.sh
fi
