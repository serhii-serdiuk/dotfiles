case $DISTRO in
Tuxedo|KDE)
    PACKAGE_MANAGER=apt ;;
Fedora)
    PACKAGE_MANAGER=dnf ;;
*)
    PACKAGE_MANAGER=unknown ;;
esac

_log() {
    green="\033[32m"
    no_color="\033[0m"
    echo -e "${green}INFO: `date` - $*${no_color}"
}

# Move files or directories from $HOME into a dotfiles package and link them back with stow
dotfiles-adopt() {
    local package=$1; shift
    local dotfiles=$(realpath ~/.dotfiles)
    local file rel
    for file in "$@"; do
        rel=$(realpath -s --relative-to="$HOME" "$file")
        if [[ $rel == ../* ]]; then
            echo "Not under \$HOME: $file"
            return 1
        fi
        mkdir -p "$dotfiles/$package/$(dirname "$rel")"
        mv "$HOME/$rel" "$dotfiles/$package/$rel" || return 1
    done
    stow -d "$dotfiles" -t "$HOME" -v 1 "$package"
}

_backup_firefox() {
    _log "Backup Firefox setup"

    local backup_dir=$HOME/.backup
    local firefox_backup_dir=$backup_dir/firefox
    local firefox_dir=$HOME/.mozilla/firefox
    local firefox_profile_dir=$firefox_dir/7ultrj4r.default-release
    local firefox_profile_backup_dir=$firefox_backup_dir/7ultrj4r.default-release

    rm -rf $firefox_backup_dir
    mkdir -p $firefox_profile_backup_dir

    cp $firefox_dir/profiles.ini $firefox_backup_dir
    cp $firefox_dir/installs.ini $firefox_backup_dir
    cp -r $firefox_dir/iv60fcat.default $firefox_backup_dir

    cp -r $firefox_profile_dir/extensions/              $firefox_profile_backup_dir/
    cp $firefox_profile_dir/addons.json                 $firefox_profile_backup_dir/
    cp $firefox_profile_dir/containers.json             $firefox_profile_backup_dir/
    cp $firefox_profile_dir/extension-preferences.json  $firefox_profile_backup_dir/
    cp $firefox_profile_dir/extension-settings.json     $firefox_profile_backup_dir/
    cp $firefox_profile_dir/extensions.json             $firefox_profile_backup_dir/
    cp $firefox_profile_dir/prefs.js                    $firefox_profile_backup_dir/
    cp $firefox_profile_dir/times.json                  $firefox_profile_backup_dir/
}

backup-configs() {
    local konsave_profile=configs-plasma$KDE_SESSION_VERSION
    local backup_dir=$HOME/.backup

    _log "Backup konsave profile"
    rm -rf $HOME/.config/konsave/profiles/$konsave_profile
    konsave -s $konsave_profile
    konsave -e $konsave_profile

    mv $backup_dir/$konsave_profile.knsv $backup_dir/$konsave_profile.knsv.old
    mv $HOME/$konsave_profile.knsv $backup_dir/

    # _log "Backup global configs"
    # local global_configs_backup_dir=$HOME/.backup/global-configs
    # mkdir -p $global_configs_backup_dir/etc
    # cp /etc/tlp.conf $global_configs_backup_dir/etc/

#     _backup_firefox
}

install-tapo-controller() {
    _log "Installing Tapo smart socket controller..."

    mkcd $PROJECTS_DIR
    git clone https://github.com/K4CZP3R/tapo-p100-python.git && cd tapo-p100-python

    sudo $PACKAGE_MANAGER install python3-venv
    python3 -m venv venv && source venv/bin/activate && pip install -r req.txt
}
