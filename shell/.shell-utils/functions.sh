bak() {
    cp -r "$1"{,.bak}
}

mkcd() {
    mkdir -p -- "$1" && cd -P -- "$1"
}

mkpd() {
    mkdir -p -- "$1" && pushd -- "$1"
}

ls-count() {
    local dir=.
    if [ ! -z "$1" ]; then
        dir=$1
    fi
    local n=$(ls -1a "$dir" | wc -l)
    echo $(($n-2))
}

ll-hidden() {
    ll .*"$1"*
    echo
    ll .*/**/*"$1"*
}

find-hidden() {
    find . -path '.*'"$1"'*' -type f -printf '%P\n' | fzfp
}

dirgrep() {
    local str=${@:$#}
    local -a dirs=()

    for arg in "${@}"; do
        dirs+=("$arg")
    done

    local count=${#dirs[@]}
    dirs=("${dirs[@]:0:$count-1}")

    grep -Rn ${dirs[@]} -e "$str" 2> /dev/null
}

dirgrep-filetype() {
    local str=${@:$#}
    local -a dirs=()

    for arg in "${@}"; do
        dirs+=("$arg")
    done

    local count=${#dirs[@]}
    local filetype=${dirs[@]:$count-2:1}
    dirs=("${dirs[@]:0:$count-2}")

    grep -Rn ${dirs[@]} --include="*.$filetype" -e "$str" 2> /dev/null
}

grep-configs() {
    local app_name=$1
    local setting_str=$2
    grep -Rni $HOME/.*"$app_name"* -e "$setting_str" 2> /dev/null
    grep -Rni $HOME/.config/**/*"$app_name"* -e "$setting_str" 2> /dev/null | delete-line konsave
    grep -Rni $HOME/.local/share/**/*"$app_name"* -e "$setting_str" 2> /dev/null | sort -u
}

grep-configs-konsave() {
    local app_name=$1
    local setting_str=$2
    grep -Rni $HOME/.config/konsave/profiles/configs-backup/**/*"$app_name"* -e "$setting_str" | sort -u
}

grep-shell-scripts() {
    dirgrep-filetype $HOME/.shell-utils $HOME/.scripts $PROJECTS_DIR/setup/setup-scripts "sh" "$1"
}

binpath() {
    local out
    out=$(which $1 2>&1)
    local ret=$?
    if [ $ret -ne 0 ]; then
        echo "which: $out"
        return $ret
    fi
    realpath $out
}

pkg-binpath() {
    local out
    out=$(binpath $1 2>&1)
    local ret=$?
    if [ $ret -ne 0 ]; then
        echo $out
        return $ret
    fi
    dpkg --search $out
}

pkg-path-installed() {
    dpkg --search $1 | less
}

pkg-path() {
    apt-file search $1 | less
}


pkg-list() {
    local pkg=$1
    case $DISTRO in
    Tuxedo|KDE|Ubuntu)
        apt list 2>/dev/null | grep -E $pkg | less ;;
    Fedora)
        ;;  # TODO
    esac
}

pkg-list-installed() {
    local pkg=$1
    case $DISTRO in
    Tuxedo|KDE|Ubuntu)
        apt list --installed 2>/dev/null | grep -E $pkg | less ;;
    Fedora)
        ;;  # TODO
    esac
}

pkg-list-verbose() {
    local pkg=$1
    case $DISTRO in
    Tuxedo|KDE|Ubuntu)
        apt search $pkg 2>/dev/null | grep -E $pkg -B1 -A1 --group-separator="" | uniq | grep -E $pkg -B1 -A1 --group-separator="" | less
        ;;
    Fedora)
        ;;  # TODO
    esac
}

pkg-status() {
    local pkg=$1
    case $DISTRO in
    Tuxedo|KDE|Ubuntu)
        set +e
        dpkg-query -l $pkg 2> /dev/null | grep -q "ii"
        set -e
        ;;
    Fedora)
        ;;  # TODO
    esac
    local res=$?
    local status
    if [ $res -eq 0 ]; then
        local status="installed"
    else
        local status="not installed"
    fi
    echo "$pkg is $status"
    return $res
}

deduplicate-history() {
    cp $HOME/.bash_history $HOME/.bash_history.bak
    cat $HOME/.bash_history | nl | sort -k2 -k1,1nr | uniq -f1 | sort -n | cut -f2 > $HOME/.bash_history.tmp
    mv $HOME/.bash_history.tmp $HOME/.bash_history
}
