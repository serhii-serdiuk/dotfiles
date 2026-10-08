#!/bin/bash

set -e

SETUP_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

source "$SETUP_DIR/aux/utils.sh"
source "$SETUP_DIR/aux/install-functions.sh"

BACKUP_DIR=$SETUP_DIR/../../backup

DEVELOPMENT_INSTALL=no
MINIMAL_INSTALL=no
INSTALL_FLATPAK_APPS=no

parse_options() {
    options=$(getopt -l "develop,minimal,flatpak,non-interactive" -o "dmfy" -a -- "$@")
    eval set -- "$options"

    while true; do
        case $1 in
        -d|--develop)
            DEVELOPMENT_INSTALL=yes ;;
        -m|--minimal)
            MINIMAL_INSTALL=yes ;;
        -f|--flatpak)
            INSTALL_FLATPAK_APPS=yes ;;
        -y|--non-interactive)
            NON_INTERACTIVE=-y ;;
        --)
            shift
            break ;;
        *)
            echo "Wrong option specified, exit"
            exit 1
            ;;
        esac
        shift
    done
}

generate_locale() {
    log "Generate additional locale"
    sudo locale-gen uk_UA.UTF-8
}

disable_tuxedo_services() {
    set +e
    case $DISTRO in
    Tuxedo)
        log "Disable and remove some Tuxedo services"
        sudo systemctl disable tuxedo-tomte.timer
        sudo /opt/tuxedo-control-center/resources/dist/tuxedo-control-center/data/service/tccd --stop
#         sudo apt purge tuxedo-tomte $NON_INTERACTIVE
        sudo apt purge tuxedo-control-center tuxedo-webfai-creator tuxedo-webfai-grub $NON_INTERACTIVE
        sudo apt autoremove $NON_INTERACTIVE
        sudo rm /usr/local/share/applications/tuxedo-control-center.desktop
        sudo rm /usr/local/share/applications/tuxedo-webfai-creator.desktop
        rm $HOME/.config/autostart/tuxedo-control-center-tray.desktop
        rm -rf $HOME/.config/tuxedo-control-center
        rm -rf $HOME/.config/tuxedo-webfai-creator
        rm -rf $HOME/.tcc
        ;;
    esac
    set -e
}

change_default_theme_start_icon() {
    log "Change default theme start icon"
    default_theme_icons_dir=/usr/share/plasma/desktoptheme/default/icons
    if [ ! -f $default_theme_icons_dir/start.svgz.bak ]; then
        sudo cp $default_theme_icons_dir/start.svgz $default_theme_icons_dir/start.svgz.bak
    fi
    case $DISTRO in
    Tuxedo)
        sudo cp $BACKUP_DIR/icons/tuxedo-dark-theme-start-white.svgz $default_theme_icons_dir/start.svgz ;;
    esac
}

set_common_packages() {
    # Common packages
    # pkg_list=( powerline htop hstr vim neovim tmux yt-dlp
    pkg_list=( powerline htop
               bat ripgrep highlight
               vim vim-gtk3 wl-clipboard neovim tmux
               zathura mpv mpv-mpris yt-dlp
               yakuake filelight kdf krename kget kolourpaint kalk koko
             )

    case $DISTRO in
    Ubuntu|Tuxedo|KDE)
        pkg_list+=" powerline-gitstatus gitleaks fonts-firacode neofetch silversearcher-ag" ;;
    Fedora)
        # TODO: check if powerline-gitstatus available
        # TODO: check if gitleaks available
        pkg_list+=" fira-code-fonts fastfetch fzf the_silver_searcher yazi" ;;
        # NOTE: ffmpeg-free probably needed on Fedora
    esac

    if [ $MINIMAL_INSTALL = no ]; then
        case $DISTRO in
        Ubuntu|Tuxedo|KDE)
            pkg_list+=" fonts-noto-cjk fonts-noto-cjk-extra" ;;
        esac
    fi

    echo
    log "Set common packages: ${pkg_list[@]}"
    PACKAGES=${pkg_list[@]}

    # Common Python packages
    python_pkg_list=( konsave )
    echo
    log "Set common Python packages: ${python_pkg_list[@]}"
    PYTHON_PACKAGES=${python_pkg_list[@]}

    if [ $INSTALL_FLATPAK_APPS = no ]; then
        return
    fi
    # Common Flatpak apps
    flatpak_list=()
    if [ $MINIMAL_INSTALL = no ]; then
        flatpak_list=( com.github.tchx84.Flatseal
                       com.jgraph.drawio.desktop
                       com.obsproject.Studio
                       com.slack.Slack
                       com.spotify.Client
                       com.todoist.Todoist
                       im.kaidan.kaidan
                       io.github.DenysMb.Kontainer
                       io.github.alainm23.planify
                       io.gitlab.news_flash.NewsFlash
                       me.hyliu.fluentreader
                       org.chromium.Chromium
                       org.gabmus.gfeeds
                       org.inkscape.Inkscape
                       org.kde.alligator
                       org.kde.calligra
                       org.kde.ghostwriter
                       org.kde.haruna
                       org.kde.kalm
                       org.kde.kclock
                       org.kde.kdenlive
                       org.kde.keysmith
                       org.kde.khangman
                       org.kde.klettres
                       org.kde.klevernotes
                       org.kde.kphotoalbum
                       org.kde.ktouch
                       org.kde.marknote
                       org.kde.minuet
                       org.kde.neochat
                       org.kde.parley
                       org.kde.plasmatube
                       org.kde.ruqola
                       org.kde.tokodon
                       org.keepassxc.KeePassXC
                       org.qbittorrent.qBittorrent
                       org.signal.Signal
                       us.zoom.Zoom
                     )
    fi
    echo
    log "Set common Flatpak apps: ${flatpak_list[@]}"
    FLATPAK_APPS=${flatpak_list[@]}
}

