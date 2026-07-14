-- Mappings (.vimrc lines 51-700, except terminal-related ones -> terminal.lua).
-- Conventions of the port:
--   noremap X  -> map('', ...)                 (n, v, o modes)
--   map X      -> map('', ..., { remap = true })
--   <expr> mappings with vimscript logic are ported to Lua functions
-- The .vimrc loops that define Alt keys as terminal keycodes (set <m-x>=^[x) and
-- pass them through in :terminal are dropped: Neovim handles Alt/Meta natively.
-- <c-@> (what a terminal sends for CTRL-Space) is kept, with a <c-space> variant
-- added, since Neovim's UI reports the key as <C-Space>.

local map = vim.keymap.set
local novscode = vim.g.vscode == nil  -- guards ported from `if !exists('g:vscode')`

-- Basic mappings
map('i', 'jj', '<esc>')

map('', '<c-e>', '10<c-e>')
map('', '<c-y>', '10<c-y>')
map('', 'zl', '5zl')
map('', 'zh', '5zh')

map('', 'J', '}')
map('', 'K', '{')

map('', 'M', '@@')

map('', 'U', '<c-r>')

map('i', '<c-d>', '<c-o>x')
map('i', '<c-t>', '<c-o>x<c-o>p<c-o>h')
map('i', '<c-j>', '<c-o>dd<c-o>p')
map('i', '<c-k>', '<c-o>dd<c-o>k<c-o>P')

map('v', '<c-j>', 'dp')
map('v', '<c-k>', 'dkP')

-- Built-in completion
map('i', '<c-n>', '<c-x><c-n>')
map('i', '<c-p>', '<c-x><c-p>')
map('i', '<c-l>', '<c-x><c-l>')
map('i', '<c-f>', '<c-x><c-f>')

vim.cmd('cabbrev h vert h')
vim.cmd('cabbrev hh help')

-- Mappings which use Alt/Meta key (keycode setup loops dropped, see header)
map('n', '<m-j>', '+')
map('n', '<m-k>', '-')

map('i', '<m-j>', '<down>')
map('i', '<m-k>', '<up>')
map('i', '<m-b>', '<left>')
map('i', '<m-f>', '<right>')
-- imap: rhs must go through vim-wordmotion's w/b/db/dw remaps
map('i', '<m-h>', '<c-o>b', { remap = true })
map('i', '<m-l>', '<c-o>w', { remap = true })
map('i', '<m-w>', '<c-o>db', { remap = true })
map('i', '<m-d>', '<c-o>dw', { remap = true })
map('i', '<m-p>', '<c-r>"')
map('i', '<m-u>', '<c-o>u')
map('i', '<m-m>', '<cr>')

-- Mappings which use <leader> key which creates a separate namespace
map('n', '<space>', '<nop>')
map('v', '<space>', '<nop>')
vim.g.mapleader = ' '

-- https://vim.fandom.com/wiki/Best_Vim_Tips#Make_it_easy_to_update/reload_vimrc
map('n', '<leader>co', ':edit $MYVIMRC<cr>', { silent = true })
-- :source $MYVIMRC alone is not enough with Lua modules; ReloadConfig (init.lua)
-- drops the require() cache first
map('n', '<leader>cr', ':ReloadConfig<cr>:nohl<cr>', { silent = true })

map('n', '<leader>w', ':w<cr>')
map('n', '<leader>q', ':q<cr>')
map('n', '<leader>Q', ':qa!<cr>')
map('n', '<leader>cq', ':cq<cr>')
map('n', '<c-s>', ':silent! w<cr>', { silent = true })
map('i', '<c-s>', '<esc>:silent! w<cr>', { silent = true })
map('n', '<c-q>', ':q<cr>')

-- <leader>S (:shell in Vim) lives in terminal.lua -- :shell does not exist in nvim

vim.g.initial_cwd = vim.fn.getcwd(-1)
map('n', '<leader>rdl', function() vim.cmd('lcd ' .. vim.fn.fnameescape(vim.g.initial_cwd)) end)
map('n', '<leader>rdt', function() vim.cmd('tcd ' .. vim.fn.fnameescape(vim.g.initial_cwd)) end)

local function reset_local_dirs_to_global()
  -- TODO: consider using tabdo and windo instead of loops
  -- Reset all tab-local directories
  for tabpage = 1, vim.fn.tabpagenr('$') do
    vim.cmd(tabpage .. 'tabnext')
    if vim.fn.haslocaldir() == 2 then
      vim.cmd('tcd ' .. vim.fn.fnameescape(vim.fn.getcwd(-1)))
    end
    -- Reset all window-local directories for current tab
    for window = 1, vim.fn.winnr('$') do
      vim.cmd(window .. 'wincmd w')
      if vim.fn.haslocaldir() == 1 then
        vim.cmd('lcd ' .. vim.fn.fnameescape(vim.fn.getcwd(-1)))
      end
    end
  end
end

vim.api.nvim_create_user_command('ChangeGlobalWorkingDir', function(opts)
  vim.cmd('cd ' .. opts.args)
  reset_local_dirs_to_global()
end, { nargs = 1, complete = 'dir' })

map('n', '<leader>rdg', [[:ChangeGlobalWorkingDir <c-r>=expand(g:initial_cwd) . '/'<cr>]])
map('n', '<leader>cdl', [[:lcd <c-r>=expand('%:.:h') . '/'<cr>]])
map('n', '<leader>cdt', [[:tcd <c-r>=expand('%:.:h') . '/'<cr>]])
map('n', '<leader>cdg', [[:ChangeGlobalWorkingDir <c-r>=expand('%:.:h') . '/'<cr>]])
map('n', '<leader>e', [[:e <c-r>=expand('%:.:h') . '/'<cr>]])
-- https://vimways.org/2019/vim-and-the-working-directory/

-- Buffers
map('n', '<leader>bn', ':bn<cr>')
map('n', '<leader>bp', ':bp<cr>')
map('n', '<leader>bb', ':ls<cr>:b<space>')
map('n', '<leader>bl', ':ls!<cr>:b<space>')
map('n', '<leader>bd', ':bd<cr>')
map('n', '<leader>bw', ':ls!<cr>:bwipe<space>')
map('n', '<leader>x', function()
  local alt = vim.fn.bufnr('#')
  return (alt ~= -1 and vim.fn.buflisted(alt) == 1) and '<c-^>:bd #<cr>' or ':bd<cr>'
end, { expr = true })
map('n', '<leader>X', function()
  local alt = vim.fn.bufnr('#')
  return (alt ~= -1 and vim.fn.buflisted(alt) == 1) and '<c-^>:bwipe #<cr>' or ':bwipe<cr>'
end, { expr = true })

map('n', '<c-@>', '<c-^>')
map('n', '<c-space>', '<c-^>')

-- Split windows
map('n', '<leader>ss', ':split<cr>')
map('n', '<leader>vv', ':vsplit<cr>')
map('n', '<leader>nn', ':vnew<cr>')
map('n', '<leader>nh', ':new<cr>:res -10<cr>')
map('n', '<leader>nt', ':tab new<cr>')
map('n', '<leader>h', '<c-w>h')
map('n', '<leader>j', '<c-w>j')
map('n', '<leader>k', '<c-w>k')
map('n', '<leader>l', '<c-w>l')
map('n', '<leader>;', '<c-w><c-p>')
map('n', '<c-w><c-w>', '<c-w><c-p>')

map('n', '<c-w>0', '<c-w><c-t>')
map('n', '<c-w>9', '<c-w><c-b>')
for i = 1, 4 do
  map('n', '<c-w>' .. i, (i + 1) .. '<c-w><c-w>')
end

-- Resizing
map('n', '<leader>-', ':res -10<cr>')
map('n', '<leader>+', ':res +10<cr>')
map('n', '<leader><', ':vert res -10<cr>')
map('n', '<leader>>', ':vert res +10<cr>')
map('n', '<leader>=', '<c-w>=')

-- Rotating
map('n', '<c-w><c-r>', '<c-w><c-x>')

-- Tab pages
map('n', '<c-t>', ':tab split<cr>')
map('n', '<leader>tnc', ':tab split<cr>')
map('n', '<leader>tnp', ':-tab split<cr>')
map('n', '<leader>tnn', ':+tab split<cr>')
map('n', '<leader>tnf', ':0tab split<cr>')
map('n', '<leader>tnl', ':$tab split<cr>')
map('n', '<leader>tn0', ':0tab split<cr>')
map('n', '<leader>tn9', ':$tab split<cr>')
map('n', '<leader>tne', ':tab new<cr>')
map('n', '<leader>tnw', '<c-w>T')

-- Switching
map('n', 'H', ':tabp<cr>', { silent = true })
map('n', 'L', ':tabn<cr>', { silent = true })
map('n', '<leader><tab>', 'g<tab>')
map('n', '<c-w><c-@>', 'g<tab>')
map('n', '<c-w><c-space>', 'g<tab>')

map('n', 'g0', ':tabn 1<cr>')
map('n', 'g9', ':tabn $<cr>')
map('n', '<leader>0', ':tabn 1<cr>')
for i = 1, 8 do
  map('n', '<leader>' .. i, ':tabn ' .. i .. '<cr>')
end
map('n', '<leader>9', ':tabn $<cr>')

-- Moving
map('n', '<m-,>', ':tabm -<cr>')
map('n', '<m-.>', ':tabm +<cr>')
map('n', '<leader>tmm', ':tabm #<cr>')
map('n', '<leader>tmf', ':tabm 0<cr>')
map('n', '<leader>tml', ':tabm $<cr>')
map('n', '<leader>tm0', ':tabm 0<cr>')
map('n', '<leader>tm9', ':tabm $<cr>')

-- Terminal mappings live in terminal.lua

-- Diff
map('n', '<leader>df', ':NERDTreeClose<cr>:windo diffthis<cr>')
map('n', '<leader>dx', ':windo diffoff<cr>:NERDTreeFind<cr><c-w>=<c-w><c-p>')
map('n', '<leader>du', ':diffupdate<cr>')

-- Workaround to make mappings work in Cursor
if novscode then
  map('n', 'J', function()
    return vim.wo.diff and ']c' or ':keepjumps normal! }<cr>'
  end, { expr = true, silent = true })
  map('n', 'K', function()
    return vim.wo.diff and '[c' or ':keepjumps normal! {<cr>'
  end, { expr = true, silent = true })
end

-- For using as git mergetool
map('n', 'dgh', ':diffget 1<cr>')
map('n', 'dgm', ':diffget 2<cr>')
map('n', 'dgl', function()
  return vim.fn.winnr('$') > 2 and ':diffget 3<cr>' or ':diffget 2<cr>'
end, { expr = true })
map('n', 'dgo', function()
  return vim.fn.winnr('$') == 2 and ':diffget<cr>' or ':echom "dgo: requires exactly 2 windows"<cr>'
end, { expr = true })
-- https://www.youtube.com/watch?v=iLViiiEP4mE

-- Folding
map('', '<leader>fe', 'zi')
map('', '<leader>fu', 'zx')

map('', '<leader>fl', 'zr')
map('', '<leader>fL', 'zR')
map('', '<leader>fh', 'zm')
map('', '<leader>fH', 'zM')
-- For C++ class methods definitions inside namespace (in *.cpp file)
map('', '<leader>fn', ':set foldlevel=1<cr>')

map('', '<leader>fo', 'zo')
map('', '<leader>fO', 'zO')
map('', '<leader>fc', 'zc')
map('', '<leader>fC', 'zC')

map('', '<leader>ft', 'za')
map('', '<leader>fT', 'zA')
map('', '<s-tab>', 'za')

map('', '<leader>fj', ']z')
map('', '<leader>fk', '[z')
map('n', '<leader>fv', 'j[zV]z')

-- Wrapping, formatting and changing the case
map('', '<leader>tw', ':set wrap!<cr>')
map('n', '<leader>tc', 'g~iw')

-- Select, copy and paste to the end of line
map('n', 'Y', 'y$')
map('n', '<leader>V', 'v$h')
map('n', '<leader>pr', '<leader>V<leader>py', { remap = true })
map('n', '<leader>pp', '<leader>V<leader>py', { remap = true })
map('n', '<leader>PP', '<leader>V<leader>py', { remap = true })
map('n', '<leader><leader>p', '<leader>V<leader>py', { remap = true })

-- Select, copy/cut and past the word (including mappings from vim-wordmotion)
map('n', '<leader>vw', 'viw')
map('n', '<leader>ve', 've')
map('n', '<leader>vW', 'viW')

map('n', 'yw', 'yiw', { remap = true })
map('n', '<leader>yw', 'yiw')
map('n', '<leader>ye', 'ye')
map('n', '<leader>yW', 'yiW')

map('n', 'cw', 'ciw', { remap = true })
map('n', '<leader>cw', 'ciw')
map('n', '<leader>ce', 'ce')
map('n', '<leader>cW', 'ciW')

map('n', 'dw', 'daw', { remap = true })
map('n', '<leader>dw', 'daw')
map('n', '<leader>de', 'de')
map('n', '<leader>dW', 'daW')

map('n', '<leader>pw', 'viw"0pgvy')
map('n', '<leader>pW', 'viw"0p', { remap = true })

-- Comment and duplicate lines for debugging purposes
map('n', '<leader>dl', 'yygccp', { remap = true })
map('v', '<leader>dl', 'ygvgcgv<c-c>p', { remap = true })

-- Searching and replacing a word (using *)
map('n', '*', 'viw"hy/<c-r>h<cr>')
-- TODO: try to use | as separator instead of /
map('v', '*', '"hy/<c-r>h<cr>')
map('v', '#', '"hy?<c-r>h<cr>')
-- NOTE: These two below only make sense together with plugin chaoren/vim-wordmotion
map('n', '<leader>*', 'viw*', { remap = true })
map('n', '<leader>#', 'viw#', { remap = true })

map('', '<leader>sw', '*N', { remap = true })
map('n', '<leader>sW', '<leader>*N', { remap = true })

map('n', 'c*', '*Ncgn', { remap = true })
map('v', '<leader>c*', '*Ncgn', { remap = true })
map('n', '<leader>c*', '<leader>*Ncgn', { remap = true })

map('v', '<leader>rw', [[<leader>sw:%s///gc<left><left><left>]], { remap = true })
map('n', '<leader>rW', [[<leader>sW:%s///gc<left><left><left>]], { remap = true })

-- Search commands
map('v', '/', [[o<esc>/\%V]])
map('v', '<leader>sp', '//<cr>')
map('n', '<leader>sc', 'q/')
map('n', '<leader>sy', '/<c-r>0<cr>')
map('n', '<leader>sv', [[/\%V]])

-- Search word at cursor position in different scopes
map('n', '<leader>sip', [[viw"hyvipo<esc>/\%V<c-r>h]])
map('n', '<leader>sib', [[viw"hyvibo<esc>/\%V<c-r>h]])
map('n', '<leader>si(', [[viw"hyvi(o<esc>/\%V<c-r>h]])
map('n', '<leader>si{', [[viw"hyvi{o<esc>/\%V<c-r>h]])
map('n', '<leader>si[', [[viw"hyvi[o<esc>/\%V<c-r>h]])

-- Replace commands
map('n', '<leader>rr', [[:%s//gc<left><left><left>]])
map('v', '<leader>rr', [[:s/\v/g<left><left>]])
map('n', '<leader>rp', [[:%s///gc<left><left><left>]])
map('v', '<leader>rp', [[:s/\v//g<left><left>]])
map('n', '<leader>ry', [[:%s/\v<c-r>0//gc<left><left><left>]])
map('v', '<leader>ry', [[:s/\v<c-r>0//g<left><left>]])
map('n', '<leader>rv', [[:'<,'>s/\v/g<left><left>]])

-- Replace word at cursor position in different scopes
map('n', '<leader>rip', [[viw"hyvip:s/\v<c-r>h//g<left><left>]])
map('n', '<leader>rib', [[viw"hyvib:s/\v<c-r>h//g<left><left>]])
map('n', '<leader>ri(', [[viw"hyvi(:s/\v<c-r>h//g<left><left>]])
map('n', '<leader>ri{', [[viw"hyvi{:s/\v<c-r>h//g<left><left>]])
map('n', '<leader>ri[', [[viw"hyvi[:s/\v<c-r>h//g<left><left>]])

-- Add text to the beginning/end of line with word under cursor
map('n', '<leader>I', 'viw"hy:g/<c-r>h/norm I')
map('n', '<leader>A', 'viw"hy:g/<c-r>h/norm A')
map('v', '<leader>I', ':g/<c-r>0/norm I')
map('v', '<leader>A', ':g/<c-r>0/norm A')

map('n', '<leader>iip', 'viw"hyvip:g/<c-r>h/norm I')
map('n', '<leader>iib', 'viw"hyvib:g/<c-r>h/norm I')
map('n', '<leader>ii(', 'viw"hyvi(:g/<c-r>h/norm I')
map('n', '<leader>ii{', 'viw"hyvi{:g/<c-r>h/norm I')
map('n', '<leader>ii[', 'viw"hyvi[:g/<c-r>h/norm I')

map('n', '<leader>aip', 'viw"hyvip:g/<c-r>h/norm A')
map('n', '<leader>aib', 'viw"hyvib:g/<c-r>h/norm A')
map('n', '<leader>ai(', 'viw"hyvi(:g/<c-r>h/norm A')
map('n', '<leader>ai{', 'viw"hyvi{:g/<c-r>h/norm A')
map('n', '<leader>ai[', 'viw"hyvi[:g/<c-r>h/norm A')

-- Repeat last command
map('', '<leader>:', '@:')

-- Find next character and repeat action
map('', '<leader>.f', [[:let @z=';.'<cr>@z]])

-- Repeat action on next line
map('', '<leader>.j', [[:let @z='j.'<cr>@z]])
map('', '<leader>.+', [[:let @z='+.'<cr>@z]])
map('', '<leader>..', [[:let @z='+.'<cr>@z]])
map('', '<leader>.c', [[:let @z='gcc+'<cr>@z]])

-- arglist, vimgrep and quicklist
map('n', '<leader>al', ':args<cr>')
map('n', '<leader>ac', ':arg<space>')
map('n', '<leader>ad', ':argdo<space>')
map('n', '<leader>ar', ':argdelete<space>')
map('n', '<leader>vg', ':vimgrep // ##<cr>:copen<cr>')
map('n', '<c-j>', ':cnext<cr>zz')
map('n', '<c-k>', ':cprev<cr>zz')
map('n', 'co', ':copen<cr>')
map('n', 'cx', ':cclose<cr>')
map('n', '<leader>rcl', [[:cdo s///c<left><left>]])

-- Copy current file path/name
-- The .vimrc adds a wl-copy system() fallback here because Vim 8 lacks
-- +clipboard under Wayland; Neovim's clipboard provider runs wl-copy natively,
-- so the @+ versions alone already reach the Wayland clipboard
-- Relative path
map('', '<leader>yr', ':let @+=@%<cr>')
-- Absolute path
map('', '<leader>yp', [[:let @+=expand('%:p')<cr>]])
-- Relative dir
map('', '<leader>yd', [[:let @+=expand('%:h')<cr>]])
-- Name
map('', '<leader>yn', [[:let @+=expand('%:t')<cr>]])
-- Name without extention
map('', '<leader>y.', [[:let @+=expand('%:t:r')<cr>]])

-- Copy/paste using different registers
-- Synchronization between yank register and clipboard
map('v', '<leader>yc', '"+y')
map('n', '<leader>yc', ':let @+=@0<cr>')
map('', '<leader>cy', ':let @0=@+<cr>')
if novscode then
  map('n', '<leader>yc', [[:call system('wl-copy', @0)<cr>]])
  map('', '<leader>cy', [[:let @0=system('wl-paste --no-newline')<cr>]])
end

-- Pasting from the different registers
map('', '<leader>pc', '"+p', { remap = true })
map('', '<leader>Pc', '"+P', { remap = true })

map('', '<leader>py', '"0p')
map('', '<leader>Py', '"0P')

map('', '<leader>pd', '"-p')
map('', '<leader>Pd', '"-P')

map('', '<leader>ps', '"/p')
map('', '<leader>Ps', '"/P')

map('', '<leader>ph', '"hp')
map('', '<leader>Ph', '"hP')

-- Check registers' values
map('n', "<leader>'", ':reg<cr>')

-- Navigation via brackets/braces
map('', '(', '[[-%^')
map('', ')', ']]+')

map('', '{', 'F{', { remap = true })
map('', '}', 'f{', { remap = true })

map('', '<leader>(', '{^', { remap = true })
map('', '<leader>)', '}+', { remap = true })
if novscode then
  map('', '<leader>(', [[:let @z='{^'<cr>@z]], { remap = true })
  map('', '<leader>)', [[:let @z='}+'<cr>@z]], { remap = true })
end

map('', '<leader>{', '{+', { remap = true })
map('', '<leader>}', 'f}-', { remap = true })

-- Commented mappings for [{ ]} [( ]) work in Vim/Neovim by default (see .vimrc)
map('n', '[<', 'va<<esc>%')
map('n', ']>', 'va<<esc>')

-- Port of s:brace_select(): jump to the nearest bracket on the line first, so
-- vi{/va{/vi</va< work when the cursor is before/after the pair
local function brace_select(cmd, open)
  local pairs_tbl = { ['('] = ')', ['['] = ']', ['{'] = '}', ['<'] = '>' }
  local close = pairs_tbl[open]
  local full_cmd = cmd .. open
  local line = vim.fn.getline('.')
  local col = vim.fn.col('.')
  if not (line:find(open, 1, true) or line:find(close, 1, true)) then
    return full_cmd
  end
  local char = line:sub(col, col)
  if char == open or char == close then
    return full_cmd
  end
  local rest = line:sub(col + 1)
  if rest:find(open, 1, true) then
    return 'f' .. open .. full_cmd
  elseif rest:find(close, 1, true) then
    return 'f' .. close .. full_cmd
  else
    return (line:find(open, 1, true) and ('F' .. open) or ('F' .. close)) .. full_cmd
  end
end

map('n', 'vi{', function() return brace_select('vi', '{') end, { expr = true })
map('n', 'va{', function() return brace_select('va', '{') end, { expr = true })
map('n', 'vi<', function() return brace_select('vi', '<') end, { expr = true })
map('n', 'va<', function() return brace_select('va', '<') end, { expr = true })

map('n', "va'", "vi'ohol")
map('n', 'va"', 'vi"ohol')

map('n', '<leader>v{', '$va{V')
map('n', '<leader>v(', 'va(V')
map('n', '<leader>v[', 'va[V')
map('n', '<leader>v<', 'va<V')
if novscode then
  -- If there is an opening bracket after the cursor on this line, select inside
  -- the upcoming pair instead of the surrounding one
  local function select_ahead_or_around(open)
    return function()
      local rest = vim.fn.getline('.'):sub(vim.fn.col('.') + 1)
      if rest:find(open, 1, true) then
        return 'f' .. open .. 'vi' .. open
      end
      return 'va' .. open .. 'V'
    end
  end
  map('n', '<leader>v(', select_ahead_or_around('('), { expr = true })
  map('n', '<leader>v[', select_ahead_or_around('['), { expr = true })
  map('n', '<leader>v<', select_ahead_or_around('<'), { expr = true })
end

map('n', '<leader>v"', 'vi"')
map('n', "<leader>v'", "vi'")

map('n', '<leader>y{', '<leader>v{jy<c-o>', { remap = true })
map('n', '<leader>Y{', '<leader>v{oky<c-o>', { remap = true })
map('n', '<leader>y(', '<leader>v(y', { remap = true })
map('n', '<leader>y[', '<leader>v[y', { remap = true })
map('n', '<leader>y<', '<leader>v<y', { remap = true })
map('n', '<leader>y"', '<leader>v"y', { remap = true })
map('n', "<leader>y'", "<leader>v'y", { remap = true })

map('n', '<leader>d{', '<leader>v{jd', { remap = true })
map('n', '<leader>D{', '<leader>v{okd', { remap = true })
map('n', '<leader>d(', '<leader>v(d', { remap = true })
map('n', '<leader>d[', '<leader>v[d', { remap = true })
map('n', '<leader>d<', '<leader>v<d', { remap = true })
map('n', '<leader>d"', '<leader>v"d', { remap = true })
map('n', "<leader>d'", "<leader>v'd", { remap = true })

-- Store relative line number jumps in the jumplist if they exceed a threshold
map('', 'j', function()
  return (vim.v.count > 5 and ("m'" .. vim.v.count) or '') .. 'j'
end, { expr = true })
map('', 'k', function()
  return (vim.v.count > 5 and ("m'" .. vim.v.count) or '') .. 'k'
end, { expr = true })

-- Other
map('n', '<leader>m', '`')

map('n', '<leader>J', 'J')

map('n', '<leader>H', 'H')
map('n', '<leader>L', 'L')
map('n', '<leader>M', 'M')

if novscode then
  map('', '<leader>z', 'zt23k23j')
end

map('', '<leader>Z', 'zt16k16j')
