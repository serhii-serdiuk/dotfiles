# .zshrc

# Source global definitions for Fedora, for other distros it's done automatically
# TODO: fix "bad substitution" error
# DISTRO=$(head -n 1 /etc/os-release | cut -d "\"" -f 2 | cut -d " " -f 1)
# DISTRO=${DISTRO,,} && DISTRO=${DISTRO^}
DISTRO="Tuxedo"
# TODO: check if needed on Fedora
# if [[ $DISTRO == "Fedora" && -f /etc/bashrc ]]; then
#     . /etc/bashrc
# fi

setopt histignorealldups histignorespace sharehistory

# Set history related vars
export HISTSIZE=1000
export SAVEHIST=1000
export HISTFILE=~/.zsh_history
export HISTORY_IGNORE='(q|qq|vim|v|cd|hn|np)'

# Add some user dirs to PATH
# USER_PATH=$HOME/.local/bin:$HOME/.scripts:$HOME/.nvm/versions/node/v20.9.0/bin
USER_PATH=$HOME/.local/bin:$HOME/.scripts
if ! [[ "$PATH" =~ $USER_PATH ]]; then
    PATH="$PATH:$USER_PATH"
fi

# Define which characters are part of the word (letters and digits included by default)
export WORDCHARS="-_~'\""

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Adjust common bindings
bindkey "^[k" history-search-backward
bindkey "^[j" history-search-forward
bindkey "^[K" history-incremental-search-backward

bindkey "^[h" backward-word
bindkey "^[l" forward-word
bindkey "^[b" backward-char
bindkey "^[f" forward-char

bindkey "^[w" backward-kill-word
bindkey "^[p" yank
bindkey "^[u" undo
bindkey "^[m" accept-line

autoload -U edit-command-line
zle -N edit-command-line
bindkey "^[e" edit-command-line

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Set up fzf key bindings and fuzzy completion
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Set fzf vars
# Setting fd as the default source for fzf
# export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix'
# export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
# To apply the command to CTRL-T as well
# export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_DEFAULT_OPTS='--bind alt-k:preview-page-up,alt-j:preview-page-down'

# TODO: leads to problem with sourcing of craftenv.sh
# export FZF_CTRL_T_OPTS='
#     --walker-skip .git,*.swp
#     --preview="bat --color=always --style=numbers --line-range=:500 {}"'

# export FZF_ALT_C_OPTS='
#     --walker-skip .git,*.swp
#     --preview="tree -a --gitignore -C {}"'

# Bind fzf file search to Ctrl-F
bindkey "^F"  fzf-file-widget
# Bind fzf change directory to Ctrl-T
bindkey "^T"  fzf-cd-widget
# Reset Alt-C binding to default value (optional)
bindkey "^[c" capitalize-word

# Enable fzf ** completion for additional commands
_fzf_complete_env() {
    _fzf_complete -m -- "$@" < <(
        declare -xp | sed 's/=.*//' | sed 's/.* //'
    )
}

_fzf_complete_alias() {
    _fzf_complete +m -- "$@" < <(
        alias | sed 's/=.*//'
    )
}

_fzf_complete_ps() {
    _fzf_complete -m --header-lines=1 --no-preview --wrap --color fg:dim,nth:regular -- "$@" < <(
        command ps -eo user,pid,ppid,start,time,command 2> /dev/null
    )
}

# Insert only PID instead of whole line
_fzf_complete_ps_post() {
    __fzf_exec_awk '{print $2}'
}

_fzf_complete_ssh-copy-id() {
    _fzf_complete +m -- "$@" < <(
        __fzf_list_hosts
    )
}

# Add preview for fzf search results
_fzf_comprun() {
    local command=$1
    shift
    case "$command" in
        cd|pushd|pd|rmdir|tree|ranger|r)
            find . -type d | fzf --preview 'tree -a --gitignore -C {}' "$@" ;;
        env|export|unset)
            fzf --preview 'printenv {}' ;;
        alias|unalias)
            fzf --preview 'bash -c "source $HOME/.shell-utils/aliases.sh && alias {} | bat --color=always --style=numbers --language=sh"' "$@" ;;
        ps|kill|ssh|ssh-copy-id)  # no preview
            fzf "$@" ;;
        *)
            fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}' ;;
    esac
}

# NOTE: conflicts with powerline
# autoload -Uz promptinit
# promptinit
# prompt adam1

# Use powerline prompt
if [ -f "$(which powerline-daemon)" ]; then
    powerline-daemon -q
    if [[ $DISTRO == "Tuxedo" || $DISTRO == "Ubuntu" ]]; then
        . /usr/share/powerline/bindings/zsh/powerline.zsh
    elif [ $DISTRO == "Fedora" ]; then
        # TODO: check on Fedora
        . /usr/share/powerline/zsh/powerline.zsh
    fi
fi

# Set projects related vars
export PROJECTS_DIR=/data/home/Workspace/Projects

# AUTOGENERATED PART STARTS HERE

# Needed for running GUI apps inside container
if [ -z /run/.containerenv ] && [ $XAUTHORITY != $HOME/.Xauthority ]; then
    cp -u $XAUTHORITY $HOME/.Xauthority
fi
