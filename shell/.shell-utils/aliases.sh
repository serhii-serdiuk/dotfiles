alias ..='cd ..'
alias ...='cd ../..'
alias ls='ls --color=always'
alias ll='ls -lh --group-directories-first'
alias la='LC_COLLATE=C ls -lhA --group-directories-first'
alias pd='pushd'
alias pp='popd'
alias mkfile='touch'
alias mkdir='mkdir -p'
alias rmdir='rm -rf'
alias find='find 2>/dev/null'
alias grep='grep --color=auto'
alias igrep='grep -Ev'
alias psgrep='ps auxf | grep -Ei'
alias hgrep='history | grep -Ei'
alias less='less -R'

# Bash specific
alias ha='history -a'                           # append session history to the history list
alias hc='history -c; history -r'               # clear session history and reread the list
alias hs='history -a; history -c; history -r'   # append session history and reread the list (sync)

# Zsh specific
alias hn='fc -p'    # push new empty history list (affects only current session)
alias hp='fc -P'    # pop back previous history list

alias qq='history -c 2>/dev/null && exit || vim ~/.zsh_history && exit'
alias q='exit'

alias bat='bat --color=always --style=numbers'
alias algrep='alias | bat --language=sh | grep --color=never -F'

alias fzf='fzf -m'
alias fzfp='fzf --preview="bat --color=always --style=numbers --line-range=:500 {}" --layout=reverse'
alias ff='find -L . -type f | fzfp'
alias ffsr='find -L / -type f | fzfp'
alias ffsc='find -L /etc -type f | fzfp'
alias ffuh='find -L ~ -type f | fzfp'
alias ffuc='find -L ~/.config -type f | fzfp'
alias ffuk='find -L ~/.config/konsave -type f | fzfp'
alias ffuv='find -L ~/.vim -type f | fzfp'
alias ffuu='find -L ~/.shell-utils -type f | fzfp'
alias ffus='find -L ~/Projects/setup/setup-scripts -type f | fzfp'
alias ffub='find -L ~/Projects/setup/configs-backup -type f | fzfp'
alias ffun='find -L ~/Documents/notes -type f | fzfp'
alias ffpb='find -L build* -type f | fzfp'
alias fffc='find -L ~/CraftRoot -type f | fzfp'
alias v='vim'
alias vc='vim $(ff)'
alias vsr='vim $(ffsr)'
alias vsc='vim $(ffsc)'
alias vuh='vim $(ffuh)'
alias vuc='vim $(ffuc)'
alias vuk='vim $(ffuk)'
alias vuv='vim $(ffuv)'
alias vuu='vim $(ffuu)'
alias vus='vim $(ffus)'
alias vub='vim $(ffub)'
alias vun='vim $(ffun)'
alias vpb='vim $(ffpb)'
alias vfc='vim $(fffc)'

alias hh='hstr'
alias hf='eval $(history | sed "s/^ *[0-9]* *//" | fzf --tac --tiebreak=index --height=10)'
alias r='ranger'
alias tree-dirs='tree -d -L 3 --gitignore'
alias unzip-multipart='7z x'

alias df='df -hT -x tmpfs -x devtmpfs -x efivarfs'
alias df-all='/usr/bin/df -hT'
alias du='du -hs'
alias du-subfolders='/usr/bin/du -h'

alias lsgpu='lspci -k | grep -E "VGA|3D" -A3 --color=never'
alias lsnet='lspci -k | grep -E "Network" -A3 --color=never'
alias lscam='lsusb | grep -E -i "camera|webcam|video" --color=never'
alias lsports='sudo ss -tulpan | grep LISTEN'
alias lsfonts='fc-list'
alias lsgroups='cat /etc/group'
alias cpu-threads-count='grep -c ^processor /proc/cpuinfo'
alias sysinfo='inxi -F'

alias log-follow='journalctl --no-hostname -b -f'
alias log-current-boot='journalctl --no-hostname -b'
alias log-previos-boot='journalctl --no-hostname -b -1'

alias tmux-new-session='systemd-run --scope --user tmux new -s'
alias tmux-attach-session='tmux attach -t'

# alias qemu-run-iso='qemu-system-x86_64 -machine q35 -enable-kvm -m 6G -cpu host -smp 4 -vga virtio -display sdl,gl=on -cdrom'
alias qemu-run-iso='qemu-system-x86_64 -machine q35 -enable-kvm -m 6G -cpu host -smp 4 -device virtio-vga-gl,xres=1920,yres=1080 -display sdl,gl=on -cdrom'
alias qemu-convert-to-vdi='qemu-img convert -f qcow2 -O vdi disk.qcow2'
alias qemu-shrink-image='qemu-img convert -O qcow2 disk.qcow2 disk-new.qcow2 && mv disk-new.qcow2 disk.qcow2'

alias containers-storage='sudo du -h -d 1 --time /data/home/.local/share/containers/storage/overlay/ | sort -k2,3'
alias dbox-leftovers='podman system df -v && containers-storage | grep "$(date +"%Y-%m-%d %H:%M")"'
alias dbox-create-neon-testing='distrobox create -i invent-registry.kde.org/neon/docker-images/plasma:testing -n kde-neon-testing -H ~/Distroboxes/kde-neon-testing --init'
alias dbox-create-fedora='distrobox create -i fedora -H /data/home/Distroboxes/fedora --init'

alias restart-plasma='pkill plasmashell; plasmashell > /dev/null 2>&1 & disown'
alias restart-kwin='pkill kwin; kwin > /dev/null 2>&1 & disown'
alias restart-shortcuts-daemon='pkill kglobalaccel5; kglobalaccel5 > /dev/null 2>&1 & disown'

alias git-repo-size='git count-objects -Hv'
alias git-path-remove='git filter-repo --invert-paths --path'
alias git-show='git show --oneline --stat --summary --find-renames=30%'
alias git-status='git status -sb'
alias git-branch='git branch -vv'
alias git-search-branch='git branch -vv --all | grep -i'
alias git-fetch='git fetch && git branch -vv'
alias git-mergetool='git mergetool'

alias git-dag-current='git-dag-list.sh `pwd` --current'
alias git-dag-upstream-diff='git-dag-list.sh `pwd` --upstream-diff'
alias git-dag-review='git-dag-list.sh `pwd` --review'

# Cursor Agent CLI
alias ca='cursor-agent'

# Work aliases
