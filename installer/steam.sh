echo 'deb http://httpredir.debian.org/debian/ jessie main contrib non-free' | sudo tee -a /etc/apt/sources.list
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install -y steam
