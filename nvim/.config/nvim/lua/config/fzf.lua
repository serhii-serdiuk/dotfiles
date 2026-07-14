-- fzf / fzf.vim (.vimrc lines 816-1013).
-- The ~20 near-identical "Files from <dir>" commands are table-driven here;
-- names, paths and mappings are byte-identical to the .vimrc.

local map = vim.keymap.set

local function fzf_files(path, bang)
  vim.fn['fzf#vim#files'](path, vim.fn['fzf#vim#with_preview'](), bang and 1 or 0)
end

-- All files recursively from current working directory (pwd)
map('', '<leader>oa', ':Files!<cr>')
-- Everything from current working directory except .gitignore
map('', '<leader>og', ':GFiles! --cached --others --exclude-standard<cr>')
map('', '<leader>oo', ':GFiles! --cached --others --exclude-standard<cr>')
-- History of opened files (recent files)
map('', '<leader>or', ':History<cr>')

-- Files from current file dir
vim.api.nvim_create_user_command('CurrentDir', function(opts)
  fzf_files(vim.fn.expand('%:p:h'), opts.bang)
end, { bang = true })
map('', '<leader>oc', ':CurrentDir!<cr>')

-- Directory browse commands: { command, path, mappings... }
local dir_commands = {
  { 'SystemRootDir', '/', '<leader>osr' },
  { 'SystemConfigDir', '/etc', '<leader>osc' },
  { 'SystemUsrDir', '/usr', '<leader>osu' },
  { 'SystemShareDir', '/usr/share', '<leader>oss' },
  { 'SystemAppsDir', '/usr/share/applications', '<leader>osa' },
  { 'SystemLibDir', '/usr/lib', '<leader>osl' },
  { 'SystemPythonPackagesDir', '/usr/lib/python3/dist-packages', '<leader>osp' },
  { 'SystemPython38Dir', '/usr/lib/python3.8' },
  { 'SystemPython310Dir', '/usr/lib/python3.10' },
  { 'UserHomeDir', '~', '<leader>ouh', '<leader>oh' },
  { 'UserDotfilesDir', '~/.dotfiles', '<leader>oud', '<leader>od' },
  { 'UserConfigDir', '~/.config', '<leader>ouc' },
  { 'UserConfigKonsaveDir', '~/.config/konsave', '<leader>ouk', '<leader>ok' },
  { 'UserVimDir', '~/.vim', '<leader>ouv', '<leader>ov' },
  { 'UserShellUtilsDir', '~/.shell-utils', '<leader>ouu' },
  { 'UserSetupScriptsDir', '~/Projects/setup/setup-scripts', '<leader>ous' },
  { 'UserConfigsBackupDir', '~/Projects/setup/configs-backup', '<leader>oub' },
  { 'UserNotesDir', '~/Documents/notes', '<leader>oun', '<leader>on' },
  -- Files recursively from current project build dir
  { 'ProjectBuildDir', 'build-craft', '<leader>opb' },
  { 'FrameworksCraftDir', '~/CraftRoot', '<leader>ofc' },
}

for _, spec in ipairs(dir_commands) do
  local name, path = spec[1], spec[2]
  vim.api.nvim_create_user_command(name, function(opts)
    fzf_files(path, opts.bang)
  end, { bang = true })
  for i = 3, #spec do
    map('', spec[i], ':' .. name .. '!<cr>')
  end
end

-- Currently opened buffers
map('', '<leader>ob', ':Buffers<cr>')
map('', '<leader>bo', ':Buffers<cr>')

-- Override Rg (ripgrep) command to also search hidden files (excluding .git)
vim.api.nvim_create_user_command('Rg', function(opts)
  vim.fn['fzf#vim#grep'](
    'rg --column --line-number --no-heading --color=always --smart-case --hidden --glob "!.git" '
      .. vim.fn.shellescape(opts.args),
    1, vim.fn['fzf#vim#with_preview'](), opts.bang and 1 or 0)
end, { bang = true, nargs = '*' })

-- Grep recursively through all of the files in current dir via ripgrep
-- (the <c-w> deletes the '<,'> range fzf.vim can't handle when run from visual mode)
map('', '<leader>ga', ':<c-w>Rg<cr>')
map('', '<leader>gg', ':<c-w>Rg<cr>')
-- Grep for word under cursor
map('n', '<leader>gw', [[<leader>sw:exec "Rg ".expand('<cword>')<cr>]], { remap = true })
map('n', '<leader>gW', [[<leader>sW:exec "Rg ".expand(getreg('/'))<cr>]], { remap = true })
map('v', '<leader>gw', [[<leader>sw:exec "Rg ".expand(getreg('/'))<cr>]], { remap = true })
-- Search through the content of the current buffer
map('', '<leader>gc', ':BLines<cr>')
-- Search through the content of all opened buffers
map('', '<leader>go', ':Lines<cr>')

-- Git status
map('', '<leader>gs', ':GFiles!?<cr>')
-- Git commits for the current buffer; visual-select lines to track changes in the range
map('', '<leader>glc', ':BCommits!<cr>')
-- Git commits (requires fugitive.vim)
map('', '<leader>gla', ':Commits!<cr>')
map('', '<leader>gll', ':Commits!<cr>')

-- Search through the all commands
map('', '<leader>ca', ':Commands<cr>')
-- Search through the commands history
map('', '<leader>ch', ':History:<cr>')
-- Normal mode mappings
map('', '<leader>cm', ':Maps<cr>')

-- Search through the history of search
map('', '<leader>sh', ':History/<cr>')

-- Changelist across all open buffers
map('', '<leader><leader>c', ':Changes<cr>')
-- Windows
map('', '<leader><leader>vw', ':Windows<cr>')
-- All marks
map('', '<leader><leader>ma', ':Marks<cr>')
-- Marks in the current buffer
map('', '<leader><leader>mc', ':BMarks<cr>')
map('', '<leader><leader>mm', ':BMarks<cr>')

-- Adjust commands options
vim.g.fzf_vim = {
  files_options = '--layout=reverse',
  gfiles_options = '--layout=reverse',
  buffers_options = '--layout=reverse',
  rg_options = '--layout=reverse',
  blines_options = '--layout=reverse',
  lines_options = '--layout=reverse',
  commands_options = '--layout=reverse',
  changes_options = '--layout=reverse',
  windows_options = '--layout=reverse',
  bmarks_options = '--layout=reverse',
  marks_options = '--layout=reverse',
  maps_options = '--layout=reverse',
  bcommits_options = '--layout=reverse',
  commits_options = '--layout=reverse',
}

-- Build a quickfix list when multiple files are selected.
-- Vimscript block: g:fzf_action values must be vimscript funcrefs
vim.cmd([[
function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

" Customize actions
let g:fzf_action = {
  \ 'ctrl-l': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-v': 'vsplit',
  \ 'ctrl-s': 'split'
\ }
]])
