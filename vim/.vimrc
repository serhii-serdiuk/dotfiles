set nocompatible
set encoding=utf-8

syntax on

set expandtab      " Use spaces instead of tab
set tabstop=4      " Width of tab character
set shiftwidth=4   " Determines whitespace amount used for indentation
set autoindent
set textwidth=120
set listchars=eol:$

set showtabline=2  " Always display the tabline, even if there is only one tab
set laststatus=2   " Always display the statusline in all windows
set noshowmode     " Hide the default mode text (e.g. -- INSERT -- below the statusline)
set t_Co=256       " Use 256 colours (use this setting only if your terminal supports 256 colours)

set number
set relativenumber
set cursorline
set mouse=a
set ttymouse=sgr

set foldenable
set foldtext=s:foldtext()
set fillchars=vert:\|,fold:·,eob:~
" set fillchars=vert:┃,fold:·,eob:~
set foldlevelstart=99

set hlsearch
set incsearch
set ignorecase
set smartcase
set wildignorecase

set matchpairs+=<:>
set iskeyword-=#

set hidden      " Do not keep unlisted buffers
set wildmenu    " Enable enhanced command-line completion menu
set showcmd     " Show partially typed commands in status line
set showmatch   " Show matching brackets
set splitright
set splitbelow

set ttimeout
set ttimeoutlen=50

" set modifiable

" Basic mappings
inoremap jj <esc>

" noremap <c-d> <c-d>zz
" noremap <c-u> <c-u>zz
" noremap <c-d> <c-d>M
" noremap <c-u> <c-u>M
" noremap <c-d> <c-d>2k
" noremap <c-u> <c-u>j
noremap <c-e> 10<c-e>
noremap <c-y> 10<c-y>
noremap zl 5zl
noremap zh 5zh

