#!/bin/bash

SETUP_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")

source "$SETUP_DIR/aux/utils.sh"

BACKUP_DIR=$SETUP_DIR/../../backup

DATA_PARTITION_PATH=/data

_check_data_partition() {
    log "Check $DATA_PARTITION_PATH partition ownership"
    if [ ! -d $DATA_PARTITION_PATH ]; then
        # NOTE: for testing purpose only
        sudo mkdir -p $DATA_PARTITION_PATH
    fi
    data_user=$(stat -c %U $DATA_PARTITION_PATH)
    if [ $data_user == "root" ]; then
        log "Set ownership of $DATA_PARTITION_PATH to current user"
        sudo chown -R $USER:$USER $DATA_PARTITION_PATH
    fi
}

_restore_firefox() {
    log "Restore Firefox setup"
    firefox_dir=$HOME/.mozilla/firefox
    mkdir -p $firefox_dir
    if [ -d $firefox_dir/*.default ]; then
        mv $firefox_dir/*.default $firefox_dir/old.default
    fi
    if [ -d $firefox_dir/*.default-release ]; then
        mv $firefox_dir/*.default-release $firefox_dir/old.default-release
    fi
    cp -rb $BACKUP_DIR/firefox/* $firefox_dir/
}

_restore_global_config_by_link() {
    source_file=$1
    destination_file=$2
    destination_dir=$(dirname $(sudo realpath "$2"))

    if sudo [ -L "$destination_file" ]; then
        return
    fi
    if sudo [ -f "$destination_file" ]; then
        sudo mv "$destination_file" "$destination_file.bak"
    fi
    sudo ln -s "$source_file" "$destination_dir"
}

_restore_global_config_by_copy() {
    source_file=$1
    destination_file=$2
    destination_dir=$(dirname $(realpath "$2"))

    if sudo [ -f "$destination_file" ]; then
        sudo mv "$destination_file" "$destination_file.bak"
    fi
    sudo cp "$source_file" "$destination_dir"
}

_restore_global_config_by_append() {
    source_file=$1
    destination_file=$2

    sudo mv "$destination_file" "$destination_file.bak"
    echo | sudo tee -a "$destination_file"
    cat "$source_file" | sudo tee -a "$destination_file"
}

_restore_global_configs() {
    log "Restore global configs"

    sudo mkdir -p /root/.bashrc.d
    sudo ln -sf ~/.bashrc.d/aliases.sh /root/.bashrc.d/
    # sudo ln -sf ~/.bashrc.d/functions.sh /root/.bashrc.d/

    sudo mkdir -p /root/.config
    _restore_global_config_by_link ~/.config/ranger /root/.config/ranger

    mkdir -p ~/.vim
    _restore_global_config_by_link ~/.vim /root/.vim

    _restore_global_config_by_link ~/.bashrc /root/.bashrc
    _restore_global_config_by_link ~/.inputrc /root/.inputrc
    _restore_global_config_by_link ~/.vimrc /root/.vimrc
    _restore_global_config_by_link ~/.zshrc /root/.zshrc

    log "Changing default login shell to zsh"
    chsh -s /bin/zsh
    log "Changing default login shell to zsh (for root)"
    sudo chsh -s /bin/zsh

    # global_configs_backup=$BACKUP_DIR/global-configs
    # _restore_global_config_by_copy $global_configs_backup/etc/tlp.conf /etc/tlp.conf

    # TODO: move to setup-work
    # _restore_global_config_by_append /data/Workspace/Projects/setup-work/data/hosts /etc/hosts
}

_replace_user_dir_by_link() {
    link_dir=$1
    target_dir=$2
    echo "link_dir=$link_dir, target_dir=$target_dir"
    if [ -L "$link_dir" ]; then
        echo "$link_dir is already a link, skipping"
        return
    fi
    if [ ! -d "$target_dir" ]; then
        echo "Directory $target_dir does not exist, creating it and moving content from $link_dir"
        mkdir -p "$target_dir"
        if [ -d "$link_dir" ]; then
            mv "$link_dir" "$target_dir/.." 2> /dev/null
        fi
    fi
    if [ -d "$link_dir" ]; then
        if [ ! -z $(ls -A "$link_dir") ]; then
            echo "$link_dir is not an empty directory, clean it manually and try again"
            return
        else
            echo "$link_dir is an empty directory, removing it in order to create a link"
            rm -r "$link_dir"
        fi
    fi
    ln -s "$target_dir" "$link_dir"
    if [ $? -eq 0 ]; then
        echo "Link from $HOME to $target_dir successfully created"
    fi
}

_replace_system_dir_by_link() {
    link_dir=$1
    target_dir=$2
    if [ -L $link_dir ]; then
        echo "$link_dir is already a link, skipping"
        return
    fi
    if [ $(basename $target_dir) == "flatpak" ]; then
        three_dots="..."
    fi
    if [[ $target_dir != *"home"* ]]; then
        sudo="sudo"
    fi
    if [ ! -d $target_dir ]; then
        echo "Directory $target_dir does not exist, creating parent dir and moving $link_dir into it$three_dots"
        mkdir -p $(dirname $target_dir)
        $sudo mv $link_dir $(dirname $target_dir)
    else
        echo "Directory $target_dir exists, removing $link_dir before creating link"
        $sudo rm -rf $link_dir
    fi
    $sudo ln -s $target_dir $link_dir
    if [ $? -eq 0 ]; then
        echo "Link to $target_dir successfully created"
    fi
}

stow_dotfiles() {
    log "Link dotfiles packages into home dir with stow"
    dotfiles_dir=$(realpath "$SETUP_DIR/..")
    packages=( claude nvim shell vim zsh )

    # Must be real directories, otherwise stow replaces them by a single link into the repo
    # and files that other programs keep there land in the repo
    mkdir -p "$HOME/.config" "$HOME/.claude"

    # stow refuses to replace existing files, so keep them as .bak
    for package in ${packages[@]}; do
        (cd "$dotfiles_dir/$package" && find . -type f -o -type l) | while read -r file; do
            source_file=$dotfiles_dir/$package/${file#./}
            target_file=$HOME/${file#./}
            # -ef: the file is already reached through a link into the repo
            if [ -e "$target_file" ] && [ ! -L "$target_file" ] && [ ! "$target_file" -ef "$source_file" ]; then
                echo "Moving existing $target_file to $target_file.bak"
                mv "$target_file" "$target_file.bak"
            fi
        done
    done

    stow -d "$dotfiles_dir" -t "$HOME" -v 1 ${packages[@]}
}

restore_configs() {
    log "Restoring configs..."

    konsave_dir=$HOME/.config/konsave
#     konsave_profile=configs-plasma$KDE_SESSION_VERSION
    konsave_profile=configs-plasma5

    mkdir -p $HOME/.local/share/plasma
    mkdir -p $HOME/.var/app/org.signal.Signal/config/Signal
    mkdir -p $HOME/.var/app/com.slack.Slack/config/Slack/storage
    mkdir -p $HOME/.var/app/org.genivi.DLTViewer

    log "Import konsave profile"
    rm -rf $konsave_dir/profiles/$konsave_profile
    konsave -i $BACKUP_DIR/$konsave_profile.knsv

    log "Apply konsave profile"
    konsave -a $konsave_profile

    mv $konsave_dir/conf.yaml $konsave_dir/conf.yaml.bak
    cp $konsave_dir/profiles/$konsave_profile/conf.yaml $konsave_dir/

    wifi_interface=$(iw dev | grep wlp | cut -d " " -f 2)
    replace-substring-file "wlp[^\/]*" "$wifi_interface" $HOME/.local/share/plasma-systemmonitor/overview.page

    _check_data_partition

#     _restore_firefox
    _restore_global_configs
}

replace_dirs_by_links() {
    mkdir -p $DATA_PARTITION_PATH/home

    log "Replace home directories by links to respective $DATA_PARTITION_PATH folders"
    home_dirs=( Documents Downloads Pictures Videos AppImages Images
                "VirtualBox VMs" QEMU-VMs
                .var .vaults )
    for dir_name in ${home_dirs[@]}; do
        _replace_user_dir_by_link $HOME/$dir_name $DATA_PARTITION_PATH/home/$dir_name
    done

    _replace_user_dir_by_link $HOME/Projects $DATA_PARTITION_PATH/home/Workspace/Projects
    _replace_user_dir_by_link $HOME/CraftRoot $DATA_PARTITION_PATH/home/Workspace/Frameworks/CraftRoot
#     _replace_user_dir_by_link $HOME/.android/avd $DATA_PARTITION_PATH/home/.android/avd

    echo
    log "Replace flatpak directory by link"
    _replace_system_dir_by_link /var/lib/flatpak $DATA_PARTITION_PATH/system/var/lib/flatpak
    log "Reboot might be required after moving flatpak directory"

    echo
    log "Link dotfiles and backup directories into home dir"
    dotfiles_dir=$(realpath "$SETUP_DIR/..")
    _replace_user_dir_by_link "$HOME/.dotfiles" "$dotfiles_dir"
    _replace_user_dir_by_link "$HOME/.backup" "$BACKUP_DIR"
}

set -e
stow_dotfiles
restore_configs
replace_dirs_by_links
