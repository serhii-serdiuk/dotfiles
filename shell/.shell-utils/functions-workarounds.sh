enable-btkeyboard-fnkeys() {
    echo 0 | sudo tee /sys/module/hid_apple/parameters/fnmode
}

_toggle_kate_session_display_setup() {
    local session_config=$1
    local display_setup=$2
    local window_height=$3
    local window_width=$4

    echo "$session_config, height: $window_height, width: $window_width"

    grep $session_config -e "Height=" > /dev/null
    if [ $? -eq 0 ]; then
        replace-substring-file ".*: Height=.*" "$display_setup: Height=$window_height" $session_config
        replace-substring-file ".*: Width=.*" "$display_setup: Width=$window_width" $session_config
    else
        append-line-after "\[MainWindow0\]" "$display_setup: Width=$window_width" $session_config
        append-line-after "\[MainWindow0\]" "$display_setup: Height=$window_height" $session_config
        append-line-after "\[MainWindow0 Settings\]" "$display_setup: Width=$window_width" $session_config
        append-line-after "\[MainWindow0 Settings\]" "$display_setup: Height=$window_height" $session_config
    fi
}

# toggle-display-setup() {
display-setup() {
# adjust-display-setup() {
    local display_setup

#     sudo get-edid -q | grep "DELL P2720D"
#     if [ $? -eq 0 ]; then
#         display_setup="2560x1440 screen"
    gpu-manager | grep "output" -A 1
    if [ $1 -eq 2 ]; then
        display_setup="2 screens"
    else
        display_setup="1920x1080 screen"
    fi
    echo $display_setup

    local kwrite_session=$HOME/.local/share/kwrite/anonymous.katesession
    _toggle_kate_session_display_setup $kwrite_session "$display_setup" "672" "1152"

    local kate_session=$HOME/.local/share/kate/anonymous.katesession
    _toggle_kate_session_display_setup $kate_session "$display_setup" "934" "1582"
    for session in $HOME/.local/share/kate/sessions/*; do
        _toggle_kate_session_display_setup $session "$display_setup" "934" "1582"
    done
}

restore-windows-geometry() {
    # KONSAVE_PROFILE=fedora-config-6
    # KONSAVE_PROFILE_DIR=~/.config/konsave/profiles/$KONSAVE_PROFILE

    # cp $KONSAVE_PROFILE_DIR/configs/git-cola/settings ~/.config/git-cola/

    # Reset geometry for git-cola windows:
    # example: sed -i "s/aaa=.*/aaa=xxx/g" file
    sed -i "s/\"geometry\": .*/\"geometry\": \"\",/g" ~/.config/git-cola/settings
}

# toggle-powersave() {
#     /etc/tlp.conf
#     CPU_ENERGY_PERF_POLICY_ON_BAT=balance_performance
#     CPU_ENERGY_PERF_POLICY_ON_BAT=balance_power
#
#     sudo tlp start
#     tlp-stat --cdiff
# }
