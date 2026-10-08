#!/bin/bash

SETUP_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")

source "$SETUP_DIR/aux/utils.sh"

add_section() {
    config_file=$1
    section=$2

    log "$config_file: [$section]"

    grep $config_file -e "\[$section\]" > /dev/null
    if [ $? -ne 0 ]; then
        echo -e "\n[$section]" >> $config_file
    fi
}

add_app_section() {
    config_file=$1
    grep $config_file -e "<ActionProperties" > /dev/null
    if [ $? -ne 0 ]; then
        insert-line-before "<\/gui>" "\ <ActionProperties>\n <\/ActionProperties>" $config_file
    fi
    # TODO
    # - <ActionProperties scheme="Default"/>
    # + <ActionProperties scheme="Default">
    # +  <Action name="edit_filter" shortcut=""/>
    # + </ActionProperties>
}

set_shortcut() {
    action=$1
    shortcuts=$2
    config_file=$3
    section=$4

    echo "* Action: $action"
    echo "  - Shortcuts: $shortcuts"

    grep $config_file -e "$action" > /dev/null
    if [ $? -eq 0 ]; then
        replace-substring-file "$action=[^,]*" "$action=$shortcuts" $config_file
    else
        append-line-after "\[$section\]" "$action=$shortcuts" $config_file
    fi
}

set_app_shortcut() {
    action=$1
    shortcuts=$2
    config_file=$3

    echo "* Action: $action"
    echo "  - Shortcuts: $shortcuts"

    grep $config_file -e "<ActionProperties" -A 100 | grep -e "$action" > /dev/null
    if [ $? -eq 0 ]; then
        sed -i "/\"$action\"/ s/shortcut=\".*\"/shortcut=\"$shortcuts\"/" $config_file
    else
        insert-line-before "<\/ActionProperties>" "\  <Action name=\"$action\" shortcut=\"$shortcuts\"\/>" $config_file
    fi
}

