#!/bin/bash

# For information about Craft visit:
# https://community.kde.org/Craft

set -e

CRAFT_ROOT=~/CraftRoot

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
    if [[ $OSTYPE == linux-gnu* ]]; then
        echo -e "${bold}${color}${text}${no_format}"
    else
        echo ${text}
    fi
}
log_error() {
    error_color="\e[31m"
    log $error_color $*
}

install_linux_dependencies() {
    DISTRO=$(head -n 1 /etc/os-release | cut -d "\"" -f 2 | cut -d " " -f 1)
    DISTRO=${DISTRO,,} && DISTRO=${DISTRO^}

    case $DISTRO in
    Ubuntu|Tuxedo)
        log "Ubuntu-based distro"
        sudo apt update
        sudo apt install git build-essential clang libxcb-xinerama0-dev libgl1-mesa-dev
        ;;
    Fedora)
        log "Fedora"
        # TODO
        ;;
    *)
        log_error "Unknown Linux distribution"
        exit 1 ;;
    esac
}

install_macos_dependencies() {
    if [ ! -f /usr/local/Homebrew/bin/brew ]; then
        echo "Installing Homebrew..."
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    brew install wget gnu-sed
    echo -e "\nexport PATH=$(brew --prefix)/opt/gnu-sed/libexec/gnubin:\$PATH" >> ~/.zprofile
}


log "Defining OS type..."

case $OSTYPE in
linux-gnu*)
    log "Linux"
    install_linux_dependencies
    ;;
darwin*)
    log "macOS"
    install_macos_dependencies
    ;;
*)
    log_error "Unknown OS type"
    exit 1
    ;;
esac

echo
log "Installing Craft..."
rm -rf "$CRAFT_ROOT"
python3 -c "$(wget https://raw.githubusercontent.com/KDE/craft/master/setup/CraftBootstrap.py -O -)" --prefix "$CRAFT_ROOT"

if [[ $OSTYPE == linux-gnu* ]]; then
    echo
    echo
    log "Install linuxdeploy for packaging on Linux"
    source "$CRAFT_ROOT/craft/craftenv.sh"
    craft linuxdeploy
    # NOTE: following fix might be necessary if you encounter error:
    # "execv error: No such file or directory"
    # (https://github.com/linuxdeploy/linuxdeploy/issues/86)
    sed -i "s|AI\x02|\x00\x00\x00|" "$CRAFT_ROOT/dev-utils/bin/linuxdeploy-x86_64.AppImage"
fi
