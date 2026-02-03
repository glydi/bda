#!/bin/bash

echo "🔧 Fixing Guest Additions without CD-ROM..."

sudo apt update
sudo apt install -y build-essential dkms linux-headers-$(uname -r) wget

# Download latest Guest Additions ISO
cd /tmp || exit 1
wget https://download.virtualbox.org/virtualbox/7.0.14/VBoxGuestAdditions_7.0.14.iso

# Create mount point
sudo mkdir -p /mnt/vbox

# Mount ISO directly
sudo mount -o loop VBoxGuestAdditions_7.0.14.iso /mnt/vbox

# Run installer
cd /mnt/vbox || exit 1
sudo ./VBoxLinuxAdditions.run

echo "✅ Done. Rebooting..."
sudo reboot
