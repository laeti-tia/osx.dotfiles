" Load pathogen.vim and all other installed bundles
execute pathogen#infect()

" --- Defaults ---
" Just to be safe, we don't want the compatible mode
set nocompatible
" Number lines (might be useful against MacOS Terminal.app crashes)
" set number
" Bigger history
set history=1000
" Makes searches case-sensitive only if they contain upper-case characters
set ignorecase smartcase
" no space when joining lines, except if terminated by punctuation
set nojoinspaces
" Disable auto visual mode with mouse
set mouse-=a
" The width of a TAB (/t) is set to 4 and Indents are 4 too.
set tabstop=4 shiftwidth=4 softtabstop=4
" tab-key: insert 4 spaces (use :%retab to convert all tabs to spaces)
set expandtab smarttab
filetype plugin indent on
" Except for Makefiles
autocmd FileType make set tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab
" Use , instead of \ as Leader key
let mapleader = ','

" --- Colors ---
" We want syntax highlighting and for searches and better on dark background
syntax on
set hlsearch background=dark
colorscheme sahara

" --- Folding ---
set foldmethod=syntax
" XML Folding
let g:xml_syntax_folding = 1
au FileType xml setlocal foldmethod=syntax

" --- Rule, modeline, statusline ---
" Activate ruler (position within file at the bottom/right)
set ruler

" Show fileenconding and BOMB in the status line (and always show the status line)
if has("statusline")
    set statusline=%<%f\ %h%m%r%=%{\"[\".(&fenc==\"\"?&enc:&fenc).((exists(\"+bomb\")\ &&\ &bomb)?\",B\":\"\").\"]\ \"}%k\ %-14.(%l,%c%V%)\ %P
    set laststatus=2
endif

set modeline
" Append modeline after last line in buffer.
" Use substitute() instead of printf() to handle '%%s' modeline in LaTeX files.
function! AppendModeline()
    let l:modeline = printf(" vim: set ts=%d sw=%d tw=%d :", &tabstop, &shiftwidth, &textwidth)
    let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
    call append(line("$"), l:modeline)
endfunction
nnoremap <silent> <Leader>ml :call AppendModeline()<CR>

" --- File edition ---
" When editing a file, always jump to the last cursor position
autocmd BufReadPost *
\ if line("'\"") > 0 && line ("'\"") <= line("$") |
\   exe "normal g'\"" |
\ endif

" Triger `autoread` when files changes on disk
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif
" Notification after file change
autocmd FileChangedShellPost *
  \ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None

" --- Macros ---
" Load Justify macro (to be called with ":J")
runtime macros/justify.vim

" --- File types, language and format specifics ---
" Adding a few filetypes
au BufNewFile,BufRead *.ddl set filetype=sql
au BufNewFile,BufRead Capfile set filetype=ruby

" Use a better ctags binary
let Tlist_Ctags_Cmd = "/usr/local/bin/ctags"

" Go to the top of the Git commit message
autocmd FileType gitcommit call setpos('.', [0, 1, 1, 0])

" ansible-vim see https://github.com/pearofducks/ansible-vim
let g:ansible_unindent_after_newline = 1
let g:ansible_extra_keywords_highlight = 1
au BufRead,BufNewFile */playbooks/*.yml set filetype=ansible

" JSON auto format with python, call with gg=G to reformat an entire file
au FileType json setlocal equalprg=python\ -m\ json.tool

" sshconfig syntax coloring on all config files
au BufRead,BufNewFile ~/.ssh/config.* set filetype=sshconfig

