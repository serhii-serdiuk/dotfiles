DISTRO=$(lsb_release --id --short)

SETUP_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")

source "$SETUP_DIR/../shell/.shell-utils/functions-sed.sh"

pkg-status() {
    local package=$1
    case $DISTRO in
    Tuxedo|KDE|Ubuntu)
        dpkg-query -l $package 2> /dev/null | grep -q "ii" ;;
    Fedora)
        ;;  # TODO
    *)
        echo "Unknown"
        exit 1 ;;
    esac
    local res=$?
    if [ $res -eq 0 ]; then
        local status="installed"
    else
        local status="not installed"
    fi
    echo "$package is $status"
    return $res
}

log() {
    local green="\033[32m"
    local no_color="\033[0m"
    echo -e "${green}INFO: `date` - $*${no_color}"
}

restart-plasma() {
    log "Restart Plasma desktop"
    pkill plasmashell; plasmashell > /dev/null 2>&1 & disown
}

restart-kwin() {
    log "Restart KWin"
    pkill kwin; kwin > /dev/null 2>&1 & disown
}

restart-shortcuts-daemon() {
    log "Restart keyboard shortcuts daemon"
    pkill kglobalaccel5; kglobalaccel5 > /dev/null 2>&1 & disown
}
