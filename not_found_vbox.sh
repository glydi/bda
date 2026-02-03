#!/bin/bash

echo "🔧 Installing VirtualBox Guest Additions..."

# Update system
sudo apt update

# Install required packages
sudo apt install -y build-essential dkms linux-headers-$(uname -r)

# Create mount point
sudo mkdir -p /media/cdrom

# Try mounting the CD-ROM
if [ -e /dev/cdrom ]; then
    sudo mount /dev/cdrom /media/cdrom
elif [ -e /dev/sr0 ]; then
    sudo mount /dev/sr0 /media/cdrom
else
    echo "❌ CD-ROM device not found."
    echo "👉 Make sure: Devices → Insert Guest Additions CD Image"
    exit 1
fi

# Run installer
cd /media/cdrom || exit 1
sudo ./VBoxLinuxAdditions.run

# Finish
echo "✅ Installation complete. Rebooting..."
sudo reboot