noremap J }
noremap K {

noremap M @@

noremap U <c-r>

inoremap <c-d> <c-o>x
inoremap <c-t> <c-o>x<c-o>p<c-o>h
inoremap <c-j> <c-o>dd<c-o>p
inoremap <c-k> <c-o>dd<c-o>k<c-o>P

vnoremap <c-j> dp
vnoremap <c-k> dkP

" TODO: doesn't work for some reason, check with another terminal
" inoremap <c-,> <c-d>
" inoremap <c-.> <c-t>

" Built-in completion
inoremap <c-n> <c-x><c-n>
inoremap <c-p> <c-x><c-p>
inoremap <c-l> <c-x><c-l>
inoremap <c-f> <c-x><c-f>

cabbrev h vert h
cabbrev hh help

" Mappings which use Alt/Meta key
" Define Alt sequences as terminal key codes (uses ttimeoutlen, not timeoutlen)
" This avoids the 1-second ESC delay caused by user-mapping approach
for i in range(97,122)
  let c = nr2char(i)
  exec "set <m-" . c . ">=\e" . c
endfor
exec "set <m-,>=\e,"
exec "set <m-.>=\e."

" Pass Alt key sequences through to the terminal job in :terminal buffers
for i in range(97,122)
  let c = nr2char(i)
  exec "tnoremap <m-" . c . "> <Esc>" . c
endfor
exec "tnoremap <m-,> <Esc>,"
exec "tnoremap <m-.> <Esc>."

nnoremap <m-j> +
nnoremap <m-k> -

inoremap <m-j> <down>
inoremap <m-k> <up>
inoremap <m-b> <left>
inoremap <m-f> <right>
imap <m-h> <c-o>b
imap <m-l> <c-o>w
imap <m-w> <c-o>db
imap <m-d> <c-o>dw
inoremap <m-p> <c-r>"
inoremap <m-u> <c-o>u
inoremap <m-m> <cr>

" Mappings which use <leader> key which creates a separate namespace
nnoremap <space> <nop>
vnoremap <space> <nop>
let mapleader = " "

" https://vim.fandom.com/wiki/Best_Vim_Tips#Make_it_easy_to_update/reload_vimrc
nnoremap <silent> <leader>co :edit $MYVIMRC<cr>
nnoremap <silent> <leader>cr :source $MYVIMRC<cr>:nohl<cr>

" nnoremap <silent> <leader>w :silent! w<cr>
nnoremap <leader>w :w<cr>
nnoremap <leader>q :q<cr>
nnoremap <leader>Q :qa!<cr>
nnoremap <leader>cq :cq<cr>
nnoremap <silent> <c-s> :silent! w<cr>
inoremap <silent> <c-s> <esc>:silent! w<cr>
nnoremap <c-q> :q<cr>

nnoremap <leader>S :shell<cr>
autocmd TerminalOpen * tnoremap <buffer> <c-w>S <c-w>:shell<cr>
let g:initial_cwd = getcwd(-1)
nnoremap <leader>rdl :execute 'lcd' fnameescape(g:initial_cwd)<cr>
nnoremap <leader>rdt :execute 'tcd' fnameescape(g:initial_cwd)<cr>
command -nargs=1 -complete=dir ChangeGlobalWorkingDir cd <args> | call ResetLocalDirsToGlobal()
nnoremap <leader>rdg :ChangeGlobalWorkingDir <c-r>=expand(g:initial_cwd) . '/'<cr>
nnoremap <leader>cdl :lcd <c-r>=expand('%:.:h') . '/'<cr>
nnoremap <leader>cdt :tcd <c-r>=expand('%:.:h') . '/'<cr>
nnoremap <leader>cdg :ChangeGlobalWorkingDir <c-r>=expand('%:.:h') . '/'<cr>
nnoremap <leader>e :e <c-r>=expand('%:.:h') . '/'<cr>
" https://vimways.org/2019/vim-and-the-working-directory/

" Buffers
nnoremap <leader>bn :bn<cr>
nnoremap <leader>bp :bp<cr>
nnoremap <leader>bb :ls<cr>:b<space>
nnoremap <leader>bl :ls!<cr>:b<space>
nnoremap <leader>bd :bd<cr>
nnoremap <leader>bw :ls!<cr>:bwipe<space>
nnoremap <expr> <leader>x (bufnr('#') != -1 && buflisted(bufnr('#'))) ? "\<c-^>:bd #\<cr>" : ":bd\<cr>"
nnoremap <expr> <leader>X (bufnr('#') != -1 && buflisted(bufnr('#'))) ? "\<c-^>:bwipe #\<cr>" : ":bwipe\<cr>"

" tnoremap <buffer> <c-w>bb <c-w>:ls<cr>:b<space>
" tnoremap <buffer> <c-w>bl <c-w>:ls!<cr>:b<space>

nnoremap <c-@> <c-^>
tnoremap <c-@> <c-w>:b#<cr>

" Split windows
nnoremap <leader>ss :split<cr>
nnoremap <leader>vv :vsplit<cr>
nnoremap <leader>nn :vnew<cr>
nnoremap <leader>nh :new<cr>:res -10<cr>
nnoremap <leader>nt :tab new<cr>
" nnoremap <leader>\ :split<cr>
" nnoremap <leader>| :vsplit<cr>
nnoremap <leader>h <c-w>h
nnoremap <leader>j <c-w>j
nnoremap <leader>k <c-w>k
nnoremap <leader>l <c-w>l
nnoremap <leader>; <c-w><c-p>
nnoremap <c-w><c-w> <c-w><c-p>

nnoremap <c-w>0 <c-w><c-t>
nnoremap <c-w>9 <c-w><c-b>
nnoremap <c-w>1 2<c-w><c-w>
nnoremap <c-w>2 3<c-w><c-w>
nnoremap <c-w>3 4<c-w><c-w>
nnoremap <c-w>4 5<c-w><c-w>

autocmd TerminalOpen * tnoremap <buffer> <c-w><c-w> <c-w><c-p>
autocmd TerminalOpen * tnoremap <buffer> <c-w>0 <c-w><c-t>
autocmd TerminalOpen * tnoremap <buffer> <c-w>9 <c-w><c-b>
autocmd TerminalOpen * tnoremap <buffer> <c-w>1 <c-w>N2<c-w><c-w><c-w><c-p>i<c-w><c-p>
autocmd TerminalOpen * tnoremap <buffer> <c-w>2 <c-w>N3<c-w><c-w><c-w><c-p>i<c-w><c-p>
autocmd TerminalOpen * tnoremap <buffer> <c-w>3 <c-w>N4<c-w><c-w><c-w><c-p>i<c-w><c-p>
autocmd TerminalOpen * tnoremap <buffer> <c-w>4 <c-w>N5<c-w><c-w><c-w><c-p>i<c-w><c-p>

" Resizing
nnoremap <leader>- :res -10<cr>
nnoremap <leader>+ :res +10<cr>
nnoremap <leader>< :vert res -10<cr>
nnoremap <leader>> :vert res +10<cr>
nnoremap <leader>= <c-w>=

autocmd TerminalOpen * tnoremap <buffer> <c-w>- <c-w>:res -10<cr>
autocmd TerminalOpen * tnoremap <buffer> <c-w>+ <c-w>:res +10<cr>
autocmd TerminalOpen * tnoremap <buffer> <c-w>< <c-w>:vert res -10<cr>
autocmd TerminalOpen * tnoremap <buffer> <c-w>> <c-w>:vert res +10<cr>

" Rotating
nnoremap <c-w><c-r> <c-w><c-x>
autocmd TerminalOpen * tnoremap <buffer> <c-w><c-r> <c-w><c-x>

" Tab pages
nnoremap <c-t> :tab split<cr>
nnoremap <leader>tnc :tab split<cr>
nnoremap <leader>tnp :-tab split<cr>
nnoremap <leader>tnn :+tab split<cr>
nnoremap <leader>tnf :0tab split<cr>
nnoremap <leader>tnl :$tab split<cr>
nnoremap <leader>tn0 :0tab split<cr>
nnoremap <leader>tn9 :$tab split<cr>
nnoremap <leader>tne :tab new<cr>
nnoremap <leader>tnw <c-w>T

" tnoremap <buffer> <c-w>tnc <c-w>:tab split<cr>
" tnoremap <buffer> <c-w>tnp <c-w>:-tab split<cr>
" tnoremap <buffer> <c-w>tnn <c-w>:+tab split<cr>
" tnoremap <buffer> <c-w>tnf <c-w>:0tab split<cr>
" tnoremap <buffer> <c-w>tnl <c-w>:$tab split<cr>
" tnoremap <buffer> <c-w>tn0 <c-w>:0tab split<cr>
" tnoremap <buffer> <c-w>tn9 <c-w>:$tab split<cr>
" tnoremap <buffer> <c-w>tne <c-w>:tab new<cr>
" tnoremap <buffer> <c-w>tnw <c-w>T

" Switching
nnoremap <silent> H :tabp<cr>
nnoremap <silent> L :tabn<cr>
" TODO: this brokes some Ctrl related mappings, try on different setup of terminal+Vim
" nnoremap <c-tab> g<tab>
" tnoremap <c-tab> <c-w>g<tab>
nnoremap <leader><tab> g<tab>
autocmd TerminalOpen * tnoremap <buffer> <c-w><c-@> <c-w>g<tab>
nnoremap <c-w><c-@> g<tab>

nnoremap g0 :tabn 1<cr>
nnoremap g9 :tabn $<cr>
nnoremap <leader>0 :tabn 1<cr>
nnoremap <leader>1 :tabn 1<cr>
nnoremap <leader>2 :tabn 2<cr>
nnoremap <leader>3 :tabn 3<cr>
nnoremap <leader>4 :tabn 4<cr>
nnoremap <leader>5 :tabn 5<cr>
nnoremap <leader>6 :tabn 6<cr>
nnoremap <leader>7 :tabn 7<cr>
nnoremap <leader>8 :tabn 8<cr>
nnoremap <leader>9 :tabn $<cr>

" tnoremap <buffer> <c-w>0 <c-w>:tabn 1<cr>
" tnoremap <buffer> <c-w>1 <c-w>:tabn 1<cr>
" tnoremap <buffer> <c-w>2 <c-w>:tabn 2<cr>
" tnoremap <buffer> <c-w>3 <c-w>:tabn 3<cr>
" tnoremap <buffer> <c-w>4 <c-w>:tabn 4<cr>
" tnoremap <buffer> <c-w>5 <c-w>:tabn 5<cr>
" tnoremap <buffer> <c-w>6 <c-w>:tabn 6<cr>
" tnoremap <buffer> <c-w>7 <c-w>:tabn 7<cr>
" tnoremap <buffer> <c-w>8 <c-w>:tabn 8<cr>
" tnoremap <buffer> <c-w>9 <c-w>:tabn $<cr>

" Moving
nnoremap <m-,> :tabm -<cr>
nnoremap <m-.> :tabm +<cr>
nnoremap <leader>tmm :tabm #<cr>
nnoremap <leader>tmf :tabm 0<cr>
nnoremap <leader>tml :tabm $<cr>
nnoremap <leader>tm0 :tabm 0<cr>
nnoremap <leader>tm9 :tabm $<cr>

" tnoremap <buffer> <c-w>{ <c-w>:tabm -<cr>
" tnoremap <buffer> <c-w>} <c-w>:tabm +<cr>
" tnoremap <buffer> <c-w>tmm <c-w>:tabm #<cr>
" tnoremap <buffer> <c-w>tmf <c-w>:tabm 0<cr>
" tnoremap <buffer> <c-w>tml <c-w>:tabm $<cr>
" tnoremap <buffer> <c-w>tm0 <c-w>:tabm 0<cr>
" tnoremap <buffer> <c-w>tm9 <c-w>:tabm $<cr>

" noremap 9 $

" Terminal
nnoremap <leader>T :terminal<cr><c-w><c-p>:q<cr>
nnoremap <leader>tt :vnew<cr>:terminal<cr><c-w><c-p>:bwipe<cr><c-w><c-h><c-w><c-p>
nnoremap <leader>th :terminal<cr><c-w>:res -10<cr>
autocmd TerminalOpen * tnoremap <buffer> <c-w>tt <c-w>:vnew<cr>:terminal<cr><c-w><c-p>:bwipe<cr><c-w><c-h><c-w><c-p>
autocmd TerminalOpen * tnoremap <buffer> <c-w>th <c-w>:terminal<cr><c-w>:res -10<cr>
autocmd TerminalOpen * tmap <buffer> <c-w>r <c-w>tt<c-w><c-w><c-d><c-w><c-w>
nnoremap <c-w>tt <c-w>:vnew<cr>:terminal<cr><c-w><c-p>:bwipe<cr><c-w><c-h><c-w><c-p>
nmap <c-w>r <c-w>tt<c-w><c-w>i<c-d><c-w><c-w>

" Terminal only mappings
tnoremap <c-n> <c-w>N:vert res +6<cr>ggG
nnoremap <expr> i &buftype ==# 'terminal' ? ':vert res -6<cr>i' : 'i'
autocmd TerminalOpen * tnoremap <buffer> <c-w>m <c-w>Nmgi
autocmd TerminalOpen * tnoremap <buffer> <c-w><c-m> <c-w>Nmgi
autocmd TerminalOpen * tnoremap <buffer> <c-w>pp <c-w>"0
autocmd TerminalOpen * tnoremap <buffer> <c-w>py <c-w>"0
autocmd TerminalOpen * tnoremap <buffer> <c-w>pc <c-w>"+

" Diff
nnoremap <leader>df :NERDTreeClose<cr>:windo diffthis<cr>
nnoremap <leader>dx :windo diffoff<cr>:NERDTreeFind<cr><c-w>=<c-w><c-p>
nnoremap <leader>du :diffupdate<cr>

" Workaround to make mappings work in Cursor
if !exists('g:vscode')
  nnoremap <silent> <expr> J &diff ? ']c' : ':keepjumps normal! }<cr>'
  nnoremap <silent> <expr> K &diff ? '[c' : ':keepjumps normal! {<cr>'
endif
" vnoremap <silent> J :keepjumps visual! }<cr>
" vnoremap <silent> K :keepjumps visual! {<cr>

" For using as git mergetool
nnoremap dgh :diffget 1<cr>
nnoremap dgm :diffget 2<cr>
nnoremap <expr> dgl winnr('$') > 2 ? ':diffget 3<cr>' : ':diffget 2<cr>'
nnoremap <expr> dgo winnr('$') == 2 ? ':diffget<cr>' : ':echom "dgo: requires exactly 2 windows"<cr>'
" https://www.youtube.com/watch?v=iLViiiEP4mE

" Folding
noremap <leader>fe zi
noremap <leader>fu zx

noremap <leader>fl zr
noremap <leader>fL zR
noremap <leader>fh zm
noremap <leader>fH zM
" For C++ class methods definitions inside namespace (in *.cpp file)
noremap <leader>fn :set foldlevel=1<cr>

noremap <leader>fo zo
noremap <leader>fO zO
noremap <leader>fc zc
noremap <leader>fC zC

noremap <leader>ft za
noremap <leader>fT zA
" nnoremap <s-@> za
" nnoremap <tab> za
" nnoremap <s-tab> zA
noremap <s-tab> za

noremap <leader>fj ]z
noremap <leader>fk [z
nnoremap <leader>fv j[zV]z

" Wrapping, formatting and changing the case
noremap <leader>tw :set wrap!<cr>
nnoremap <leader>tc g~iw

" Select, copy and paste to the end of line
nnoremap Y y$
nnoremap <leader>V v$h
nmap <leader>pr <leader>V<leader>py
nmap <leader>pp <leader>V<leader>py
nmap <leader>PP <leader>V<leader>py
nmap <leader><leader>p <leader>V<leader>py

" Select, copy/cut and past the word (including mappings from vim-wordmotion)
nnoremap <leader>vw viw
nnoremap <leader>ve ve
nnoremap <leader>vW viW

nmap yw yiw
nnoremap <leader>yw yiw
nnoremap <leader>ye ye
nnoremap <leader>yW yiW

nmap cw ciw
nnoremap <leader>cw ciw
nnoremap <leader>ce ce
nnoremap <leader>cW ciW

nmap dw daw
nnoremap <leader>dw daw
nnoremap <leader>de de
nnoremap <leader>dW daW

nnoremap <leader>pw viw"0pgvy
nmap <leader>pW viw"0p

" Comment and duplicate lines for debugging purposes
nmap <leader>dl yygccp
vmap <leader>dl ygvgcgv<c-c>p

" Searching and replacing a word (using *)
" nnoremap * viw"hy*
nnoremap * viw"hy/<c-r>h<cr>
" TODO: try to use | as separator instead of /
vnoremap * "hy/<c-r>h<cr>
vnoremap # "hy?<c-r>h<cr>
" nmap <leader>* viW*
" nmap <leader># viW#
" NOTE: These two below only make sense together with plugin chaoren/vim-wordmotion
nmap <leader>* viw*
nmap <leader># viw#

map <leader>sw *N
nmap <leader>sW <leader>*N

nmap c* *Ncgn
vmap <leader>c* *Ncgn
nmap <leader>c* <leader>*Ncgn

" nnoremap <leader>rw *N:%s///gc<left><left><left>
vmap <leader>rw <leader>sw:%s///gc<left><left><left>
nmap <leader>rW <leader>sW:%s///gc<left><left><left>

" Search commands
" nnoremap <leader>ss /
" vnoremap <leader>ss o<esc>/\%V
vnoremap / o<esc>/\%V
" nnoremap <leader>sp //
vnoremap <leader>sp //<cr>
nnoremap <leader>sc q/
nnoremap <leader>sy /<c-r>0<cr>
" nnoremap <leader>sy q/p<cr>
nnoremap <leader>sv /\%V

" Search word at cursor position in different scopes
" nmap <leader>sip ywvip<esc>j<leader>sy
nnoremap <leader>sip viw"hyvipo<esc>/\%V<c-r>h
nnoremap <leader>sib viw"hyvibo<esc>/\%V<c-r>h
nnoremap <leader>si( viw"hyvi(o<esc>/\%V<c-r>h
nnoremap <leader>si{ viw"hyvi{o<esc>/\%V<c-r>h
nnoremap <leader>si[ viw"hyvi[o<esc>/\%V<c-r>h

" Replace commands
nnoremap <leader>rr :%s//gc<left><left><left>
vnoremap <leader>rr :s/\v/g<left><left>
nnoremap <leader>rp :%s///gc<left><left><left>
vnoremap <leader>rp :s/\v//g<left><left>
" vnoremap <leader>rp :s///g<left><left>
nnoremap <leader>ry :%s/\v<c-r>0//gc<left><left><left>
vnoremap <leader>ry :s/\v<c-r>0//g<left><left>
nnoremap <leader>rv :'<,'>s/\v/g<left><left>

" Replace word at cursor position in different scopes
nnoremap <leader>rip viw"hyvip:s/\v<c-r>h//g<left><left>
nnoremap <leader>rib viw"hyvib:s/\v<c-r>h//g<left><left>
nnoremap <leader>ri( viw"hyvi(:s/\v<c-r>h//g<left><left>
nnoremap <leader>ri{ viw"hyvi{:s/\v<c-r>h//g<left><left>
nnoremap <leader>ri[ viw"hyvi[:s/\v<c-r>h//g<left><left>

" Add text to the beginning/end of line with word under cursor
nnoremap <leader>I viw"hy:g/<c-r>h/norm I
nnoremap <leader>A viw"hy:g/<c-r>h/norm A
vnoremap <leader>I :g/<c-r>0/norm I
vnoremap <leader>A :g/<c-r>0/norm A

" nnoremap <leader>ii viw"hy:g/<c-r>h/norm I
" nnoremap <leader>ia viw"hy:g/<c-r>h/norm A
" vnoremap <leader>ii :g/<c-r>0/norm I
" vnoremap <leader>ia :g/<c-r>0/norm A

nnoremap <leader>iip viw"hyvip:g/<c-r>h/norm I
nnoremap <leader>iib viw"hyvib:g/<c-r>h/norm I
nnoremap <leader>ii( viw"hyvi(:g/<c-r>h/norm I
nnoremap <leader>ii{ viw"hyvi{:g/<c-r>h/norm I
nnoremap <leader>ii[ viw"hyvi[:g/<c-r>h/norm I

nnoremap <leader>aip viw"hyvip:g/<c-r>h/norm A
nnoremap <leader>aib viw"hyvib:g/<c-r>h/norm A
nnoremap <leader>ai( viw"hyvi(:g/<c-r>h/norm A
nnoremap <leader>ai{ viw"hyvi{:g/<c-r>h/norm A
nnoremap <leader>ai[ viw"hyvi[:g/<c-r>h/norm A

" Repeat last command
noremap <leader>: @:

" Find next character and repeat action
noremap <leader>.f :let @z=';.'<cr>@z

" Repeat action on next line
noremap <leader>.j :let @z='j.'<cr>@z
noremap <leader>.+ :let @z='+.'<cr>@z
noremap <leader>.. :let @z='+.'<cr>@z
noremap <leader>.c :let @z='gcc+'<cr>@z

" Repeat the last dot action on all visually selected lines
" NOTE: not sure it works correctly
" vnoremap . :norm. <cr>

" arglist, vimgrep and quicklist
nnoremap <leader>al :args<cr>
nnoremap <leader>ac :arg<space>
" nnoremap <leader>aa :argadd<space>
nnoremap <leader>ad :argdo<space>
nnoremap <leader>ar :argdelete<space>
nnoremap <leader>vg :vimgrep // ##<cr>:copen<cr>
nnoremap <c-j> :cnext<cr>zz
nnoremap <c-k> :cprev<cr>zz
nnoremap co :copen<cr>
nnoremap cx :cclose<cr>
" TODO: create function which takes replace word as argument
" nnoremap <leader>clr :cdo s//text/c | update
" nnoremap <leader>clr :cdo s///c | update<left><left><left><left><left><left><left><left><left><left><left>
" nnoremap <leader>clr :cdo s///c<left><left>
nnoremap <leader>rcl :cdo s///c<left><left>
" :cdo norm @q
" nnoremap <leader>cld :cdo! norm dd
" nnoremap <leader>clm :cdo! norm @

" Copy current file path/name
" TODO: replace yank register 0 with clipboard register + everywhere
" Relative path
noremap <leader>yr :let @+=@%<cr>
if !exists('g:vscode')
  noremap <leader>yr :let @0=@%<cr>
endif
" Absolute path
noremap <leader>yp :let @0=expand('%:p')<cr>
" Relative dir
noremap <leader>yd :let @0=expand('%:h')<cr>
" Name
noremap <leader>yn :let @0=expand('%:t')<cr>
" Name without extention
noremap <leader>y. :let @0=expand('%:t:r')<cr>

" Copy/paste using different registers
" Synchronization between yank register and clipboard
vnoremap <leader>yc "+y
nnoremap <leader>yc :let @+=@0<cr>
noremap <leader>cy :let @0=@+<cr>
if !exists('g:vscode')
  nnoremap <leader>yc :call system('wl-copy', @0)<cr>
  noremap <leader>cy :let @0=system('wl-paste --no-newline')<cr>
endif

" Pasting from the different registers
map <leader>pc "+p
map <leader>Pc "+P

noremap <leader>py "0p
noremap <leader>Py "0P

noremap <leader>pd "-p
noremap <leader>Pd "-P

noremap <leader>ps "/p
noremap <leader>Ps "/P

noremap <leader>ph "hp
noremap <leader>Ph "hP

" Check registers' values
nnoremap <leader>' :reg<cr>
autocmd TerminalOpen * tnoremap <buffer> <c-w>' <c-w>:reg<cr>

" Navigation via brackets/braces
noremap ( [[-%^
noremap ) ]]+

map { F{
map } f{

map <leader>( {^
map <leader>) }+
if !exists('g:vscode')
  map <leader>( :let @z='{^'<cr>@z
  map <leader>) :let @z='}+'<cr>@z
endif

map <leader>{ {+
map <leader>} f}-

" Commented mappings here work in Vim by default but doesn't work in Kate, should be added manually
" TODO: check how they work in Qt Creator
" nnoremap [{ va{<esc>%
" nnoremap ]} va{<esc>
" nnoremap [( va(<esc>%
" nnoremap ]) va(<esc>
nnoremap [< va<<esc>%
nnoremap ]> va<<esc>

nnoremap <expr> vi{ <sid>brace_select('vi', '{')
nnoremap <expr> va{ <sid>brace_select('va', '{')
nnoremap <expr> vi< <sid>brace_select('vi', '<')
nnoremap <expr> va< <sid>brace_select('va', '<')

nnoremap va' vi'ohol
nnoremap va" vi"ohol

nnoremap <leader>v{ $va{V
nnoremap <leader>v( va(V
nnoremap <leader>v[ va[V
nnoremap <leader>v< va<V
if !exists('g:vscode')
  nnoremap <expr> <leader>v( getline('.')[col('.'):] =~ '(' ? 'f(vi(' : 'va(V'
  nnoremap <expr> <leader>v[ getline('.')[col('.'):] =~ '[' ? 'f[vi[' : 'va[V'
  nnoremap <expr> <leader>v< getline('.')[col('.'):] =~ '<' ? 'f<vi<' : 'va<V'
endif

nnoremap <leader>v" vi"
nnoremap <leader>v' vi'

nmap <leader>y{ <leader>v{jy<c-o>
nmap <leader>Y{ <leader>v{oky<c-o>
nmap <leader>y( <leader>v(y
nmap <leader>y[ <leader>v[y
nmap <leader>y< <leader>v<y
nmap <leader>y" <leader>v"y
nmap <leader>y' <leader>v'y

nmap <leader>d{ <leader>v{jd
nmap <leader>D{ <leader>v{okd
nmap <leader>d( <leader>v(d
nmap <leader>d[ <leader>v[d
nmap <leader>d< <leader>v<d
nmap <leader>d" <leader>v"d
nmap <leader>d' <leader>v'd

" Commented mappings here work in Vim by default but doesn't work in Kate, should be added manually
" Also they don't work in Qt Creator and there is no way to add them,
" uncommenting in this config leads to broken behavior in Vim (stops working inside parentheses), tested only with '('

" nnoremap vi( f(vi(
" nnoremap yi( f(yi(
" nnoremap di( f(di(
" nnoremap ci( f(ci(
"
" nnoremap va( f(va(
" nnoremap ya( f(ya(
" nnoremap da( f(da(
" nnoremap ca( f(ca(
"
" nnoremap vib f(vib
" nnoremap yib f(yib
" nnoremap dib f(dib
" nnoremap cib f(cib
"
" nnoremap vab f(vab
" nnoremap yab f(yab
" nnoremap dab f(dab
" nnoremap cab f(cab

" nnoremap vi[ f[vi[
" nnoremap yi[ f[yi[
" nnoremap di[ f[di[
" nnoremap ci[ f[ci[
"
" nnoremap va[ f[va[
" nnoremap ya[ f[ya[
" nnoremap da[ f[da[
" nnoremap ca[ f[ca[

" nnoremap vi" f"vi"
" nnoremap yi" f"yi"
" nnoremap di" f"di"
" nnoremap ci" f"ci"
"
" nnoremap va" f"va"
" nnoremap ya" f"ya"
" nnoremap da" f"da"
" nnoremap ca" f"ca"

" TODO: These work in Vim only partialy (inside angle brackets), uncommenting breaks default behavior
" nnoremap vi< f<vi<
" nnoremap yi< f<yi<
" nnoremap di< f<di<
" nnoremap ci< f<ci<
"
" These don't work in Kate after adding them manually as the ones above for some reason
" nnoremap va< f<va<
" nnoremap ya< f<ya<
" nnoremap da< f<da<
" nnoremap ca< f<ca<

" Store relative line number jumps in the jumplist if they exceed a threshold
noremap <expr> j (v:count > 5 ? "m'" . v:count : '') . 'j'
noremap <expr> k (v:count > 5 ? "m'" . v:count : '') . 'k'

" Other
" nnoremap <leader>m `mzz
nnoremap <leader>m `

nnoremap <leader>J J

nnoremap <leader>H H
nnoremap <leader>L L
nnoremap <leader>M M

if !exists('g:vscode')
  noremap <leader>z zt23k23j
endif

noremap <leader>Z zt16k16j

" Install vim-plug if not installed and the plugins
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugins
filetype off

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

" Wayland clipboard support
Plug 'jasonccox/vim-wayland-clipboard'

" Fuzzy find everything
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Manage files
Plug 'preservim/nerdtree'
Plug 'francoiscabrol/ranger.vim'
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

" Language specific
" Plug 'nvie/vim-flake8'

" Git integration
" Plug 'tpope/vim-fugitive'
" Plug 'airblade/vim-gitgutter'

" Writing and note taking
" Plug 'vimwiki/vimwiki'
Plug 'junegunn/goyo.vim'
" Plug 'junegunn/limelight.vim'

" Status/Tabline
Plug 'itchyny/lightline.vim'
Plug 'maximbaz/lightline-ale'
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'

" Colorschemes
Plug 'dracula/vim', { 'as': 'dracula' }
" Plug 'catppuccin/nvim', { 'as': 'catppuccin' }  " requires vim >= 9
" Plug 'joshdick/onedark.vim'
" Plug 'ayu-theme/ayu-vim'
" Plug 'morhetz/gruvbox'

" NOTE: no need for Vim 9+
" Plug 'editorconfig/editorconfig-vim'

call plug#end()

filetype plugin indent on

" ===== vim-surround plugin
nmap ysw <leader>vwS

" ===== vim-easymotion plugin
" map <leader> <plug>(easymotion-prefix)
" nmap s <plug>(easymotion-s2)

" ===== vim-sneak plugin
map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T
let g:sneak#label = 1

augroup nerdtree_sneak
  autocmd!
  autocmd FileType nerdtree nmap <buffer> s <Plug>Sneak_s
  autocmd FileType nerdtree nmap <buffer> S <Plug>Sneak_S
  autocmd FileType nerdtree nmap <buffer> f <Plug>Sneak_f
augroup END

" ===== scalpel plugin
" Shorten :Scalpel command name to :S
" let g:ScalpelCommand='S'
if !exists('g:vscode')
  " nmap <leader>rw <leader>sw:nohl<cr><plug>(Scalpel)
  nmap <leader>rw <leader>sw:nohl<cr>:Scalpel/<c-r>h//<left>
endif
" vmap <leader>rw <plug>(ScalpelVisual)

" ===== fzf plugin
" All files recursively from current working directory (pwd)
noremap <leader>oa :Files!<cr>
" Everything from current working directory except .gitignore
noremap <leader>og :GFiles! --cached --others --exclude-standard<cr>
noremap <leader>oo :GFiles! --cached --others --exclude-standard<cr>
" History of opened files (recent files)
noremap <leader>or :History<cr>
" noremap <leader>or :call fzf#vim#history(fzf#vim#with_preview({"options": ["--layout=reverse"]}), 0)<cr>
" Files from current file dir
command! -bang CurrentDir call fzf#vim#files(expand('%:p:h'), fzf#vim#with_preview(), <bang>0)
noremap <leader>oc :CurrentDir!<cr>
" Files recursively from /
command! -bang SystemRootDir call fzf#vim#files('/', fzf#vim#with_preview(), <bang>0)
noremap <leader>osr :SystemRootDir!<cr>
" Files recursively from /etc
command! -bang SystemConfigDir call fzf#vim#files('/etc', fzf#vim#with_preview(), <bang>0)
noremap <leader>osc :SystemConfigDir!<cr>
" Files recursively from /usr
command! -bang SystemUsrDir call fzf#vim#files('/usr', fzf#vim#with_preview(), <bang>0)
noremap <leader>osu :SystemUsrDir!<cr>
" Files recursively from /usr/share
command! -bang SystemShareDir call fzf#vim#files('/usr/share', fzf#vim#with_preview(), <bang>0)
noremap <leader>oss :SystemShareDir!<cr>
" Files recursively from /usr/share/applications
command! -bang SystemAppsDir call fzf#vim#files('/usr/share/applications', fzf#vim#with_preview(), <bang>0)
noremap <leader>osa :SystemAppsDir!<cr>
" Files recursively from /usr/lib
command! -bang SystemLibDir call fzf#vim#files('/usr/lib', fzf#vim#with_preview(), <bang>0)
noremap <leader>osl :SystemLibDir!<cr>
" Files recursively from /usr/lib/python3/dist-packages
command! -bang SystemPythonPackagesDir call fzf#vim#files('/usr/lib/python3/dist-packages', fzf#vim#with_preview(), <bang>0)
noremap <leader>osp :SystemPythonPackagesDir!<cr>
" Files recursively from /usr/lib/python3.8
command! -bang SystemPython38Dir call fzf#vim#files('/usr/lib/python3.8', fzf#vim#with_preview(), <bang>0)
" Files recursively from /usr/lib/python3.10
command! -bang SystemPython310Dir call fzf#vim#files('/usr/lib/python3.10', fzf#vim#with_preview(), <bang>0)
" Files recursively from $HOME dir
command! -bang UserHomeDir call fzf#vim#files('~', fzf#vim#with_preview(), <bang>0)
noremap <leader>ouh :UserHomeDir!<cr>
noremap <leader>oh :UserHomeDir!<cr>
" Files recursively from $HOME/.dotfiles dir
command! -bang UserDotfilesDir call fzf#vim#files('~/.dotfiles', fzf#vim#with_preview(), <bang>0)
noremap <leader>oud :UserDotfilesDir!<cr>
noremap <leader>od :UserDotfilesDir!<cr>
" Files recursively from $HOME/.config dir
command! -bang UserConfigDir call fzf#vim#files('~/.config', fzf#vim#with_preview(), <bang>0)
noremap <leader>ouc :UserConfigDir!<cr>
" Files recursively from $HOME/.config/konsave dir
command! -bang UserConfigKonsaveDir call fzf#vim#files('~/.config/konsave', fzf#vim#with_preview(), <bang>0)
noremap <leader>ouk :UserConfigKonsaveDir!<cr>
noremap <leader>ok :UserConfigKonsaveDir!<cr>
" Files recursively from $HOME/.vim dir
command! -bang UserVimDir call fzf#vim#files('~/.vim', fzf#vim#with_preview(), <bang>0)
noremap <leader>ouv :UserVimDir!<cr>
noremap <leader>ov :UserVimDir!<cr>
" Files recursively from $HOME/.shell-utils dir
command! -bang UserShellUtilsDir call fzf#vim#files('~/.shell-utils', fzf#vim#with_preview(), <bang>0)
noremap <leader>ouu :UserShellUtilsDir!<cr>
" Files recursively from $HOME/Projects/setup/setup-scripts dir
command! -bang UserSetupScriptsDir call fzf#vim#files('~/Projects/setup/setup-scripts', fzf#vim#with_preview(), <bang>0)
noremap <leader>ous :UserSetupScriptsDir!<cr>
" Files recursively from $HOME/Projects/setup/configs-backup dir
command! -bang UserConfigsBackupDir call fzf#vim#files('~/Projects/setup/configs-backup', fzf#vim#with_preview(), <bang>0)
noremap <leader>oub :UserConfigsBackupDir!<cr>
" Files recursively from $HOME/Documents/notes dir
command! -bang UserNotesDir call fzf#vim#files('~/Documents/notes', fzf#vim#with_preview(), <bang>0)
noremap <leader>oun :UserNotesDir!<cr>
noremap <leader>on :UserNotesDir!<cr>
" Files recursively from current project build dir
" command! -bang ProjectBuildDir call fzf#vim#files('build', fzf#vim#with_preview(), <bang>0)
command! -bang ProjectBuildDir call fzf#vim#files('build-craft', fzf#vim#with_preview(), <bang>0)
noremap <leader>opb :ProjectBuildDir!<cr>
" Files recursively from <path>/Frameworks/CraftRoot dir
command! -bang FrameworksCraftDir call fzf#vim#files('~/CraftRoot', fzf#vim#with_preview(), <bang>0)
noremap <leader>ofc :FrameworksCraftDir!<cr>

" Currently opened buffers
noremap <leader>ob :Buffers<cr>
noremap <leader>bo :Buffers<cr>

" Override Rg (ripgrep) command to also search hidden files (excluding .git)
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case --hidden --glob "!.git" ' . shellescape(<q-args>),
  \   1, fzf#vim#with_preview(), <bang>0)

" Grep recursively through all of the files in current dir via ripgrep
" NOTE: consider adding 's' prefix in case of conficts with mappings for Git
noremap <leader>ga :<c-w>Rg<cr>
noremap <leader>gg :<c-w>Rg<cr>
" Grep for word under cursor
nmap <leader>gw <leader>sw:exec "Rg ".expand('<cword>')<cr>
nmap <leader>gW <leader>sW:exec "Rg ".expand(getreg('/'))<cr>
vmap <leader>gw <leader>sw:exec "Rg ".expand(getreg('/'))<cr>
" Search through the content of the current buffer
noremap <leader>gc :BLines<cr>
" Search through the content of all opened buffers
noremap <leader>go :Lines<cr>

" Git status
noremap <leader>gs :GFiles!?<cr>
" Git commits for the current buffer; visual-select lines to track changes in the range
noremap <leader>glc :BCommits!<cr>
" Git commits (requires fugitive.vim)
noremap <leader>gla :Commits!<cr>
noremap <leader>gll :Commits!<cr>

" Search through the all commands
noremap <leader>ca :Commands<cr>
" Search through the commands history
noremap <leader>ch :History:<cr>
" noremap <leader>cc :History:<cr>
" Normal mode mappings
noremap <leader>cm :Maps<cr>

" Search through the history of search
noremap <leader>sh :History/<cr>

" Changelist across all open buffers
noremap <leader><leader>c :Changes<cr>
" Windows
noremap <leader><leader>vw :Windows<cr>
" All marks
noremap <leader><leader>ma :Marks<cr>
" Marks in the current buffer
noremap <leader><leader>mc :BMarks<cr>
noremap <leader><leader>mm :BMarks<cr>

" Adjust commands options
let g:fzf_vim = {}
let g:fzf_vim.files_options = '--layout=reverse'
let g:fzf_vim.gfiles_options = '--layout=reverse'
let g:fzf_vim.buffers_options = '--layout=reverse'
let g:fzf_vim.rg_options = '--layout=reverse'
let g:fzf_vim.blines_options = '--layout=reverse'
let g:fzf_vim.lines_options = '--layout=reverse'
let g:fzf_vim.commands_options = '--layout=reverse'
let g:fzf_vim.changes_options = '--layout=reverse'
let g:fzf_vim.windows_options = '--layout=reverse'
let g:fzf_vim.bmarks_options = '--layout=reverse'
let g:fzf_vim.marks_options = '--layout=reverse'
let g:fzf_vim.maps_options = '--layout=reverse'
let g:fzf_vim.bcommits_options = '--layout=reverse'
let g:fzf_vim.commits_options = '--layout=reverse'

" Build a quickfix list when multiple files are selected
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

" " Customize fzf colors to match your color scheme
" " - fzf#wrap translates this to a set of `--color` options
" let g:fzf_colors =
" \ { 'fg':      ['fg', 'Normal'],
"   \ 'bg':      ['bg', 'Normal'],
"   \ 'query':   ['fg', 'Normal'],
"   \ 'hl':      ['fg', 'Comment'],
"   \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
"   \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
"   \ 'hl+':     ['fg', 'Statement'],
"   \ 'info':    ['fg', 'PreProc'],
"   \ 'border':  ['fg', 'Ignore'],
"   \ 'prompt':  ['fg', 'Conditional'],
"   \ 'pointer': ['fg', 'Exception'],
"   \ 'marker':  ['fg', 'Keyword'],
"   \ 'spinner': ['fg', 'Label'],
"   \ 'header':  ['fg', 'Comment'] }

" " Map fzf colors to Vim scheme
" let g:fzf_colors = {
"     \ 'fg':      ['fg', 'Normal'],
"     \ 'bg':      ['bg', 'Normal'],
"     \ 'hl':      ['fg', 'Search'],
"     \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
"     \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
"     \ 'hl+':     ['fg', 'Visual'],
"     \ 'info':    ['fg', 'PreProc'],
"     \ 'border':  ['fg', 'StatusLineNC'],
"     \ 'prompt':  ['fg', 'Conditional'],
"     \ 'pointer': ['fg', 'Exception'],
"     \ 'marker':  ['fg', 'Keyword'],
"     \ 'spinner': ['fg', 'Label'],
"     \ 'header':  ['fg', 'Comment']
" \ }

" ===== nerdtree plugin
if !exists('g:vscode')
  " nnoremap <c-n> :NERDTree<cr><c-w>=
  " nnoremap <c-t> :NERDTreeToggle<cr><c-w>=
  " nnoremap <c-f> :NERDTreeFind<cr><c-w>=

  " Mirror the NERDTree before showing it. This makes it the same on all tabs.
  nnoremap <c-n> :NERDTreeMirror<cr>:NERDTreeFocus<cr><c-w>=
  nnoremap <c-f> :NERDTreeMirror<cr>:NERDTreeFocus<cr><c-w><c-p>:NERDTreeFind<cr><c-w>=
endif

let g:NERDTreeMapPreview = 'i'
let g:NERDTreeMapOpenSplit = '<leader>ss'
let g:NERDTreeMapOpenVSplit = '<leader>vv'
let g:NERDTreeWinSize=35
" let g:NERDTreeFileLines = 1

" Close the tab if NERDTree is the only window remaining in it.
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if winnr() == winnr('h') && bufname('#') =~ 'NERD_tree_' && bufname('%') !~ 'NERD_tree_' && winnr('$') > 1 |
  \ let buf=bufnr() | buffer# | execute "normal! \<c-w>wzz" | execute 'buffer'.buf | endif

" Open the existing NERDTree on each new tab.
" NOTE: causes not showing of Vim greeting screen on startup
" autocmd BufWinEnter * if &buftype != 'quickfix' && getcmdwintype() == '' | silent NERDTreeMirror | endif

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

" ===== ranger plugin
nnoremap <leader>dc :Ranger<cr>
" nnoremap <leader>dw :RangerWorkingDirectory<cr>
nnoremap <leader>dd :RangerWorkingDirectory<cr>

let g:ranger_map_keys = 0
" let g:ranger_command_override = 'ranger --cmd "set show_hidden=true"'

" ===== vim-renamer plugin
nnoremap <leader>br :Renamer<cr>
nnoremap <leader>rx :Ren<cr>

let g:RenamerShowHidden = 1

" ===== vim-lsp plugin
function! s:lsp_scroll_or(amount, fallback) abort
  if exists('*popup_list') && !empty(popup_list())
    call lsp#scroll(a:amount)
    return "\<Ignore>"
  endif
  return a:fallback
endfunction

function! s:on_lsp_buffer_enabled() abort
  set foldmethod=expr
    \ foldexpr=lsp#ui#vim#folding#foldexpr()
    " \ foldtext=lsp#ui#vim#folding#foldtext()
  " setlocal foldlevelstart=99

  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes
  if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif

  " TODO: try to use nnoremap
  nmap <buffer> gh <plug>(lsp-hover)
  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> gpd <plug>(lsp-peek-definition)
  nmap <buffer> gD <plug>(lsp-declaration)
  nmap <buffer> gpD <plug>(lsp-peek-declaration)
  nmap <buffer> gs <plug>(lsp-document-symbol)
  nmap <buffer> go <plug>(lsp-document-symbol-search)
  nmap <buffer> gO <plug>(lsp-workspace-symbol-search)
  nmap <buffer> gr <plug>(lsp-references)
  nmap <buffer> gI <plug>(lsp-implementation)
  nmap <buffer> gpI <plug>(lsp-peek-implementation)
  nmap <buffer> gt <plug>(lsp-type-definition)
  nmap <buffer> gy <plug>(lsp-type-definition)
  nmap <buffer> gpt <plug>(lsp-peek-type-definition)
  nmap <buffer> gpy <plug>(lsp-peek-type-definition)
  nnoremap <buffer> <expr> <m-j> <sid>lsp_scroll_or(+4, '+')
  nnoremap <buffer> <expr> <m-k> <sid>lsp_scroll_or(-4, '-')
  " nnoremap <buffer> <expr> <m-j> <sid>lsp_scroll_or(+4, ':m .+1<cr>')
  " nnoremap <buffer> <expr> <m-k> <sid>lsp_scroll_or(-4, ':m .-2<cr>')

  nmap <buffer> <leader>cc <plug>(lsp-switch-source-header)
  nmap <buffer> <leader>rn <plug>(lsp-rename)
  nmap <buffer> <leader>R <plug>(lsp-rename)
  nmap <buffer> <leader>ff <plug>(lsp-document-format)
  map <buffer> <leader>fr <plug>(lsp-document-range-format)
  " TODO: check functions below
  nmap <buffer> <leader>aa <plug>(lsp-code-action-float)
  nmap <buffer> <leader>ap <plug>(lsp-code-action-preview)
  nmap <buffer> <leader>cl <plug>(lsp-code-lens)

  let g:lsp_format_sync_timeout = 1000
  autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
endfunction

augroup lsp_setup
  au!
  " call s:on_lsp_buffer_enabled only for languages that has the server registered
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" ===== ale plugin
let g:ale_virtualtext_cursor = 'current'

let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_enter = 0
let g:ale_lint_on_save = 0

let g:ale_fixers = {
  \   '*': ['remove_trailing_lines', 'trim_whitespace'],
  \ }
" let g:ale_fixers = {
"   \   '*': ['remove_trailing_lines', 'trim_whitespace'],
"   \   'cpp': ['astyle', 'clang-format', 'clangtidy', 'uncrustify'],
"   \   'javascript': ['eslint'],
"   \ }
let g:ale_fix_on_save = 1

let g:ale_c_build_dir_names = ['build', 'build-craft']

" nmap <silent> [g <plug>(ale_previous_wrap)
" nmap <silent> ]g <plug>(ale_next_wrap)
nnoremap [g :lprev<cr>zz
nnoremap ]g :lnext<cr>zz

nnoremap <leader>di :ALEPopulateLocList<cr>
nnoremap <leader>fx :ALEFix<cr>
" nnoremap <leader>aa :ALECodeAction<cr>
" vnoremap <leader>aa :ALECodeAction<cr>

" ===== asyncomplete plugin
inoremap  <expr> <cr>   pumvisible() ? asyncomplete#close_popup() : "\<cr>"
imap      <expr> <tab>  pumvisible() ? "\<c-n><cr>" : "\<tab>"

" imap <c-space> <plug>(asyncomplete_force_refresh)
" For Vim 8 (<c-@> corresponds to <c-space>):
imap <c-@> <plug>(asyncomplete_force_refresh)

" Preview popup
let g:asyncomplete_auto_completeopt = 0
set completeopt=menuone,noinsert,noselect,preview
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

autocmd User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
  \   'name': 'buffer',
  \   'allowlist': ['*'],
  \   'blocklist': ['go'],
  \   'completor': function('asyncomplete#sources#buffer#completor')
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

" ===== goyo plugin
nnoremap <silent> <leader>F :Goyo<cr>
" autocmd! User GoyoEnter Limelight
" autocmd! User GoyoLeave Limelight!
autocmd! User GoyoEnter let g:ale_virtualtext_cursor = 'disabled'
autocmd! User GoyoLeave let g:ale_virtualtext_cursor = 'current'

let g:goyo_width = 120
let g:goyo_height = 70
" let g:goyo_linenr = 1

" ===== lightline plugin
let g:lightline = {
  \   'colorscheme': 'dracula',
  \ }

let g:lightline.component_expand = {
  \   'linter_checking': 'lightline#ale#checking',
  \   'linter_infos': 'lightline#ale#infos',
  \   'linter_warnings': 'lightline#ale#warnings',
  \   'linter_errors': 'lightline#ale#errors',
  \   'linter_ok': 'lightline#ale#ok',
  \ }

let g:lightline.component_type = {
  \   'linter_checking': 'right',
  \   'linter_infos': 'right',
  \   'linter_warnings': 'warning',
  \   'linter_errors': 'error',
  \   'linter_ok': 'right',
  \ }

" let g:lightline.active = { 'right': [[ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ]] }

" Final version
" let g:lightline.active = {
"   \ 'right': [ [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ],
"   \            [ 'lineinfo' ],
"   \            [ 'percent' ],
"   \            [ 'fileformat', 'fileencoding', 'filetype'] ] }

" ===== vim-airline plugin
" let g:airline#extensions#ale#enabled = 1
" let g:airline_powerline_fonts = 1

" Colorschemes
set background=dark
set termguicolors  " enable true colors support

colorscheme dracula
" colorscheme onedark
" let ayucolor="mirage"
" colorscheme ayu
" colorscheme gruvbox

" Functions definition
function! s:foldtext() abort
  return getline(v:foldstart) . '···' . '[' . (v:foldend - v:foldstart + 1) . ' lines]'
endfunction

function! s:brace_select(cmd, open) abort
  let pairs = {'(': ')', '[': ']', '{': '}', '<': '>'}
  let close = pairs[a:open]
  let full_cmd = a:cmd . a:open
  let line = getline('.')
  let pattern = '[' . escape(a:open . close, '[]') . ']'
  if line !~ pattern
    return full_cmd
  endif
  let char = line[col('.')-1]
  if char == a:open || char == close
    return full_cmd
  endif
  let rest = line[col('.'):]
  if rest =~ escape(a:open, '[]')      | return 'f' . a:open . full_cmd
  elseif rest =~ escape(close, '[]')   | return 'f' . close . full_cmd
  else | return (line =~ escape(a:open, '[]') ? 'F' . a:open : 'F' . close) . full_cmd
  endif
endfunction

function! ResetLocalDirsToGlobal()
  " TODO: consider using tabdo and windo instead of loops
  " Reset all tab-local directories
  for tabpage in range(1, tabpagenr('$'))
    execute tabpage . 'tabnext'
    if haslocaldir() == 2
      execute 'tcd ' . fnameescape(getcwd(-1))
    endif
    " Reset all window-local directories for current tab
    for window in range(1, winnr('$'))
      execute window . 'wincmd w'
      if haslocaldir() == 1
        execute 'lcd ' . fnameescape(getcwd(-1))
      endif
    endfor
  endfor
endfunction

function! SetIsKeywordForNonCpp()
  " Should not be applied for C++ due to operator->()
  if &filetype !=# 'cpp' || empty(&filetype)
    setlocal iskeyword+=-
  endif
endfunction

" Set auto commands
augroup remember_folds
  autocmd!
  autocmd BufWinLeave * if expand('%') != '' | mkview | endif
  autocmd BufWinEnter * if expand('%') != '' | silent! loadview | endif
augroup END

" Return to the last cursor position when opening files
autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   execute "normal! `\"" |
  \ endif

" Enable syntax highlighting for additional set of files
autocmd BufNewFile,BufRead ~/.config/* setfiletype dosini
autocmd BufNewFile,BufRead requirements*.txt set syntax=python

" Force indentation width for C++ files to 4 spaces
autocmd BufEnter *.cpp,*.h setlocal shiftwidth=4

" Do not consider '-' as part of word for C++ files
autocmd BufWinEnter,BufNewFile,BufRead * call SetIsKeywordForNonCpp()

" Update file if it was changed
" autocmd FocusGained,BufEnter,CursorHold * checktime
autocmd BufEnter,CursorHold * checktime

" autocmd VimEnter * call fzf#vim#history(fzf#vim#with_preview({'options': ['--layout=reverse']}), 1)
" autocmd VimEnter * call timer_start(50, {-> fzf#vim#history(fzf#vim#with_preview({'options': ['--layout=reverse']}), 0)})
" autocmd VimEnter * call timer_start(50, {-> execute('History')})

" Enable Powerline for Vim
" if has('linux')
"   python3 from powerline.vim import setup as powerline_setup
"   python3 powerline_setup()
"   python3 del powerline_setup
" endif

" Example of how to execute system process
" if has("gui_running")
"     let s:uname = system("uname")
"     if s:uname == 'Darwin\n'
"         set guifont=Meslo\ LG\ M\ for\ Powerline:h13
"     endif
" endif
