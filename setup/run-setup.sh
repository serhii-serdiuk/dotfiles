#!/bin/bash

set -e

SETUP_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

source "$SETUP_DIR/aux/utils.sh"

SETUP_LOGFILE="$HOME/setup.log"

case $DISTRO in
Fedora)
    sudo dnf install util-linux-script -y ;;
esac

# TODO: no script command on Fedora installed
script --quiet --return --command "'$SETUP_DIR/setup.sh' $*" --log-out "$SETUP_LOGFILE" --append

delete-lines-file "[0-9]+%" "$SETUP_LOGFILE"
delete-lines-file "idealTree:" "$SETUP_LOGFILE"
delete-lines-file "reify:" "$SETUP_LOGFILE"
delete-lines-file "\[.+\].*flathub" "$SETUP_LOGFILE"
delete-lines-file "6n.*ID.*Branch.*Op.*Remote.*Download" "$SETUP_LOGFILE"

# remove color codes from log file
replace-substring-file "\x1b\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|k]" "" "$SETUP_LOGFILE"
replace-substring-file "^.*?25h" "" "$SETUP_LOGFILE"

# remove DOS line ending
sed -Ei "s/ +\r/\n/g; s/\r//g" "$SETUP_LOGFILE"
# replace multiple empty lines with one
sed -i "/^$/N; /^\n$/D" "$SETUP_LOGFILE"
