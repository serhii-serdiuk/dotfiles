-- Terminal mappings (.vimrc lines 144-145, 168-171, 195-217, 248, 294-311, 561).
-- This is the most Neovim-divergent part of the port. Vim 8's terminal differs
-- from Neovim's in four ways this module compensates for:
--   1. Vim's :terminal opens in a new split; Neovim's opens in the CURRENT
--      window. Mappings are rewritten accordingly (e.g. <leader>tt becomes a
--      plain :vnew + :terminal, no dummy-window cleanup dance needed).
--   2. Vim enters Terminal-Job mode automatically on open and on entering a
--      terminal window; Neovim stays in Normal mode. Emulated with TermOpen /
--      WinEnter startinsert autocmds. (Known difference: Vim preserves
--      Terminal-Normal mode when you leave and re-enter a window; here
--      re-entering always lands in job mode.)
--   3. In Vim, CTRL-W in Terminal-Job mode is the built-in window-command
--      prefix (termwinkey); Neovim sends CTRL-W to the job. Recreated with
--      terminal-mode mappings below.
--   4. :shell was removed in Neovim, so the :shell mappings use :terminal.

local map = vim.keymap.set

-- (2) Auto-enter job mode; terminals show no line numbers in Vim
vim.api.nvim_create_autocmd('TermOpen', {
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd('startinsert')
  end,
})
vim.api.nvim_create_autocmd('WinEnter', {
  callback = function()
    if vim.bo.buftype == 'terminal' then
      vim.cmd('startinsert')
    end
  end,
})

-- (3) CTRL-W prefix emulation, global for all terminal buffers.
-- The bare <c-w> covers every normal-mode window command (h/j/k/l, T, x,
-- g<tab>, <c-p>, ...); longer mappings below cover Vim's termwinkey specials.
map('t', '<c-w>', [[<c-\><c-n><c-w>]])
map('t', '<c-w>:', [[<c-\><c-n>:]])   -- command line (Vim: CTRL-W :)
map('t', '<c-w>N', [[<c-\><c-n>]])    -- Terminal-Normal mode (Vim: CTRL-W N)
map('t', '<c-w>"', function()         -- paste register (Vim: CTRL-W "{reg})
  return [[<c-\><c-n>"]] .. vim.fn.nr2char(vim.fn.getchar()) .. 'pi'
end, { expr = true })

-- Was: nnoremap <leader>S :shell<cr> -- see (4); with (1) this replaces the
-- current window's buffer with a terminal instead of suspending to a subshell
map('n', '<leader>S', ':terminal<cr>')

map('n', '<c-@>', '<c-^>')  -- kept in mappings.lua too; here for the t-mode pair
map('t', '<c-@>', [[<c-\><c-n>:b#<cr>]])
map('t', '<c-space>', [[<c-\><c-n>:b#<cr>]])

-- Terminal (Vim versions juggled the extra split that :terminal created, see (1))
map('n', '<leader>T', ':terminal<cr>')
map('n', '<leader>tt', ':vnew<cr>:terminal<cr>')
map('n', '<leader>th', ':new<cr>:res -10<cr>:terminal<cr>')
map('n', '<c-w>tt', ':vnew<cr>:terminal<cr>')

-- Was: nmap <c-w>r <c-w>tt<c-w><c-w>i<c-d><c-w><c-w> (and a tmap twin):
-- open a fresh terminal split and CTRL-D the old shell. Ported as a function
-- because the keystroke chain relies on Vim's auto-job-mode timing.
local function restart_terminal()
  local old = vim.api.nvim_get_current_buf()
  vim.cmd('vnew')
  vim.cmd('terminal')
  if vim.bo[old].buftype == 'terminal' then
    vim.fn.chansend(vim.bo[old].channel, '\4')  -- CTRL-D
  end
end
map('n', '<c-w>r', restart_terminal)

-- Terminal only mappings
map('t', '<c-n>', [[<c-\><c-n>:vert res +6<cr>ggG]])
map('n', 'i', function()
  return vim.bo.buftype == 'terminal' and ':vert res -6<cr>i' or 'i'
end, { expr = true })

-- Buffer-local mappings Vim added via `autocmd TerminalOpen * tnoremap <buffer> ...`
vim.api.nvim_create_autocmd('TermOpen', {
  callback = function(ev)
    local opts = { buffer = ev.buf }
    local function tmap(lhs, rhs, extra)
      map('t', lhs, rhs, extra and vim.tbl_extend('force', opts, extra) or opts)
    end

    tmap('<c-w>S', [[<c-\><c-n>:terminal<cr>]])  -- was <c-w>:shell, see (4)

    tmap('<c-w><c-w>', [[<c-\><c-n><c-w><c-p>]])
    tmap('<c-w>0', [[<c-\><c-n><c-w>t]])
    tmap('<c-w>9', [[<c-\><c-n><c-w>b]])
    -- Go to Nth window (WinEnter autocmd restores job mode when coming back)
    for i = 1, 4 do
      tmap('<c-w>' .. i, [[<c-\><c-n>]] .. (i + 1) .. '<c-w><c-w>')
    end

    -- Resizing (trailing `i` returns to job mode, like Vim's CTRL-W : did)
    tmap('<c-w>-', [[<c-\><c-n>:res -10<cr>i]])
    tmap('<c-w>+', [[<c-\><c-n>:res +10<cr>i]])
    tmap('<c-w><', [[<c-\><c-n>:vert res -10<cr>i]])
    tmap('<c-w>>', [[<c-\><c-n>:vert res +10<cr>i]])

    -- Rotating
    tmap('<c-w><c-r>', [[<c-\><c-n><c-w>xi]])

    -- Switching tabs
    tmap('<c-w><c-@>', [[<c-\><c-n>g<tab>]])
    tmap('<c-w><c-space>', [[<c-\><c-n>g<tab>]])

    -- New terminals
    tmap('<c-w>tt', [[<c-\><c-n>:vnew<cr>:terminal<cr>]])
    tmap('<c-w>th', [[<c-\><c-n>:new<cr>:res -10<cr>:terminal<cr>]])
    tmap('<c-w>r', restart_terminal)

    -- Set mark g and stay in job mode (was <c-w>Nmgi)
    tmap('<c-w>m', [[<c-\><c-n>mgi]])
    tmap('<c-w><c-m>', [[<c-\><c-n>mgi]])

    -- Paste registers into the terminal (was Vim's CTRL-W "0 / "+)
    tmap('<c-w>pp', [[<c-\><c-n>"0pi]])
    tmap('<c-w>py', [[<c-\><c-n>"0pi]])
    tmap('<c-w>pc', [[<c-\><c-n>"+pi]])

    -- Check registers' values (was <c-w>:reg<cr>; ends in Terminal-Normal mode
    -- because the hit-enter prompt would swallow a trailing `i`)
    tmap("<c-w>'", [[<c-\><c-n>:reg<cr>]])
  end,
})
