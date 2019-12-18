sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

git clone https://github.com/proudust/dotfiles.git ~/dotfiles
ln -sf ~/dotfiles/.bashrc ~/.bashrc

sudo apt install -y build-essential curl file gcc git
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
source ~/.bashrc

brew install golang npm python3 python@2
brew install ghq jq peco unzip yq zip
