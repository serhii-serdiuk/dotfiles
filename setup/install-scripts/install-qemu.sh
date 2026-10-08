#!/bin/bash

set -e

DISTRO=$(head -n 1 /etc/os-release | cut -d "\"" -f 2 | cut -d " " -f 1)
DISTRO=${DISTRO,,} && DISTRO=${DISTRO^}

log() {
    no_format="\e[0m"
    bold="\e[1m"
    color="\e[34m"  # default is blue color
    if [ $# -eq 2 ]; then
        color=$1
        text=$2
    else
        text=$1
    fi
    echo -e "${bold}${color}${text}${no_format}"
}
log_error() {
    error_color="\e[31m"
    log $error_color $*
}

install_quickemu() {
    log "Installing Quickemu..."
    case $DISTRO in
    Ubuntu|Tuxedo)
        sudo apt-add-repository ppa:flexiondotorg/quickemu
        sudo apt update
        sudo apt install quickemu
        ;;
    Fedora)
        sudo dnf install git edk2-tools genisoimage mesa-demos spice-gtk-tools qemu-system-*
        git clone --filter=blob:none https://github.com/quickemu-project/quickemu
        ;;
    esac
}

install_qqx() {
    log "Installing qqX..."
    git clone https://github.com/TuxVinyards/qqX
    cd qqX && ./qqX_setup_and_install
}


log "Installing virtualization packages..."

case $DISTRO in
Ubuntu|Tuxedo)
    sudo apt install qemu-utils qemu-system-x86 virt-manager
    ;;
Fedora)
    sudo dnf install @virtualization
    ;;
*)
    log_error "Unknown Linux distribution"
    exit 1 ;;
esac

sudo systemctl enable libvirtd
sudo systemctl start libvirtd

sudo usermod -aG libvirt $USER

install_quickemu
install_qqx
