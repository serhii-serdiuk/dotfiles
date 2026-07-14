-- Plugin declarations via vim-plug (.vimrc lines 702-784).
-- Changes vs the Vim list:
--   - jasonccox/vim-wayland-clipboard dropped: Neovim talks to wl-copy/wl-paste
--     natively (see :h clipboard-wayland)
--   - rbgrouleff/bclose.vim added: ranger.vim requires it under Neovim

-- Install vim-plug if not installed and the plugins
-- (Neovim autoload dir differs from Vim's ~/.vim/autoload)
local plug_path = vim.fn.stdpath('data') .. '/site/autoload/plug.vim'
local bootstrap = vim.fn.empty(vim.fn.glob(plug_path)) == 1
if bootstrap then
  vim.fn.system({ 'curl', '-fLo', plug_path, '--create-dirs',
    'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' })
  -- Neovim caches runtime-file lookups at startup, so the freshly downloaded
  -- autoload file is not found on this very run -- source it explicitly
  vim.cmd('source ' .. vim.fn.fnameescape(plug_path))
end

vim.cmd('filetype off')

-- Kept as a vimscript block: vim-plug's options (lambdas like { -> fzf#install() })
-- do not translate to Lua funcrefs
vim.cmd([[
call plug#begin()

" Improved defaults
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'Raimondi/delimitMate'

" Improved motions
Plug 'easymotion/vim-easymotion'
Plug 'justinmk/vim-sneak'
Plug 'chaoren/vim-wordmotion'

" Improved substitution
Plug 'wincent/scalpel'

" Fuzzy find everything
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Manage files
Plug 'preservim/nerdtree'
Plug 'francoiscabrol/ranger.vim'
Plug 'rbgrouleff/bclose.vim'
Plug 'qpkorr/vim-renamer'

" Syntax highlighting
Plug 'sheerun/vim-polyglot'
Plug 'ap/vim-css-color'

" LSP for Vim
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'dense-analysis/ale'
Plug 'rhysd/vim-lsp-ale'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'

" Git integration
" Plug 'tpope/vim-fugitive'
" Plug 'airblade/vim-gitgutter'

" Writing and note taking
Plug 'junegunn/goyo.vim'
" Plug 'junegunn/limelight.vim'

" Status/Tabline
Plug 'itchyny/lightline.vim'
Plug 'maximbaz/lightline-ale'

" Colorschemes
Plug 'dracula/vim', { 'as': 'dracula' }

call plug#end()
]])

-- First run: install everything synchronously, then re-run the config so the
-- plugin-dependent parts (colorscheme, <plug> maps) pick the plugins up.
-- (The .vimrc used `autocmd VimEnter * PlugInstall --sync | source $MYVIMRC`;
-- doing it inline is deterministic also in headless runs.)
if bootstrap then
  vim.cmd('PlugInstall --sync')
  vim.cmd('ReloadConfig')
  return
end

vim.cmd('filetype plugin indent on')
