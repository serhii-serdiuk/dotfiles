-- Small plugin configs + colorscheme (.vimrc lines 786-814, 1249-1302).

local map = vim.keymap.set
local novscode = vim.g.vscode == nil

-- ===== vim-surround plugin
map('n', 'ysw', '<leader>vwS', { remap = true })

-- ===== vim-sneak plugin
map('', 'f', '<Plug>Sneak_f', { remap = true })
map('', 'F', '<Plug>Sneak_F', { remap = true })
map('', 't', '<Plug>Sneak_t', { remap = true })
map('', 'T', '<Plug>Sneak_T', { remap = true })
vim.g['sneak#label'] = 1

local nerdtree_sneak = vim.api.nvim_create_augroup('nerdtree_sneak', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = nerdtree_sneak,
  pattern = 'nerdtree',
  callback = function(ev)
    local opts = { buffer = ev.buf, remap = true }
    map('n', 's', '<Plug>Sneak_s', opts)
    map('n', 'S', '<Plug>Sneak_S', opts)
    map('n', 'f', '<Plug>Sneak_f', opts)
  end,
})

-- ===== scalpel plugin
if novscode then
  map('n', '<leader>rw', [[<leader>sw:nohl<cr>:Scalpel/<c-r>h//<left>]], { remap = true })
end

-- ===== goyo plugin
map('n', '<leader>F', ':Goyo<cr>', { silent = true })
vim.api.nvim_create_autocmd('User', {
  pattern = 'GoyoEnter',
  callback = function() vim.g.ale_virtualtext_cursor = 'disabled' end,
})
vim.api.nvim_create_autocmd('User', {
  pattern = 'GoyoLeave',
  callback = function() vim.g.ale_virtualtext_cursor = 'current' end,
})

vim.g.goyo_width = 120
vim.g.goyo_height = 70

-- ===== lightline plugin
vim.g.lightline = {
  colorscheme = 'dracula',
  component_expand = {
    linter_checking = 'lightline#ale#checking',
    linter_infos = 'lightline#ale#infos',
    linter_warnings = 'lightline#ale#warnings',
    linter_errors = 'lightline#ale#errors',
    linter_ok = 'lightline#ale#ok',
  },
  component_type = {
    linter_checking = 'right',
    linter_infos = 'right',
    linter_warnings = 'warning',
    linter_errors = 'error',
    linter_ok = 'right',
  },
}

-- Colorschemes
vim.opt.background = 'dark'
vim.opt.termguicolors = true  -- enable true colors support

-- pcall: on the very first start the plugins are not installed yet, and an
-- error here would abort the whole init (unlike in vimscript)
pcall(vim.cmd, 'colorscheme dracula')