set_global_shortcuts() {
    log "Global shortcuts..."

    config_file=$HOME/.config/kglobalshortcutsrc
    section="kwin"
    add_section $config_file $section

    set_shortcut "Switch One Desktop Up"            "Meta+Up"                           $config_file    $section
    set_shortcut "Switch One Desktop Down"          "Meta+Down"                         $config_file    $section
    set_shortcut "Switch One Desktop to the Left"   "Meta+Left"                         $config_file    $section
    set_shortcut "Switch One Desktop to the Right"  "Meta+Right"                        $config_file    $section
    set_shortcut "Switch to Desktop 1"              "Meta+1\\\tCtrl+F1"                 $config_file    $section
    set_shortcut "Switch to Desktop 2"              "Meta+2\\\tCtrl+F2"                 $config_file    $section
    set_shortcut "Switch to Desktop 3"              "Meta+!\\\tCtrl+F3"                 $config_file    $section
    set_shortcut "Switch to Desktop 4"              "Meta+@\\\tCtrl+F4"                 $config_file    $section
    set_shortcut "Walk Through Desktops"            "Meta+\`\\\tMeta+'"                 $config_file    $section
    set_shortcut "Walk Through Desktops (Reverse)"  "Meta+~"                            $config_file    $section
    set_shortcut "ShowDesktopGrid"                  "Meta+S"                            $config_file    $section

    set_shortcut "Window Quick Tile Top"            "Meta+Shift+Up"                     $config_file    $section
    set_shortcut "Window Quick Tile Bottom"         "Meta+Shift+Down"                   $config_file    $section
    set_shortcut "Window Quick Tile Left"           "Meta+Shift+Left"                   $config_file    $section
    set_shortcut "Window Quick Tile Right"          "Meta+Shift+Right"                  $config_file    $section
    set_shortcut "Window Pack Up"                   "Meta+Ctrl+Up"                      $config_file    $section
    set_shortcut "Window Pack Down"                 "Meta+Ctrl+Down"                    $config_file    $section
    set_shortcut "Window Pack Left"                 "Meta+Ctrl+Left"                    $config_file    $section
    set_shortcut "Window Pack Right"                "Meta+Ctrl+Right"                   $config_file    $section
    set_shortcut "Window Move Center"               "Meta+Ctrl+Space"                   $config_file    $section
    set_shortcut "Window Above Other Windows"       "Meta+Ctrl+A"                       $config_file    $section
    set_shortcut "Window Maximize"                  "Meta+M"                            $config_file    $section
    set_shortcut "Window Minimize"                  "Meta+N"                            $config_file    $section
    set_shortcut "Window Close"                     "Alt+F4\\\tMeta+Q"                  $config_file    $section
    set_shortcut "Kill Window"                      "Meta+Shift+Q"                      $config_file    $section
    set_shortcut "Edit Tiles"                       "Meta+\\\\\\\\\\\\\\\\"             $config_file    $section
    set_shortcut "ExposeAll"                        "Ctrl+F10\\\tMeta+A\\\tLaunch (C)"  $config_file    $section

    set_shortcut "Switch to Next Screen"            "Meta+J\\\tMeta+O"                  $config_file    $section
    set_shortcut "Switch to Previous Screen"        "Meta+K"                            $config_file    $section
    set_shortcut "Window to Next Screen"            "Meta+Shift+J\\\tMeta+Shift+O"      $config_file    $section
    set_shortcut "Window to Previous Screen"        "Meta+Shift+K"                      $config_file    $section

    set_shortcut "Activate Window Demanding Attention"                      "Meta+U"            $config_file $section
    set_shortcut "Walk Through Windows Alternative"                         "Meta+Tab"          $config_file $section
    set_shortcut "Walk Through Windows Alternative (Reverse)"               "Meta+Space"        $config_file $section
    set_shortcut "Walk Through Windows of Current Application Alternative"  "Meta+Shift+Space"  $config_file $section
    echo

    section="plasmashell"
    add_section $config_file $section

    set_shortcut "activate task manager entry 1"    "Alt+!"     $config_file    $section
    set_shortcut "activate task manager entry 2"    "Alt+@"     $config_file    $section
    set_shortcut "activate task manager entry 3"    "Alt+#"     $config_file    $section
    set_shortcut "activate task manager entry 4"    "Alt+$"     $config_file    $section
    set_shortcut "activate task manager entry 5"    "Alt+%"     $config_file    $section
    set_shortcut "activate task manager entry 6"    "Alt+^"     $config_file    $section
    set_shortcut "activate task manager entry 7"    "Alt+\&"    $config_file    $section
    set_shortcut "activate task manager entry 8"    "Alt+*"     $config_file    $section
    set_shortcut "activate task manager entry 9"    "Alt+("     $config_file    $section
    set_shortcut "activate task manager entry 10"   "Alt+)"     $config_file    $section

#     activate widget 21=Meta+B,none,Activate Bluetooth Widget
#     activate widget 19=Meta+Shift+B,none,Activate Battery and Brightness Widget
#     activate widget 30=Meta+Shift+C,none,Activate Event Calendar Widget
#     activate widget 12=Meta+C,none,Activate Clipboard Widget
#     activate widget 13=Meta+Shift+U,none,Activate Disks  Devices Widget
#     activate widget 147=Meta+F,none,Activate Fokus Widget
#     activate widget 26=Meta+Shift+F,none,Activate Weather Widget Widget
#     activate widget 23=Meta+Alt+K,none,Activate KDE Connect Widget
#     activate widget 14=Meta+Shift+N,none,Activate Notifications Widget
#     activate widget 22=Meta+Shift+P,none,Activate Media Player Widget
#     activate widget 25=Meta+R,none,Activate Advanced Radio Player Widget
#     activate widget 47=Meta+T,none,Activate TodoList Widget
#     activate widget 8=Meta+Alt+T,none,Activate System Tray Widget
#     activate widget 10=Meta+Shift+V,none,Activate Audio Volume Widget
#     activate widget 20=Meta+Shift+W,none,Activate Networks Widget

    set_shortcut "manage activities"            "Meta+Shift+A"      $config_file    $section
    set_shortcut "next activity"                "Meta+Esc"          $config_file    $section
    set_shortcut "previous activity"            "Meta+Shift+Esc"    $config_file    $section
    set_shortcut "switch to next activity"      "Meta+PgDown"       $config_file    $section
    set_shortcut "switch to previous activity"  "Meta+PgUp"         $config_file    $section
    set_shortcut "stop current activity"        "none"              $config_file    $section
    set_shortcut "toggle do not disturb"        "Meta+Shift+D"      $config_file    $section
    echo

    section="kded5"
    add_section $config_file $section
    set_shortcut "display"              "Display\\\tMeta+Ctrl+D"    $config_file    $section
    echo

    section="mediacontrol"
    add_section $config_file $section
    set_shortcut "playpausemedia"       "Media Play\\\tMeta+P"      $config_file    $section
    echo

    section="kmix"
    add_section $config_file $section
    set_shortcut "mute"                 "Volume Mute\\\tMeta+Shift+M"                               $config_file    $section
    set_shortcut "mic_mute"             "Meta+Volume Mute\\\tMicrophone Mute\\\tMeta+Ctrl+Shift+M"  $config_file    $section
    echo

    section="ksmserver"
    add_section $config_file $section
    set_shortcut "Log Out"              "Meta+Del\\\tCtrl+Alt+Del"  $config_file    $section
    echo

    section="org_kde_powerdevil"
    add_section $config_file $section
    set_shortcut "Sleep"                "Meta+Shift+L\\\tSleep"     $config_file    $section
    echo

    section="yakuake"
    add_section $config_file $section
    set_shortcut "toggle-window-state"  "F12\\\tMeta+Shift+Return"  $config_file    $section
    echo

    # TODO: shortcuts below should be tested properly
#     section="org.kde.konsole.desktop"
#     add_section $config_file $section
#     append-line-after "\[$section\]" "_launch=Meta+Return,none,Konsole" $config_file
#
#     section="org.kde.kwrite.desktop"
#     add_section $config_file $section
#     append-line-after "\[$section\]" "_k_friendly_name=KWrite" $config_file
#     append-line-after "\[$section\]" "_launch=Meta+Shift+E,none,KWrite" $config_file
#
#     section="org.kde.kcalc.desktop"
#     add_section $config_file $section
#     append-line-after "\[$section\]" "_launch=Meta+X\\\tLaunch (1),Launch (1),KCalc" $config_file
#
#     section="systemsettings.desktop"
#     add_section $config_file $section
#     append-line-after "\[$section\]" "_launch=Meta+\\,\\\tTools,Tools,System Settings" $config_file
#
#     section="org.kde.kinfocenter.desktop"
#     add_section $config_file $section
#     append-line-after "\[$section\]" "_k_friendly_name=Info Center" $config_file
#     append-line-after "\[$section\]" "_launch=Meta+<,none,Info Center" $config_file
#
#     section="org.kde.plasma-systemmonitor.desktop"
#     add_section $config_file $section
#     append-line-after "\[$section\]" "_k_friendly_name=System Monitor" $config_file
#     append-line-after "\[$section\]" "_launch=Meta+Ctrl+\\,,none,System Monitor" $config_file
#
#     section="org.kde.krunner.desktop"
#     add_section $config_file $section
#                                                             # Meta+Shift+/
#     set_shortcut "RunClipboard"              "Alt+Shift+F2\\\tMeta+?\\\tAlt+Shift+Space"    $config_file    $section
#     append-line-after "\[$section\]" "_launch=Alt+F2\\\tSearch\\\tAlt+Space\\\tMeta+/,Alt+Space\\\tAlt+F2\\\tSearch,KRunner" $config_file
#
#     section="org.keepassxc.KeePassXC.desktop"
#     add_section $config_file $section
#     append-line-after "\[$section\]" "_k_friendly_name=KeePassXC" $config_file
#     append-line-after "\[$section\]" "_launch=Meta+Ctrl+K,none,KeePassXC" $config_file
#
#     section="firefox-newtab.desktop"
#     add_section $config_file $section
#     append-line-after "\[$section\]" "__launch=Meta+Ctrl+Shift+N,none,Open New Tab" $config_file
#
#     section="firefox-deepl-translator.desktop"
#     add_section $config_file $section
#     append-line-after "\[$section\]" "_launch=Meta+Ctrl+Shift+T,none,Open DeepL Translator" $config_file
#
#     section="firefox-deepl-write.desktop"
#     add_section $config_file $section
#     append-line-after "\[$section\]" "_launch=Meta+Ctrl+Shift+D,none,Open DeepL Write" $config_file
#
#     section="restart-plasma.desktop"
#     add_section $config_file $section
#     append-line-after "\[$section\]" "_launch=Meta+Ctrl+Shift+P,none,Restart Plasma desktop" $config_file
#
#     section="restart-kwin.desktop"
#     add_section $config_file $section
#     append-line-after "\[$section\]" "_launch=Meta+Ctrl+Shift+K,none,Restart KWin" $config_file
#
#     section="restart-shortcuts-daemon.desktop"
#     add_section $config_file $section
#     append-line-after "\[$section\]" "_launch=Meta+Ctrl+S,none,Restart keyboard shortcuts daemon" $config_file
#
#     section="restart-remoteclient.desktop"
#     add_section $config_file $section
#     append-line-after "\[$section\]" "_launch=Meta+Shift+R,none,Restart remoteclient" $config_file
#     echo

    config_file=$HOME/.config/kdeglobals
    section="Shortcuts"
    add_section $config_file $section

    set_shortcut "BeginningOfLine"      "Home; Ctrl+A"              $config_file    $section
    set_shortcut "EndOfLine"            "End; Ctrl+E"               $config_file    $section
    set_shortcut "Begin"                "Ctrl+Home; Alt+<"          $config_file    $section
    set_shortcut "End"                  "Ctrl+End; Alt+>"           $config_file    $section
    set_shortcut "SelectAll"            "Ctrl+Alt+S"                $config_file    $section
    set_shortcut "Deselect"             ""                          $config_file    $section
    set_shortcut "TextCompletion"       ""                          $config_file    $section
    set_shortcut "Close"                "Ctrl+W"                    $config_file    $section
}

