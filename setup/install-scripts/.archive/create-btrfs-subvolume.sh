#!/bin/bash

# NOTE: This script is supposed to be executed on openSUSE system
# in order to create subvolume inside user's home directory

set -e

TARGET_DIR_NAME=".cache"
PARENT_DIR_PATH="$HOME"
TARGET_DIR_PATH="$PARENT_DIR_PATH/$TARGET_DIR_NAME"
ROOT_PARTITION=/dev/nvme0n1p2

# Backup target directory
mv "$TARGET_DIR_PATH" "$TARGET_DIR_PATH.bak"

# Mount root subvolume
sudo mount $ROOT_PARTITION -o subvol=@ /mnt

# Create new subvolume
sudo mkdir -p "/mnt$PARENT_DIR_PATH"
sudo btrfs subvolume create "/mnt$TARGET_DIR_PATH"

# Adjust ownership
sudo chown -R $USER:users "/mnt$HOME"

# Copy content to new subvolume
cp -r "$TARGET_DIR_PATH.bak/"* "/mnt$TARGET_DIR_PATH/"

# Unmount root subvolume
sudo umount /mnt

# Add relevant entry in /etc/fstab
sudo vim /etc/fstab

echo "Reboot is required to mount new btrfs subvolume"
