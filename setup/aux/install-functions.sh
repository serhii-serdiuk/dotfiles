source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# TODO: insvestigate why "sourcing" this file from graphical terminal logs out from graphical session

install_virtualbox() {
    set +e; pkg-status virtualbox > /dev/null; res=$?; set -e
    if [ $res -eq 0 ]; then
        log "VirtualBox is already installed"
        return
    fi
    log "Installing VirtualBox..."
    local auto_confirm=$1

    if [ $DISTRO == "Tuxedo" ]; then
        sudo apt install virtualbox-ext-pack virtualbox-guest-additions-iso $auto_confirm
    elif [ $DISTRO == "Ubuntu" ]; then
        sudo apt install virtualbox $auto_confirm
        # NOTE: [Guest OS] Install following packages before installing guest additions:
        # sudo apt install gcc make perl
    elif [ $DISTRO == "Fedora" ]; then
        # sudo dnf config-manager --add-repo https://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo
        # sudo dnf -y install VirtualBox-7.0

        # TODO: check installing via RPM Fusion

        # Add RPM Fusion repositories
        sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm $auto_confirm

        # Install VirtualBox
        # https://rpmfusion.org/Howto/VirtualBox
    else
        echo "Unknown distro: $DISTRO"
        return
    fi

    log "Add current user to 'vboxusers' group for achieving of full featured experience"
    sudo usermod -aG vboxusers $USER

    read -p "In order to take effect of user group changes need to reboot your system. Do it now [y/N]: " yn
    case $yn in
        [Yy]* ) log "Rebooting..."; reboot;;
        * ) log "VirtualBox installing done";;
    esac

    # NOTE: [Guest OS] Add current user to 'vboxsf' group to get access to shared folder without 'sudo'
    # sudo usermod -aG vboxsf $USER
}

install_teamviewer() {
    set +e; pkg-status teamviewer > /dev/null; res=$?; set -e
    if [ $res -eq 0 ]; then
        log "TeamViewer is already installed"
        return
    fi
    log "Installing TeamViewer..."
    local auto_confirm=$1

    wget -O- https://download.teamviewer.com/download/linux/signature/TeamViewer2017.asc | gpg --dearmor | sudo tee /usr/share/keyrings/teamview.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/teamview.gpg] http://linux.teamviewer.com/deb stable main" | sudo tee /etc/apt/sources.list.d/teamviewer.list

    sudo apt update && sudo apt -o DPkg::Options::="--force-confnew" install teamviewer $auto_confirm
}

install_appimagelauncher() {
    sudo apt-add-repository ppa:appimagelauncher-team/stable
    sudo apt update
    sudo apt install appimagelauncher

    # NOTE: ppa is not available for Ubuntu 24.04 and you need to download and install .deb package
    # sudo dpkg -i appimagelauncher_2.2.0-gha111.d9d4c73+bionic_amd64.deb
    # sudo apt install --fix-broken

    # NOTE: also on Ubuntu 24.04 you probably need to install libfuse2 to run AppImages
    # sudo apt install libfuse2
}
