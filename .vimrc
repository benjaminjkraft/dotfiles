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
set relativenumber
set expandtab
set autowrite
set autoindent
set nofoldenable
set backspace=indent,eol,start
set nocp
set cole=2
set cocu=nvc
set tw=79 sw=4 ts=4 sts=4
set colorcolumn=+1
set wildmenu
set scrolloff=1
set display+=lastline

" display options
set laststatus=2
set guifont=Ubuntu\ Mono\ derivative\ Powerline\ 11
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

" rainbow parens
au VimEnter * RainbowParenthesesActivate
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

" indentLine
let g:indentLine_color_term = 235 " solarized base02
let g:indentLine_color_gui = '#eee8d5' "solarized base2
let g:indentLine_char = '│'

"emmet.vim
let g:user_emmet_mode='nv'
let g:user_emmet_leader_key=',e'

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
" TODO: once https://github.com/bling/vim-airline/pull/866/ is merged and
" works, replace this with that.
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
nnoremap <C-\> <C-W><C-]>

" easymotion
" map  / <Plug>(easymotion-sn)
" omap / <Plug>(easymotion-tn)
" map  n <Plug>(easymotion-next)
" map  N <Plug>(easymotion-prev)

" sh
autocmd FileType sh setlocal tw=0

" make
autocmd FileType make setlocal noet

" JSON
let g:vim_json_syntax_conceal=0
autocmd FileType json setlocal foldmethod=syntax

" Markdown
autocmd BufNewFile,BufReadPost *.md set filetype=markdown
autocmd FileType markdown setlocal tw=0

" Python
autocmd FileType python setlocal ts=4 sw=4 sts=4
let g:syntastic_python_checkers = ['flake8']
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_javascript_eslint_args = '--config third_party/khan-linter-src/eslintrc'
let g:syntastic_jsx_checkers = ['eslint']

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
