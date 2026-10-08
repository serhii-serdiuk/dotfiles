#!/bin/bash

SETUP_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")

source "$SETUP_DIR/aux/utils.sh"

# Directory where all KDE projects sources will be placed including kdesrc-build
KDE_SOURCES_DIR=~/Projects/kde/src

# Clone kdesrc-build tool if it doesn't exist already on provided path
if [ -d $KDE_SOURCES_DIR/kdesrc-build ]; then
    log "kdesrc-build is already installed"
    return
fi
log "Setting up KDE development environment..."
mkdir -p $KDE_SOURCES_DIR && cd $KDE_SOURCES_DIR
git clone https://invent.kde.org/sdk/kdesrc-build.git

# Do whole Qt and KDE setup via kdesrc-build
pushd $KDE_SOURCES_DIR/kdesrc-build
./kdesrc-build --initial-setup

# Replace default ~/kde dir with correct one
replace-substring-file "~\/kde" "~\/Projects\/kde" ~/.config/kdesrc-buildrc

# We need to create symbolic link so Kate (or other IDE) could find QML language server
sudo ln -s ../lib/qt6/bin/qmlls /usr/bin/qmlls6

# NOTE: missing build dependency for kate, dolphin and probably some other KDE apps
case $DISTRO in
Tuxedo|KDE|Ubuntu)
    sudo apt -y install libqt6websockets6-dev ;;
esac

# NOTE: adding sources repository might fix some additional build dependencies
case $DISTRO in
Tuxedo)
    echo -e "\n# Needed for some build dependencies\ndeb-src https://mirrors.tuxedocomputers.com/ubuntu/mirror/archive.ubuntu.com/ubuntu jammy main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list
    sudo apt update ;;
esac

# Build some KDE project to be sure that setup process went fine
# ./kdesrc-build kate

popd


# NOTE: additional information can be found here:
# https://kate-editor.org/build-it/