set_kwrite_shortcuts() {
    log "KWrite shortcuts..."

    config_file=$HOME/.local/share/kxmlgui5/kwrite/kateui.rc
    add_app_section $config_file

    set_app_shortcut "view_history_back"            "Alt+Left"                      $config_file
    set_app_shortcut "view_history_forward"         "Alt+Right"                     $config_file
    set_app_shortcut "view_prev_tab"                "Ctrl+PgUp; Ctrl+Alt+Left"      $config_file
    set_app_shortcut "view_next_tab"                "Ctrl+PgDown; Ctrl+Alt+Right"   $config_file

    set_app_shortcut "view_split_vert"              "Ctrl+\\\\"                     $config_file
    set_app_shortcut "view_split_horiz"             "Alt+\\\\"                      $config_file
    set_app_shortcut "view_split_vert_move_doc"     "Ctrl+|"                        $config_file
    set_app_shortcut "view_split_horiz_move_doc"    "Alt+|"                         $config_file
    set_app_shortcut "view_close_current_space"     "Ctrl+Alt+\\\\"                 $config_file
    set_app_shortcut "view_close_others"            "Ctrl+Alt+|"                    $config_file
    set_app_shortcut "go_next_split_view"           "F8; Ctrl+Shift+J"              $config_file
    set_app_shortcut "go_prev_split_view"           "Shift+F8; Ctrl+Shift+K"        $config_file

    set_app_shortcut "view_quick_open"              "Ctrl+Alt+O; Alt+O"             $config_file
    set_app_shortcut "open_kcommand_bar"            "Ctrl+Alt+I; Alt+\/"            $config_file
    set_app_shortcut "file_copy_filepath"           "Ctrl+Shift+C"                  $config_file
    set_app_shortcut "file_save_all"                ""                              $config_file
}

