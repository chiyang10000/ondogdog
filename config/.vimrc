filetype plugin indent on
syntax on
set nu
set incsearch
set hlsearch
set clipboard=unnamed
set mouse=i
set paste
set backspace=indent,eol,start
set autoindent
set ruler
set tabstop=2
set shiftwidth=2
set expandtab
set listchars=tab:^I
color desert
highlight ColorColumn ctermbg=235 guibg=#2c2d27
let &colorcolumn="72,80,".join(range(120,999),",")
