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
echo -e "\e[32m* Switching to root dir\e[0m"
cd /root
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

# Setup SSL & Domain

RESET="\e[0m"
GREEN="\e[32m"

# Ask if they want to setup a domain (if not load balancing)
while true; do
    read -p "$(echo -e $GREEN"\n* Do you want to set up a domain? (Y/N)"$RESET)" domain_yn
    case $domain_yn in
        [yY] )
            echo -e "\e[32m* Starting domain setup...\e[0m"

            # Prompt for domain name
            read -p "$(echo -e $GREEN"\n* Enter your domain (e.g., example.com):"$RESET)" domain_name

            # Install Certbot for SSL
            sudo apt install -y certbot python3-certbot-nginx > /dev/null 2>&1

            # Request SSL certificate
            sudo certbot --nginx -d $domain_name

            # Add domain to Nginx config
            cat <<EOL | sudo tee -a /etc/nginx/sites-available/proxy.conf > /dev/null
upstream Revela {
    server 127.0.0.1:8080;
}

server {
    server_name $domain_name;
    listen 80;
}

server {
    listen 443 ssl;
    server_name $domain_name;
    ssl_certificate /etc/letsencrypt/live/$domain_name/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain_name/privkey.pem;

    location / {
        # Generic configuration for proxy:
        # Upgrade WebSockets
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'Upgrade';
        # Increase header buffer
        proxy_set_header Host \$host; 
        proxy_connect_timeout 10;
        proxy_send_timeout 90;
        proxy_read_timeout 90;
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
        proxy_temp_file_write_size 256k;
        proxy_pass http://Revela;
    }
}

EOL

            # Remove default config
            sudo rm /etc/nginx/sites-enabled/default
            sudo rm /etc/nginx/sites-available/default

            # Create symbolic link
            sudo ln -s /etc/nginx/sites-available/proxy.conf /etc/nginx/sites-enabled/proxy.conf

            # Restart Nginx
            sudo systemctl restart nginx

            echo -e "\e[32m* Domain setup completed\e[0m"
            break;;
        [nN] )
            echo -e "\e[32m* Skipped domain setup\e[0m"
            break;;
        * ) echo -e "\e[32m* Invalid Response.\e[0m";;
    esac
done
