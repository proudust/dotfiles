sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

git clone https://github.com/proudust/dotfiles.git ~/dotfiles
ln -sf ~/dotfiles/.bashrc ~/.bashrc
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig

sudo apt install -y build-essential curl file gcc git
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
source ~/.bashrc

brew install golang npm python3 python@2
brew install exa ghq jq peco unzip yq zip

npm install -g npm-check-updates
