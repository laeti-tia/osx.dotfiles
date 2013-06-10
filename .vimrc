syntax on
" Highlight searches
set hlsearch
" Activate ruler (position within file at the bottom/right)
set ruler
set background=dark
"set modeline
"set modelines=5

" Default tab behavior
set ts=4 sw=4 tw=0

" Change the <Leader> key
"let mapleader = ","

" Append modeline after last line in buffer.
" Use substitute() instead of printf() to handle '%%s' modeline in LaTeX files.
function! AppendModeline()
	let l:modeline = printf(" vim: set ts=%d sw=%d tw=%d :", &tabstop, &shiftwidth, &textwidth)
	let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
	call append(line("$"), l:modeline)
endfunction
nnoremap <silent> <Leader>ml :call AppendModeline()<CR>

" Only do this part when compiled with support for autocommands
if has("autocmd")
	" When editing a file, always jump to the last cursor position
	autocmd BufReadPost *
	\ if line("'\"") > 0 && line ("'\"") <= line("$") |
	\   exe "normal g'\"" |
	\ endif
endif

" Load Justify macro (to be called with ":J")
runtime macros/justify.vim

" Load pathogen.vim and all other installed bundles
call pathogen#infect()

" Use a better ctags binary
let Tlist_Ctags_Cmd = "/usr/local/bin/ctags"

" Go to the top of the Git commit message
autocmd FileType gitcommit call setpos('.', [0, 1, 1, 0])

" Adding a few filetypes
au BufNewFile,BufRead Capfile set filetype=ruby

" XML Folding
let g:xml_syntax_folding = 1
au FileType xml setlocal foldmethod=syntax
