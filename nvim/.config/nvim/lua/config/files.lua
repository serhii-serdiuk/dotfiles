-- "Manage files" plugins: NERDTree, ranger.vim, vim-renamer (.vimrc lines 1015-1087).

local map = vim.keymap.set

-- ===== nerdtree plugin
if vim.g.vscode == nil then
  -- Mirror the NERDTree before showing it. This makes it the same on all tabs.
  map('n', '<c-n>', ':NERDTreeMirror<cr>:NERDTreeFocus<cr><c-w>=')
  map('n', '<c-f>', ':NERDTreeMirror<cr>:NERDTreeFocus<cr><c-w><c-p>:NERDTreeFind<cr><c-w>=')
end

vim.g.NERDTreeMapPreview = 'i'
vim.g.NERDTreeMapOpenSplit = '<leader>ss'
vim.g.NERDTreeMapOpenVSplit = '<leader>vv'
vim.g.NERDTreeWinSize = 35

-- Vimscript block: window/buffer juggling one-liners and the s:-scoped tree
-- sync logic, kept verbatim from the .vimrc
vim.cmd([[
" Close the tab if NERDTree is the only window remaining in it.
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if winnr() == winnr('h') && bufname('#') =~ 'NERD_tree_' && bufname('%') !~ 'NERD_tree_' && winnr('$') > 1 |
  \ let buf=bufnr() | buffer# | execute "normal! \<c-w>wzz" | execute 'buffer'.buf | endif

" Below is the logic of synchronizing trees on windows switch
function! s:is_nerd_tree_opened()
  return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
endfunction

let g:nerd_tree_sync_blocked = 0

function! s:sync_nerd_tree()
  " Do nothing if NERDTree not opened or it's in the current window
  if !s:is_nerd_tree_opened() || winnr() == bufwinnr(t:NERDTreeBufName)
    return
  endif
  " Current buffer is a valid file
  if strlen(expand('%')) > 0 && &modifiable && &buftype != 'nofile'
    if !g:nerd_tree_sync_blocked
      let cur_win = winnr()
      let prev_win = winnr('#')
      let g:nerd_tree_sync_blocked = 1
      execute 'NERDTreeFind'
      normal! zz
      execute prev_win . 'wincmd w'
      execute cur_win . 'wincmd w'
      let g:nerd_tree_sync_blocked = 0
    endif
  endif
endfunction

autocmd BufEnter * call s:sync_nerd_tree()
]])

-- ===== ranger plugin (requires bclose.vim under Neovim, added in plugins.lua)
map('n', '<leader>dc', ':Ranger<cr>')
map('n', '<leader>dd', ':RangerWorkingDirectory<cr>')

vim.g.ranger_map_keys = 0

-- ===== vim-renamer plugin
map('n', '<leader>br', ':Renamer<cr>')
map('n', '<leader>rx', ':Ren<cr>')

vim.g.RenamerShowHidden = 1
