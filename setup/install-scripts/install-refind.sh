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

install_refind_theme() {
    refind_dir=/boot/efi/EFI/refind
    refind_theme_conf=$refind_dir/themes/refind-theme-regular/theme.conf

    log "Installing rEFInd theme Regular..."
    git clone https://github.com/bobafetthotmail/refind-theme-regular.git

    # Remove unnecessary files
    rm -rf refind-theme-regular/{src,.git}
    rm refind-theme-regular/install.sh

    # Remove old version from rEFInd directory
    sudo rm -rf $refind_dir/themes/refind-theme-regular

    # Create directory for themes in case of first install and copy files
    sudo mkdir -p $refind_dir/themes
    sudo cp -r refind-theme-regular $refind_dir/themes/

    # Cleanup
    rm -rf refind-theme-regular

    # Enable installed theme
    echo -e "\ninclude themes/refind-theme-regular/theme.conf" | sudo tee -a $refind_dir/refind.conf > /dev/null

    # Switch to dark theme
    sudo sed -i '/128.*bg\./s/^/#/g' $refind_theme_conf
    sudo sed -i '/128.*selection-big/s/^/#/g' $refind_theme_conf
    sudo sed -i '/128.*selection-small/s/^/#/g' $refind_theme_conf

    sudo sed -i '/128.*bg_dark/s/^#//g' $refind_theme_conf
    sudo sed -i '/128.*selection_dark-big/s/^#//g' $refind_theme_conf
    sudo sed -i '/128.*selection_dark-small/s/^#//g' $refind_theme_conf
}

install_refind() {
    refind_dir=/boot/efi/EFI/refind

    if sudo [ -d $refind_dir ]; then
        log "rEFInd is already installed"
        return
    fi

    log "Installing rEFInd boot manager..."
    case $DISTRO in
    Tuxedo|KDE)
        sudo apt-add-repository ppa:rodsmith/refind
        sudo apt update
        sudo apt install refind ;;
    Fedora)
        # TODO: need to test on Fedora installation on VB
        # check here for details: https://www.rodsbooks.com/refind/getting.html
        sudo dnf install rEFInd ;;
        # sudo refind-install
    *)
        log_error "Unknown Linux distribution"
        exit 1 ;;
    esac
}

install_refind
install_refind_theme
