#!/bin/bash

# Update system packages
sudo apt update -y

# Install Cockpit
echo "Installing Cockpit..."
sudo apt install cockpit -y

# Install prerequisites for Oh My Zsh
echo "Installing prerequisites for Oh My Zsh..."
sudo apt install curl wget git -y

# Install Zsh
echo "Installing Zsh..."
sudo apt install zsh -y

# Install Oh My Zsh
echo "Installing Oh My Zsh..."
yes | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Change default shell to Zsh
echo "Changing default shell to Zsh..."
chsh -s $(which zsh)

# Install Docker
echo "Installing Docker..."
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update -y
sudo apt install docker-ce docker-compose -y

# Create /docker and nested directories
echo "Creating /docker and nested directories..."
sudo mkdir -p /docker/plex /docker/plex/filme /docker/plex/musik /docker/plex/serien /docker/nginx

# Download Docker Compose files
echo "Downloading Docker Compose files..."
sudo curl -L https://raw.githubusercontent.com/Akuras88/docker-composes/main/nginx-docker-compose.yml -o /docker/nginx/docker-compose.yml
sudo curl -L https://raw.githubusercontent.com/Akuras88/docker-composes/main/plex-docker-compose.yml -o /docker/plex/docker-compose.yml

# Set a static IP for Wi-Fi
echo "Setting static IP for Wi-Fi..."
sudo bash -c 'cat > /etc/netplan/01-network-manager-all.yaml' <<EOL
network:
  version: 2
  renderer: NetworkManager
  wifis:
    wlp2s0:
      dhcp4: no
      addresses: [192.168.179.12/24]
      routes:
      - to: 0.0.0.0/0
        via: 192.168.179.1
      nameservers:
        addresses: [8.8.8.8,8.8.4.4]
      access-points:
        "Gast":
          password: "2Bekloppte"
EOL

sudo netplan apply

# Install Portainer
echo "Installing Portainer..."
sudo docker volume create portainer_data
sudo docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce

# Start Docker Compose services
echo "Starting Docker Compose services..."
sudo docker-compose -f /docker/nginx/docker-compose.yml up -d
sudo docker-compose -f /docker/plex/docker-compose.yml up -d

echo "Installation and setup completed. Please restart your terminal."
