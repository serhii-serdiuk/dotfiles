-- vim-lsp + ALE + asyncomplete (.vimrc lines 1089-1247).
-- The whole stack is vimscript and works under Neovim unchanged, so the
-- fragile parts (funcref-based workarounds) stay as vim.cmd blocks verbatim.

local map = vim.keymap.set

-- ===== vim-lsp plugin
-- Vim's s:lsp_scroll_or checked popup_list(); Neovim renders vim-lsp previews
-- as floating windows, so detect those instead
local function lsp_scroll_or(amount, fallback)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).relative ~= '' then
      vim.fn['lsp#scroll'](amount)
      return '<Ignore>'
    end
  end
  return fallback
end

local function on_lsp_buffer_enabled(ev)
  vim.cmd('set foldmethod=expr foldexpr=lsp#ui#vim#folding#foldexpr()')

  vim.opt_local.omnifunc = 'lsp#complete'
  vim.opt_local.signcolumn = 'yes'
  vim.opt_local.tagfunc = 'lsp#tagfunc'

  local opts = { buffer = ev.buf, remap = true }
  map('n', 'gh', '<plug>(lsp-hover)', opts)
  map('n', 'gd', '<plug>(lsp-definition)', opts)
  map('n', 'gpd', '<plug>(lsp-peek-definition)', opts)
  map('n', 'gD', '<plug>(lsp-declaration)', opts)
  map('n', 'gpD', '<plug>(lsp-peek-declaration)', opts)
  map('n', 'gs', '<plug>(lsp-document-symbol)', opts)
  map('n', 'go', '<plug>(lsp-document-symbol-search)', opts)
  map('n', 'gO', '<plug>(lsp-workspace-symbol-search)', opts)
  map('n', 'gr', '<plug>(lsp-references)', opts)
  map('n', 'gI', '<plug>(lsp-implementation)', opts)
  map('n', 'gpI', '<plug>(lsp-peek-implementation)', opts)
  map('n', 'gt', '<plug>(lsp-type-definition)', opts)
  map('n', 'gy', '<plug>(lsp-type-definition)', opts)
  map('n', 'gpt', '<plug>(lsp-peek-type-definition)', opts)
  map('n', 'gpy', '<plug>(lsp-peek-type-definition)', opts)
  map('n', '<m-j>', function() return lsp_scroll_or(4, '+') end, { buffer = ev.buf, expr = true })
  map('n', '<m-k>', function() return lsp_scroll_or(-4, '-') end, { buffer = ev.buf, expr = true })

  map('n', '<leader>cc', '<plug>(lsp-switch-source-header)', opts)
  map('n', '<leader>rn', '<plug>(lsp-rename)', opts)
  map('n', '<leader>R', '<plug>(lsp-rename)', opts)
  map('n', '<leader>ff', '<plug>(lsp-document-format)', opts)
  map({ 'n', 'v', 'o' }, '<leader>fr', '<plug>(lsp-document-range-format)', opts)
  -- TODO: check functions below
  map('n', '<leader>aa', '<plug>(lsp-code-action-float)', opts)
  map('n', '<leader>ap', '<plug>(lsp-code-action-preview)', opts)
  map('n', '<leader>cl', '<plug>(lsp-code-lens)', opts)

  vim.g.lsp_format_sync_timeout = 1000
  vim.cmd([[autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')]])
end

local lsp_setup = vim.api.nvim_create_augroup('lsp_setup', { clear = true })
-- called only for languages that have the server registered
vim.api.nvim_create_autocmd('User', {
  group = lsp_setup,
  pattern = 'lsp_buffer_enabled',
  callback = on_lsp_buffer_enabled,
})

-- ===== ale plugin
vim.g.ale_virtualtext_cursor = 'current'

vim.g.ale_lint_on_text_changed = 'never'
vim.g.ale_lint_on_insert_leave = 0
vim.g.ale_lint_on_enter = 0
vim.g.ale_lint_on_save = 0

vim.g.ale_fixers = {
  ['*'] = { 'remove_trailing_lines', 'trim_whitespace' },
}
vim.g.ale_fix_on_save = 1

vim.g.ale_c_build_dir_names = { 'build', 'build-craft' }

map('n', '[g', ':lprev<cr>zz')
map('n', ']g', ':lnext<cr>zz')

map('n', '<leader>di', ':ALEPopulateLocList<cr>')
map('n', '<leader>fx', ':ALEFix<cr>')

-- ===== asyncomplete plugin
-- Kept as vimscript verbatim: the buffer-source registration and the two
-- workarounds below build vimscript funcrefs/dicts that have no clean Lua
-- equivalent, and their behavior must stay identical to the Vim setup.
vim.cmd([[
inoremap  <expr> <cr>   pumvisible() ? asyncomplete#close_popup() : "\<cr>"
imap      <expr> <tab>  pumvisible() ? "\<c-n><cr>" : "\<tab>"

" <c-@> corresponds to <c-space> in a terminal; Neovim also knows the real key
imap <c-@> <plug>(asyncomplete_force_refresh)
imap <c-space> <plug>(asyncomplete_force_refresh)

" Preview popup
let g:asyncomplete_min_chars = 3
let g:asyncomplete_auto_completeopt = 0
set completeopt=menuone,noinsert,noselect,preview
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

autocmd User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
  \   'name': 'buffer',
  \   'allowlist': ['*'],
  \   'blocklist': ['go'],
  \   'completor': function('asyncomplete#sources#buffer#completor'),
  \   'config': {
  \     'max_buffer_size': 5000000
  \   }
  \ }))

" asyncomplete-buffer indexes on BufWinEnter, but b:asyncomplete_enable is only
" set on BufEnter which fires after BufWinEnter — so freshly opened buffers are
" never indexed. InsertEnter fires after both, with no ambiguity about which
" buffer is current, making it a reliable trigger for the initial indexing.
function! s:asyncomplete_initial_index()
  if get(b:, 'asyncomplete_enable', 0) && !get(b:, 'asyncomplete_buffer_indexed', 0)
    let l:buffer_info = asyncomplete#get_source_info('buffer')
    call l:buffer_info.on_event(l:buffer_info, {}, 'BufWinEnter')
    let b:asyncomplete_buffer_indexed = 1
  endif
endfunction

autocmd InsertEnter * call s:asyncomplete_initial_index()
" TODO: prepare a PR to asyncomplete-buffer to handle this logic inside plugin
" see also solution from https://github.com/prabirshrestha/asyncomplete-buffer.vim/issues/17#issuecomment-1183146073

" Custom preprocessor for asyncomplete (core): replicate the default
" prefix-filtering logic but also exclude the exact base keyword.
" Root cause: asyncomplete-buffer's completor calls s:refresh_keyword_incremental
" on every keystroke, inserting the currently typed word into the global s:words
" dict. asyncomplete's own default preprocessor never strips exact matches, so
" the word you're typing always surfaces as the first candidate. This hook
" (g:asyncomplete_preprocessor) replaces s:default_preprocessor and adds the
" exclusion.
" NOTE: as bonus, this also enables case-sensitive filtering for buffer source,
" which is more intuitive when the user explicitly types uppercase letters.
function! s:asyncomplete_no_self_complete(options, matches) abort
    let l:items = []
    let l:startcols = []
    for [l:source_name, l:source_matches] in items(a:matches)
        let l:startcol = l:source_matches['startcol']
        let l:base = a:options['typed'][l:startcol - 1:]
        for l:item in l:source_matches['items']
            if empty(l:base) || (stridx(l:item['word'], l:base) == 0 && l:item['word'] !=# l:base)
                call add(l:items, l:item)
                let l:startcols += [l:startcol]
            endif
        endfor
    endfor
    if empty(l:items) | return | endif
    let a:options['startcol'] = min(l:startcols)
    call asyncomplete#preprocess_complete(a:options, l:items)
endfunction
let g:asyncomplete_preprocessor = [function('s:asyncomplete_no_self_complete')]
" TODO: prepare a PR to asyncomplete-buffer/asyncomplete to handle this logic inside plugin
]])
