#!/bin/bash
set -e
echo -e "\e[32m
# # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#           Revela Network Installation Script          #
#       This Script only works on Ubuntu & Debian       #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # #\e[0m"

# Check if user is sudo
if [[ $EUID -ne 0 ]]; then
    echo -e "\e[32m* This script must be executed via sudo user. \e[0m" 1>&2
    exit 1
fi

# Proceed?
while true; do
    RESET="\e[0m"
    GREEN="\e[32m"
    read -p "$(echo -e $GREEN"\n* Do you want to proceed? (Y/N)"$RESET)" yn
    case $yn in
        [yY] ) echo -e "\e[32m* Confirmed. Continuing..\e[0m"; break;;
        [nN] ) echo -e "\e[32m* Confirmed. Exiting Installation..\e[0m"; exit;;
        * ) echo -e "\e[32m* Invalid Response.\e[0m";;
    esac
done

echo -e "\e[32m* Installing dependencies..\e[0m"
sudo apt update > /dev/null 2>&1

# Install Curl
if ! [ -x "$(command -v curl)" ]; then
    echo -e "\e[32m* Installing curl.\e[0m"
    sudo apt install -y curl > /dev/null 2>&1
fi

# Install NodeJS
if ! [ -x "$(command -v node)" ]; then
    echo -e "\e[32m* Installing NodeJS\e[0m"
    curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash - > /dev/null 2>&1 && sudo apt install -y nodejs > /dev/null 2>&1
fi

# Install NPM 
if ! [ -x "$(command -v npm)" ]; then
    echo -e "\e[32m* Installing NPM.\e[0m"
    sudo apt install -y npm > /dev/null 2>&1
fi

# Install Git
if ! [ -x "$(command -v git)" ]; then
    echo -e "\e[32m* Installing git.\e[0m"
    sudo apt install -y git > /dev/null 2>&1
fi

# Install Pm2
if ! [ -x "$(command -v pm2)" ]; then
    echo -e "\e[32m* Installing pm2.\e[0m"
    sudo npm install pm2 -g > /dev/null 2>&1
fi

# Install Revela Network app
echo -e "\e[32m* Starting Installation\e[0m"
git clone https://github.com/DIVISIONSolar/Revela-App > /dev/null 2>&1
cd ~/Revela-App
npm install > /dev/null 2>&1
cd ~/Revela-App/node_modules/revela-frontend/public
git clone https://github.com/DIVISIONSolar/Revela-Games games > /dev/null 2>&1
echo -e "\e[32m* Installation Completed\e[0m"

# Start Revela
cd /root/Revela-App
sudo pm2 start "npm start" --name "Revela App"
sudo pm2 startup
sudo pm2 save