append_networking_packages() {
    # Packages for networking
    pkg_list=( nmap samba
               openssh-server  # create functions disable-pwd-ssh-access/enable-pwd-ssh-access
               # vnc server
             )

    case $DISTRO in
    Ubuntu|Tuxedo|KDE)
        pkg_list+=" proxychains4" ;;
    Fedora)
        pkg_list+=" proxychains-ng" ;;
    esac

    echo
    log "Append packages for networking: ${pkg_list[@]}"
    PACKAGES+=" ${pkg_list[@]}"

    if [ $INSTALL_FLATPAK_APPS = no ]; then
        return
    fi
    # Flatpak apps for networking
    flatpak_list=()
    if [ $MINIMAL_INSTALL = no ]; then
        case $DISTRO in
        Ubuntu|Tuxedo|KDE)
            flatpak_list=( org.kde.krdc ) ;;
        esac
    fi
    log "Append Flatpak apps for networking: ${flatpak_list[@]}"
    FLATPAK_APPS+=" ${flatpak_list[@]}"
}

append_development_packages() {
    # Packages for development
    pkg_list=( git git-cola git-gui gitk clang cmake cmake-gui ccache
               # kdiff3 kcolorchooser
               #kommit  # NOTE: integrates with Dolphin and hugely slows it down
               #kirigami-gallery plasma-sdk  # TODO: check later if still relevant
             )

    case $DISTRO in
    Ubuntu|Tuxedo|KDE)
        pkg_list+=" git-filter-repo build-essential ninja-build clang-format cpplint cmake-curses-gui"
        pylsp_list=" python3-pylsp python3-rope python3-pyflakes python3-mccabe python3-pycodestyle"
        pylsp_list+=" python3-pydocstyle python3-autopep8 python3-yapf pylint" ;;
    Fedora)
        # TODO: check if git-filter-repo available
        # TODO: check if cpplint available
        pkg_list+=" gcc g++ clang-tools-extra" ;;
    esac
    pkg_list+="$pylsp_list"

    echo
    log "Append packages for development: ${pkg_list[@]}"
    PACKAGES+=" ${pkg_list[@]}"

    # Python packages for development
    # python_pkg_list=( git-filter-repo powerline-gitstatus cpplint )
    # echo
    # log "Append Python packages for development: ${python_pkg_list[@]}"
    # PYTHON_PACKAGES+=" ${python_pkg_list[@]}"

    if [ $INSTALL_FLATPAK_APPS = no ]; then
        return
    fi
    # Flatpak apps for development
    flatpak_list=()
    if [ $MINIMAL_INSTALL = no ]; then
        flatpak_list=( dev.zed.Zed
                       io.qt.QtCreator
                       org.genivi.DLTViewer
                       org.gnome.meld
                       org.kde.kate
                       org.kde.kcachegrind
                       org.kde.kcharselect
                       org.kde.kdevelop
                       org.kde.kompare
                       org.kde.kontrast
                       org.kde.kruler
                       org.kde.okteta
                       org.kde.umbrello
                     )
    fi
    echo
    log "Append Flatpak apps for development: ${flatpak_list[@]}"
    FLATPAK_APPS+=" ${flatpak_list[@]}"
}

set_package_manager() {
    echo
    case $DISTRO in
    Ubuntu|Tuxedo|KDE)
        PACKAGE_MANAGER=apt ;;
    Fedora)
        PACKAGE_MANAGER=dnf ;;
    *)
        log "Package manager wasn't set, cannot proceed further"
        PACKAGE_MANAGER=unknown
        exit 1 ;;
    esac
    log "Package manager was set to '$PACKAGE_MANAGER'"
}

install_updates() {
    log "Updating the system..."
    case $DISTRO in
    Ubuntu|Tuxedo)
        sudo apt update && sudo apt upgrade $NON_INTERACTIVE && sudo apt autoremove $NON_INTERACTIVE ;;
    KDE)
        pkcon refresh && pkcon update ;;
    Fedora)
        sudo dnf copr enable lihaohong/yazi $NON_INTERACTIVE

        sudo dnf upgrade --refresh $NON_INTERACTIVE
    esac
}

