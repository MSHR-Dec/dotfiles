let mapleader = "\<Space>"

" vim plug
call plug#begin('~/.vim/plugged')

Plug '/opt/homebrew/opt/fzf'
Plug 'junegunn/fzf.vim'
Plug 'preservim/vim-markdown'
Plug 'voldikss/vim-floaterm'
Plug 'vim-airline/vim-airline'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-endwise'
Plug 'joshdick/onedark.vim'

call plug#end()

" Floaterm
let g:floaterm_opener = 'edit'
nmap <C-t> :FloatermToggle /opt/homebrew/bin/brush --login<CR>
nnoremap <C-b> :FloatermNew --width=0.9 --height=0.9 --title=yazi yazi<CR>

" fzf
let $FZF_DEFAULT_COMMAND = 'fd --type f --hidden --exclude .git'
nnoremap <Leader>fg :Rg<CR>
nnoremap <Leader>ff :BLines<CR>
nnoremap <Leader>fF :Files<CR>
nnoremap <Leader>fb :Buffers<CR>

" vim-airline
let g:airline_theme='onedark'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'

" vim-terraform
let g:terraform_fmt_on_save=1

" common
set number
set nowritebackup
set nobackup
set virtualedit=block
set backspace=indent,eol,start
set ambiwidth=single
set wildmenu
set ignorecase
set smartcase
set wrapscan
set incsearch
set hlsearch
set showmatch matchtime=1
set cinoptions+=:0
set cmdheight=2
set laststatus=2
set showcmd
set display=lastline
set listchars=tab:^\ ,trail:~
set history=10000
set expandtab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set guioptions-=T
set guioptions+=a
set guioptions-=m
set guioptions+=R
set showmatch
set smartindent
set noswapfile
set nofoldenable
set title
set hidden
set clipboard=unnamed,autoselect

nnoremap x "_x
nnoremap s "_s
nnoremap <Esc><Esc> :nohlsearch<CR><ESC>
nnoremap <C-N> :bnext<CR>
nnoremap <C-P> :bprev<CR>
nnoremap <S-F> :%!jq .<CR><ESC>
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv
vnoremap < <gv
vnoremap > >gv

set cursorline

" theme
set termguicolors
let g:onedark_terminal_italics = 1
let g:onedark_color_overrides = {
\ "foreground": { "gui": "#FFFFFF", "cterm": "231", "cterm16": "NONE" },
\ "white":      { "gui": "#FFFFFF", "cterm": "231", "cterm16": "15" },
\}

syntax on
colorscheme onedark