set_kate_shortcuts() {
    log "Kate shortcuts..."

    config_file=$HOME/.local/share/kxmlgui5/kate/kateui.rc
    add_app_section $config_file

    set_app_shortcut "view_history_back"                        "Alt+Left"                      $config_file
    set_app_shortcut "view_history_forward"                     "Alt+Right"                     $config_file
    set_app_shortcut "view_prev_tab"                            "Ctrl+PgUp; Ctrl+Alt+Left"      $config_file
    set_app_shortcut "view_next_tab"                            "Ctrl+PgDown; Ctrl+Alt+Right"   $config_file

    set_app_shortcut "view_split_vert"                          "Ctrl+\\\\"                     $config_file
    set_app_shortcut "view_split_horiz"                         "Alt+\\\\"                      $config_file
    set_app_shortcut "view_split_vert_move_doc"                 "Ctrl+|"                        $config_file
    set_app_shortcut "view_split_horiz_move_doc"                "Alt+|"                         $config_file
    set_app_shortcut "view_close_current_space"                 "Ctrl+Alt+\\\\"                 $config_file
    set_app_shortcut "view_close_others"                        "Ctrl+Alt+|"                    $config_file
    set_app_shortcut "go_next_split_view"                       "F8; Ctrl+Shift+J"              $config_file
    set_app_shortcut "go_prev_split_view"                       "Shift+F8; Ctrl+Shift+K"        $config_file

    set_app_shortcut "view_quick_open"                          "Ctrl+Alt+O; Alt+O"             $config_file
    set_app_shortcut "open_kcommand_bar"                        "Ctrl+Alt+I; Alt+\/"            $config_file
    set_app_shortcut "file_copy_filepath"                       "Ctrl+Shift+C"                  $config_file
    set_app_shortcut "file_save_all"                            ""                              $config_file
    echo

    config_file=$HOME/.local/share/kxmlgui5/katepart/katepart5ui.rc
    add_app_section $config_file

    set_app_shortcut "Previous Editing Line"                    "Alt+Shift+Left"                $config_file
    set_app_shortcut "Next Editing Line"                        "Alt+Shift+Right"               $config_file
    set_app_shortcut "select_beginning_of_line"                 "Shift+Home; Ctrl+Shift+A"      $config_file
    set_app_shortcut "select_end_of_line"                       "Shift+End; Ctrl+Shift+E"       $config_file

    set_app_shortcut "tools_scripts_jumpIndentUp"               "Alt+Up"                        $config_file
    set_app_shortcut "tools_scripts_jumpIndentDown"             "Alt+Down"                      $config_file
    set_app_shortcut "tools_scripts_emmetNext"                  "Alt+Shift+Down"                $config_file
    set_app_shortcut "tools_scripts_emmetPrev"                  "Alt+Shift+Up"                  $config_file

    set_app_shortcut "newline_above"                            "Shift+Return"                  $config_file
    set_app_shortcut "newline_below"                            "Ctrl+Return"                   $config_file
    set_app_shortcut "no_indent_newline"                        "Ctrl+Shift+Return"             $config_file
    set_app_shortcut "smart_newline"                            "Alt+Shift+Return"              $config_file

    set_app_shortcut "tools_formatIndent"                       "Ctrl+I"                        $config_file
    set_app_shortcut "tools_cleanIndent"                        "Ctrl+Shift+I"                  $config_file
    set_app_shortcut "tools_indent"                             ""                              $config_file
    set_app_shortcut "tools_unindent"                           ""                              $config_file
    set_app_shortcut "tools_comment"                            "Ctrl+Shift+\/"                 $config_file
    set_app_shortcut "tools_uncomment"                          ""                              $config_file
    set_app_shortcut "switch_to_cmd_line"                       "F7; Alt+Shift+\/"              $config_file

    set_app_shortcut "delete_next_character"                    "Del; Ctrl+D"                   $config_file
    set_app_shortcut "tools_scripts_duplicateLinesDown"         "Ctrl+L"                        $config_file
    set_app_shortcut "tools_scripts_duplicateLinesUp"           "Ctrl+Shift+L"                  $config_file
    set_app_shortcut "edit_toggle_camel_case_cursor"            "Ctrl+Shift+M"                  $config_file
    set_app_shortcut "edit_find_multicursor_next_occurrence"    "Ctrl+Y"                        $config_file
    set_app_shortcut "edit_skip_multicursor_current_occurrence" "Ctrl+Shift+Y"                  $config_file
    set_app_shortcut "edit_find_multicursor_all_occurrences"    "Ctrl+Alt+Y"                    $config_file
    set_app_shortcut "file_print"                               ""                              $config_file
    set_app_shortcut "clipboard_history_paste"                  "Ctrl+Alt+V; "                  $config_file
    set_app_shortcut "switch_next_input_mode"                   "Alt+Shift+V"                   $config_file
    set_app_shortcut "tools_uppercase"                          "Alt+U"                         $config_file
    set_app_shortcut "tools_lowercase"                          "Alt+Shift+U"                   $config_file
    set_app_shortcut "view_dynamic_word_wrap"                   "Ctrl+Alt+W"                    $config_file
    set_app_shortcut "tools_toggle_automatic_spell_checking"    ""                              $config_file
    set_app_shortcut "set_verticalSelect"                       ""                              $config_file
    set_app_shortcut "file_save_as"                             ""                              $config_file
    echo

    config_file=$HOME/.local/share/kxmlgui5/katesearch/ui.rc
    add_app_section $config_file

    set_app_shortcut "go_to_next_match"                         "F6; Ctrl+Alt+J"                $config_file
    set_app_shortcut "go_to_prev_match"                         "Shift+F6; Ctrl+Alt+K"          $config_file
    set_app_shortcut "search_in_files_new_tab"                  "Ctrl+Alt+F"                    $config_file
    echo

    config_file=$HOME/.local/share/kxmlgui5/kateproject/ui.rc
    add_app_section $config_file

    set_app_shortcut "projects_prev_project"                    "Ctrl+Alt+Shift+Left"           $config_file
    set_app_shortcut "projects_next_project"                    "Ctrl+Alt+Shift+Right"          $config_file
    set_app_shortcut "projects_open_project"                    "Ctrl+Shift+O"                  $config_file
    set_app_shortcut "projects_goto_index"                      "Ctrl+U"                        $config_file
    echo

    config_file=$HOME/.local/share/kxmlgui5/katekonsole/ui.rc
    add_app_section $config_file

    set_app_shortcut "katekonsole_tools_toggle_visibility"      "F4; Alt+Shift+T"               $config_file
    set_app_shortcut "katekonsole_tools_toggle_focus"           "Ctrl+Shift+F4; Alt+Shift+F"    $config_file
    set_app_shortcut "katekonsole_tools_run"                    "Ctrl+Shift+X"                  $config_file
    set_app_shortcut "katekonsole_tools_sync"                   "Ctrl+Shift+T"                  $config_file
    echo

    config_file=$HOME/.local/share/kxmlgui5/katebuild/ui.rc
    add_app_section $config_file

    set_app_shortcut "build_selected_target"                    "Ctrl+Shift+B"                  $config_file
    set_app_shortcut "build_and_run_selected_target"            "Ctrl+Shift+R"                  $config_file
    echo

    config_file=$HOME/.local/share/kxmlgui5/katefiletree/ui.rc
    add_app_section $config_file

    set_app_shortcut "filetree_prev_document"                   ""                              $config_file
    set_app_shortcut "filetree_next_document"                   ""                              $config_file
    echo

    config_file=$HOME/.local/share/kxmlgui5/lspclient/ui.rc
    add_app_section $config_file

    set_app_shortcut "lspclient_format"                         ""                              $config_file
    echo

    config_file=$HOME/.local/share/kxmlgui5/textfilter/ui.rc
    add_app_section $config_file

    set_app_shortcut "edit_filter"                              ""                              $config_file
    echo

    config_file=$HOME/.local/share/kxmlgui5/externaltools/ui.rc
    add_app_section $config_file

    set_app_shortcut "externaltool_terminal"                    "Ctrl+Alt+T"                    $config_file
    set_app_shortcut "externaltool_gitdag_current"              "Ctrl+Alt+L"                    $config_file
    set_app_shortcut "externaltool_gitdag_upstreamdiff"         "Ctrl+Alt+Shift+L"              $config_file
    set_app_shortcut "externaltool_gitgui_blame"                "Ctrl+Alt+B"                    $config_file
    set_app_shortcut "externaltool_gitk_file"                   "Ctrl+Alt+Shift+B"              $config_file
    set_app_shortcut "externaltool_gitcola"                     "Ctrl+Alt+C"                    $config_file
    set_app_shortcut "externaltool_gitcola_stash"               "Ctrl+Alt+Shift+S"              $config_file
    set_app_shortcut "externaltool_gitcola_rebase"              "Ctrl+Alt+Shift+R"              $config_file
    set_app_shortcut "externaltool_kdeapi"                      "Ctrl+Alt+Shift+K"              $config_file
    set_app_shortcut "externaltool_qtapi"                       "Ctrl+Alt+Shift+Q"              $config_file
    set_app_shortcut "externaltool_qmlpreview"                  "Ctrl+P"                        $config_file
    echo

    config_file=$HOME/.config/katerc
    section="Shortcuts"
    add_section $config_file $section

    set_shortcut "goto_next_diagnostic"                                     "none"          $config_file    $section
    set_shortcut "goto_prev_diagnostic"                                     "none"          $config_file    $section
    set_shortcut "kate_mdi_toolview_diagnostics"                            "Alt+Shift+D"   $config_file    $section
    set_shortcut "kate_mdi_toolview_kate_plugin_katebuildplugin"            "Alt+Shift+B"   $config_file    $section
    set_shortcut "kate_mdi_toolview_kate_plugin_katesearch"                 "Alt+Shift+S"   $config_file    $section
    set_shortcut "kate_mdi_toolview_kate_private_plugin_katefiletreeplugin" "Ctrl+Shift+D"  $config_file    $section
    set_shortcut "kate_mdi_toolview_kateproject"                            "Ctrl+Shift+P"  $config_file    $section
    set_shortcut "kate_mdi_toolview_kateprojectgit"                         "Ctrl+Shift+G"  $config_file    $section
    set_shortcut "kate_mdi_toolview_kateprojectinfo"                        "Alt+Shift+P"   $config_file    $section
    set_shortcut "kate_mdi_toolview_lspclient_symbol_outline"               "Ctrl+Shift+S"  $config_file    $section
    set_shortcut "kate_mdi_toolview_output"                                 "Alt+Shift+O"   $config_file    $section
}


# set_global_shortcuts
# set_kwrite_shortcuts
set_kate_shortcuts

# restart-shortcuts-daemon
