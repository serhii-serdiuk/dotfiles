-- General autocommands (.vimrc lines 1347-1383).
-- The TerminalOpen ones live in terminal.lua (TermOpen in Neovim).

local autocmd = vim.api.nvim_create_autocmd

-- Remember folds between sessions
local remember_folds = vim.api.nvim_create_augroup('remember_folds', { clear = true })
autocmd('BufWinLeave', {
  group = remember_folds,
  command = [[if expand('%') != '' | mkview | endif]],
})
autocmd('BufWinEnter', {
  group = remember_folds,
  command = [[if expand('%') != '' | silent! loadview | endif]],
})

-- Return to the last cursor position when opening files
autocmd('BufReadPost', {
  command = [[if line("'\"") > 0 && line("'\"") <= line("$") | execute "normal! `\"" | endif]],
})

-- Enable syntax highlighting for additional set of files
autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = vim.fn.expand('~') .. '/.config/*',
  command = 'setfiletype dosini',
})
autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = 'requirements*.txt',
  command = 'set syntax=python',
})

-- Force indentation width for C++ files to 4 spaces
autocmd('BufEnter', {
  pattern = { '*.cpp', '*.h' },
  command = 'setlocal shiftwidth=4',
})

-- Do not consider '-' as part of word for C++ files
-- (should not be applied for C++ due to operator->())
autocmd({ 'BufWinEnter', 'BufNewFile', 'BufRead' }, {
  callback = function()
    local ft = vim.bo.filetype
    if ft ~= 'cpp' or ft == '' then
      vim.opt_local.iskeyword:append('-')
    end
  end,
})

-- Update file if it was changed
autocmd({ 'BufEnter', 'CursorHold' }, {
  callback = function()
    -- checktime is not allowed while the command line is being edited or in
    -- terminal buffers with a running job
    if vim.fn.getcmdwintype() == '' and vim.bo.buftype ~= 'terminal' then
      vim.cmd('checktime')
    end
  end,
})
