sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

DOTFILES_REPO="~/dotfiles"
if [ ! -d $DOTFILES_REPO/.git ]; then
  git clone https://github.com/proudust/dotfiles.git $DOTFILES_REPO
else
  git -C $DOTFILES_REPO fetch origin
  git -C $DOTFILES_REPO pull origin
fi
ln -sf $DOTFILES_REPO/.bashrc ~/.bashrc
ln -sf $DOTFILES_REPO/.gitconfig ~/.gitconfig

sudo apt install -y build-essential curl file gcc git
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
source ~/.bashrc

brew install golang npm python3 python@2
brew install bat coreutils exa ghq jq peco powerline-go unzip yq zip

npm install -g npm-check-updates

if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
  # WSL only
else
  # other
  sudo apt install -y keepass2
  $DOTFILES_REPO/installer/cica-font.sh
  $DOTFILES_REPO/installer/code.sh
  $DOTFILES_REPO/installer/gitkraken.sh
  $DOTFILES_REPO/installer/steam.sh
fi
