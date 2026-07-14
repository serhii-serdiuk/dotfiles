-- Core options (.vimrc lines 1-49).
-- Dropped as unnecessary in Neovim:
--   set nocompatible   -- always off in nvim
--   set encoding=utf-8 -- always utf-8 in nvim
--   syntax on          -- enabled by default in nvim
--   set t_Co=256       -- termcap options removed in nvim
--   set ttymouse=sgr   -- nvim always uses SGR mouse protocol

local M = {}

vim.opt.expandtab = true   -- Use spaces instead of tab
vim.opt.tabstop = 4        -- Width of tab character
vim.opt.shiftwidth = 4     -- Determines whitespace amount used for indentation
vim.opt.autoindent = true
vim.opt.textwidth = 120
vim.opt.listchars = { eol = '$' }

vim.opt.showtabline = 2    -- Always display the tabline, even if there is only one tab
vim.opt.laststatus = 2     -- Always display the statusline in all windows
vim.opt.showmode = false   -- Hide the default mode text (e.g. -- INSERT -- below the statusline)

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.mouse = 'a'

function M.foldtext()
  return vim.fn.getline(vim.v.foldstart) .. '···' .. '[' .. (vim.v.foldend - vim.v.foldstart + 1) .. ' lines]'
end

vim.opt.foldenable = true
vim.opt.foldtext = 'v:lua.require("config.options").foldtext()'
vim.opt.fillchars = { vert = '|', fold = '·', eob = '~' }
vim.opt.foldlevelstart = 99

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wildignorecase = true

vim.opt.matchpairs:append('<:>')
vim.opt.iskeyword:remove('#')

vim.opt.hidden = true      -- Do not keep unlisted buffers
vim.opt.wildmenu = true    -- Enable enhanced command-line completion menu
vim.opt.showcmd = true     -- Show partially typed commands in status line
vim.opt.showmatch = true   -- Show matching brackets
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 50

return M
