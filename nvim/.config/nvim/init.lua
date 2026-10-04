-- Neovim config: faithful, behavior-identical port of ../vim/.vimrc.
-- Module order mirrors the .vimrc section order:
--   options -> mappings -> terminal -> plugins (vim-plug) -> per-plugin config -> autocmds
-- Vim-only bits (Alt keycode hacks, ttymouse, t_Co, wayland clipboard plugin)
-- are dropped; every drop and Neovim-specific replacement is commented in place.

-- Hard requirement: vim.keymap.set, nvim_create_user_command and
-- nvim_create_autocmd all appeared in Neovim 0.7 (tested on 0.9.5).
-- Bail out with a readable message instead of cascading nil-call errors.
if vim.fn.has('nvim-0.7') == 0 then
  vim.cmd([[
    echohl WarningMsg
    echomsg 'init.lua: this config requires Neovim 0.7+, loading skipped (use vim with ~/.vimrc instead)'
    echohl None
  ]])
  return
end

-- Reload the whole config (require() caches modules, so plain :source is not enough)
vim.api.nvim_create_user_command('ReloadConfig', function()
  for name in pairs(package.loaded) do
    if name:match('^config%.') then
      package.loaded[name] = nil
    end
  end
  vim.cmd('source $MYVIMRC')
end, {})

require('config.options')
require('config.mappings')
require('config.terminal')  -- terminal-mode setup + Vim termwinkey (CTRL-W) emulation
require('config.plugins')   -- vim-plug bootstrap + plugin declarations
require('config.lsp')       -- vim-lsp + ALE + asyncomplete
require('config.fzf')
require('config.files')     -- NERDTree + ranger + renamer ("Manage files" group)
require('config.misc')      -- surround, sneak, scalpel, goyo, lightline, colorscheme
require('config.autocmds')
