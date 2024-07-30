#!/bin/bash

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install common packages
sudo apt install -y git vim curl wget build-essential net-tools shellcheck

# Install specific applications (modify as needed)
sudo apt install -y tmux htop atop sysstat postgresql-client

# Install python3
sudo apt install -y python3 python3-pip

#Install VPN
sudo apt install -y openvpn

# Install video & stream controller
sudo apt install -y ffmpeg

# Clean up
sudo apt autoremove -y
sudo apt clean

echo "Setup complete!"