install_packages() {
    echo
    log "Installing packages..."
    sudo $PACKAGE_MANAGER install ${PACKAGES[@]} $NON_INTERACTIVE

    case $DISTRO in
    Ubuntu|Tuxedo|KDE)
        if [ ! -e ~/.fzf ]; then
            # Newer version has better integration with shell
            echo
            log "Installing FZF from GitHub..."
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
            ~/.fzf/install
        fi

        # https://github.com/sharkdp/bat?tab=readme-ov-file#on-ubuntu-using-apt
        mkdir -p ~/.local/bin
        ln -sf /usr/bin/batcat ~/.local/bin/bat
        ;;
    esac

    if [ ! -e ~/.ranger ]; then
        echo
        log "Installing Ranger from GitHub..."
        git clone https://github.com/ranger/ranger.git ~/.ranger
        pushd ~/.ranger && sudo make install && popd
    fi
    if [ ! -e ~/.config/ranger/plugins ]; then
        mkdir -p ~/.config/ranger/plugins
    fi
    echo
    pushd ~/.config/ranger/plugins
    if [ ! -e ranger-fzf-filter ]; then
        log "Installing Ranger FZF plugin from GitHub..."
        git clone https://github.com/MuXiu1997/ranger-fzf-filter.git
        # Add a binding to your ~/.config/ranger/rc.conf file to quickly use :fzf_filter:
        # map f console fzf_filter%space
    fi
    popd
}

# Needs gitleaks installed first: the pre-commit hook runs it on every commit
enable_dotfiles_git_hooks() {
    echo
    log "Enable git hooks of the dotfiles repo (secret scan before each commit)"
    git -C "$SETUP_DIR/.." config core.hooksPath .githooks
}

install_python_packages() {
    echo
    log "Installing Python packages..."
    # sudo $PACKAGE_MANAGER install python3-pip $NON_INTERACTIVE
    sudo $PACKAGE_MANAGER install pipx $NON_INTERACTIVE
    pipx install ${PYTHON_PACKAGES[@]}
    pipx ensurepath
    # pipx completions
    # Needed for running konsave in this terminal without re-login
    # export PATH=$PATH:$HOME/.local/bin
    # TODO: reload shell config in current terminal

    # pip install python-lsp-server
}

install_nodejs_packages() {
    echo
    log "Installing Node.js packages..."

    sudo $PACKAGE_MANAGER install nvm $NON_INTERACTIVE
    source /usr/share/nvm/init-nvm.sh

    nvm install v20.9.0
    nvm install-latest-npm  # NOTE: what about "sudo apt install npm"?

    npm install -g bash-language-server
    npm install -g typescript-language-server typescript
    npm install -g vscode-json-languageserver
    npm install -g yaml-language-server
}

install_flatpak_apps() {
    echo
    log "Installing apps from Flathub..."
    sudo $PACKAGE_MANAGER install flatpak $NON_INTERACTIVE
    case $DISTRO in
    Ubuntu)
        sudo $PACKAGE_MANAGER install plasma-discover-backend-flatpak $NON_INTERACTIVE ;;
    esac
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install ${FLATPAK_APPS[@]} $NON_INTERACTIVE
}


log "Starting system setup..."

parse_options $@
generate_locale
case $DISTRO in
Tuxedo)
    disable_tuxedo_services
esac
change_default_theme_start_icon

set_common_packages
append_networking_packages
if [ $DEVELOPMENT_INSTALL = yes ]; then
    append_development_packages
fi

set_package_manager
install_updates
install_packages
enable_dotfiles_git_hooks
install_python_packages
# if [ $DEVELOPMENT_INSTALL = yes ]; then
#     install_nodejs_packages  # TODO: doesn't work on Fedora, maybe should be reconsider
    # NOTE: using 'source' command here instead of just running script as usual
    # because otherwise 'go to definition' feature of bash language server doesn't work
#     source scripts/setup-kde-devenv.sh  # TODO: probably need to refactor
# fi
# if [ $MINIMAL_INSTALL = no ]; then
    # install_virtualbox $NON_INTERACTIVE
    # install_teamviewer $NON_INTERACTIVE
# fi
# install_appimagelauncher  # TODO: doesn't work, need to check
if [ $INSTALL_FLATPAK_APPS = yes ]; then
    install_flatpak_apps
fi

echo
source "$SETUP_DIR/aux/restore-configs.sh"

echo
log "System setup is completed!"
read -p "Would you like to reboot now [y/N]: " yn
case $yn in
    [Yy]* ) log "Rebooting..."; reboot;;
    * ) log "Leave the setup script";;
esac


# Further improvements of configuration:
# TODO: backup tiling config
# TODO: [Dolphin] Add shortcut Ctrl+D to open Downloads
# TODO: [Settings] Shortcut for context menu (right click)
# TODO: [KatePart] Ctrl+/ comments current line and goes to next one
# TODO: [Dolphin] Template feature
# TODO: [System] Consider to limit the size of logs - https://www.freedesktop.org/software/systemd/man/journald.conf.html
# TODO: [Settings] Customize Login Screen (set to default KDE Plasma)

# Suggestions for upstream:
# [Kate] Possibility to clone shortcut scheme
# [Kate] Cannot delete scheme permanently, it can be recreated if use the same name
# [Kate] Ctrl+Tab in KWrite doesn't work

# date --set="16 Sep 2023 17:35:00"
