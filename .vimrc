runtime bundle/vim-pathogen/autoload/pathogen.vim
filetype off
execute pathogen#infect()
execute pathogen#helptags()
filetype plugin indent on
syntax on

set incsearch
set ignorecase
set smartcase
let g:EasyMotion_smartcase = 1
set spell
set number
set expandtab
set autowrite
set autoindent
set nofoldenable
set backspace=indent,eol,start
set nocp
set cole=2
set cocu=nvc
set tw=79 sw=2 ts=2 sts=2

" display options
set laststatus=2
set guifont=Ubuntu\ Mono\ derivative\ Powerline\ 12
highlight LineNr guifg=white guibg=black
highlight Conceal guifg=black guibg=white
set guioptions-=T
set formatoptions+=t
if has('gui_running')
    set background=light
    let g:airline_powerline_fonts = 1
else
    set background=dark
    let g:solarized_termcolors=256
endif
colorscheme solarized

" airline config
let g:airline_mode_map = {
    \ '__' : '-',
    \ 'n' : 'N',
    \ 'i' : 'I',
    \ 'R' : 'R',
    \ 'c' : 'C',
    \ 'v' : 'V',
    \ 'V' : 'V',
    \ '' : 'V',
    \ 's': 'S',
    \ 'S' : 'S',
    \ '' : 'S',
    \ }
" word count from http://cromwell-intl.com/linux/vim-word-count.html
function WordCount()
  if !exists('w:word_count')
    let w:word_count="?"
  endif
	return w:word_count
endfunction
function UpdateWordCount()
	let lnum = 1
	let n = 0
	while lnum <= line('$')
		let n = n + len(split(getline(lnum)))
		let lnum = lnum + 1
	endwhile
	let w:word_count = n
endfunction
" Update the count when cursor is idle in command or insert mode.
" Update when idle for 1000 msec (default is 4000 msec).
set updatetime=1000
augroup WordCounter
	au! CursorHold,CursorHoldI * call UpdateWordCount()
augroup END
let g:airline_section_z = airline#section#create(['windowswap', '%{WordCount()}w  ', 'linenr', '/%L:%3v '])

" shortcuts
map Y y$
cnoremap w!! w !sudo dd of=%
vnoremap < <gv
vnoremap > >gv
nnoremap <C-j> <C-W>w
nnoremap <C-k> <C-W>W
nnoremap <Leader>u :GundoToggle<CR>
nnoremap <Leader>m :wa<CR>:make<CR><CR>

" easymotion
" map  / <Plug>(easymotion-sn)
" omap / <Plug>(easymotion-tn)
" map  n <Plug>(easymotion-next)
" map  N <Plug>(easymotion-prev)

" JSON
let g:vim_json_syntax_conceal=0
autocmd FileType json setlocal foldmethod=syntax

" HTML
autocmd FileType html setlocal tw=0

" Markdown
autocmd BufNewFile,BufReadPost *.md set filetype=markdown
autocmd FileType markdown setlocal tw=0

" Python
autocmd FileType python setlocal ts=4 sw=4 sts=4
let g:syntastic_python_checkers = ['pyflakes', 'pep8']

" (La)TeX
let g:tex_flavor='latex'
let g:tex_conceal="agm"
let b:atp_OpenViewer = 1
let atp_Viewer = "evince"
let g:atp_imap_define_math=0
autocmd FileType tex setlocal tw=0
autocmd FileType bib setlocal tw=0
let g:syntastic_tex_chktex_args = "-n 8"

" Haskell
let g:haskell_conceal=0
autocmd FileType haskell vnoremap _p :PointFree!<CR>
autocmd FileType haskell nnoremap _l :GhcModLint<CR>
autocmd FileType haskell nnoremap __ :GhcModCheck<CR>
autocmd FileType haskell nnoremap _st :GhcModType<CR>
let g:haddock_browser="/usr/bin/firefox"
let g:ghc="/usr/bin/local/ghc"
au BufEnter *.hs compiler ghc
autocmd FileType haskell setlocal tw=0
