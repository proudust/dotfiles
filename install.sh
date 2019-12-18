sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

sudo apt install -y build-essential curl file gcc git
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"

brew install golang npm python3 python@2
brew install ghq jq peco unzip zip

git clone https://github.com/proudust/dotfiles.git ~/dotfiles
ln -sf ~/dotfiles/.bashrc ~/.bashrc
