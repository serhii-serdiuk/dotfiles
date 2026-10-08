#!/bin/bash

# brew install python3

venv_path=$HOME/.python/powerline-venv

# # Python package for Powerline is very old (2.7 from 2018) but it's the only available
# # version on macOS, the Homebrew package is not available
# TODO: consider refactor with using pipx for automatic handling of venv
# python3 -m venv $venv_path
source $venv_path/bin/activate
# python3 -m pip install powerline-status

package_root=$(pip show powerline-status | grep Location | sed "s/Location: //")

# echo -e "\nexport PATH=$venv_path/bin:\$PATH" >> $HOME/.zshrc
# echo "if [ -f \"\$(which powerline-daemon)\" ]; then" >> $HOME/.zshrc
# echo "    powerline-daemon -q" >> $HOME/.zshrc
# echo "    . $package_root/powerline/bindings/zsh/powerline.zsh" >> $HOME/.zshrc
# echo "fi" >> $HOME/.zshrc

# brew install --cask iterm2
# brew install --cask font-meslo-lg-nerd-font

# # (optional) Powerline for Vim
# brew install vim
# brew install --cask macvim
# echo -e "\nexport PATH=/usr/local/bin:\$PATH" >> $HOME/.zshrc

# NOTE: No need in this integration, vim plugin used instead
# echo -e "\nif has('mac')" >> $HOME/.vimrc
# echo "    if !has(\"gui_running\")" >> $HOME/.vimrc
# echo "        set rtp+=$package_root/powerline/bindings/vim" >> $HOME/.vimrc
# echo "    else" >> $HOME/.vimrc
# echo "        set guifont=MesloLGM\ Nerd\ Font\ Mono:h14" >> $HOME/.vimrc
# echo "    endif" >> $HOME/.vimrc
# echo "endif" >> $HOME/.vimrc

# Something related to font
echo -e "\nif has('mac')" >> $HOME/.vimrc
echo "    if has(\"gui_running\")" >> $HOME/.vimrc
echo "        set guifont=MesloLGM\ Nerd\ Font\ Mono:h14" >> $HOME/.vimrc
echo "    endif" >> $HOME/.vimrc
echo "endif" >> $HOME/.vimrc
