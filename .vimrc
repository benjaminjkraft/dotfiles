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
" in principle nofoldenable DTRT, but it means the first zc will enable folds
" and thus close them all.  instead, enable folds, but set them all open.
set foldlevel=99
set backspace=indent,eol,start
set nocp
set cole=2
set cocu=nvc
set tw=79 sw=4 ts=4 sts=4
set colorcolumn=+1
set wildmenu
set scrolloff=1
set display+=lastline
set tags=./tags;

" ALE -- turn on fixers, but not for 3rd party code.
let g:ale_linters = {}  " defined below
let g:ale_fixers = {}   " defined below
let g:ale_fix_on_save = 1
" TODO: figure out ALE completion (may require getting pyls living beyond the
" vim session, so it's not super slow)
" TODO: cleaner way to handle these various kinds of third-party-ness
autocmd BufRead,BufNewFile */google/appengine/* let b:ale_fix_on_save = 0
autocmd BufRead,BufNewFile */frankenserver/* let b:ale_fix_on_save = 0
autocmd BufRead,BufNewFile */frankenserver-khansrc/* let b:ale_fix_on_save = 0
autocmd BufRead,BufNewFile */third_party/* let b:ale_fix_on_save = 0

" display options
set laststatus=2
set guifont=Ubuntu\ Mono\ derivative\ Powerline\ 11
highlight LineNr guifg=white guibg=black
highlight Conceal guifg=black guibg=white
set guioptions-=T
set formatoptions+=tro
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
let g:airline_theme='solarized'
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

let g:airline_detect_paste=0
let g:airline_detect_spell=0
let g:airline_detect_crypt=0
let g:airline_skip_empty_sections=1

let g:airline_section_x = airline#section#create([])
let g:airline_section_y = airline#section#create(['filetype'])
call airline#parts#define('pct', {'raw': '%3p%% '})
call airline#parts#define('linenr', {'raw': '%3l', 'accent': 'bold'})
call airline#parts#define('colnr', {'raw': ': %2v'})
call airline#parts#define('maxlinenr', {'raw': '/%L', 'accent': 'none'})
let g:airline_section_z = airline#section#create(['pct', 'linenr', 'maxlinenr', 'colnr'])

let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#wordcount#enabled = 1
let g:airline#extensions#wordcount#filetypes = '.*'
let g:airline#extensions#wordcount#formatter#default#fmt = '%sw'  " always short!
let g:airline#extensions#wordcount#formatter#default#fmt_short = '%sw'

" shortcuts
map Y y$
cnoremap w!! w !sudo dd of=%
vnoremap < <gv
vnoremap > >gv
nnoremap <C-j> <C-W>w
nnoremap <C-k> <C-W>W
nnoremap <Leader>u :GundoToggle<CR>
nnoremap <Leader>m :wa<CR>:make<CR><CR>
nnoremap <C-\><C-\> :ALEGoToDefinitionInSplit<CR>
nnoremap <C-\>\ :ALEGoToDefinitionInSplit<CR>
nnoremap <C-\>s :ALEGoToDefinitionInSplit<CR>
nnoremap <C-\>v :ALEGoToDefinitionInVSplit<CR>
nnoremap <C-\>e :ALEGoToDefinition<CR>
nnoremap <C-]><C-]> :ALEGoToTypeDefinitionInSplit<CR>
nnoremap <C-]>] :ALEGoToTypeDefinitionInSplit<CR>
nnoremap <C-]>s :ALEGoToTypeDefinitionInSplit<CR>
nnoremap <C-]>v :ALEGoToDefinitionInVSplit<CR>
nnoremap <C-]>e :ALEGoToDefinition<CR>
nnoremap <C-t> <C-^>
vnoremap // y/\V<C-r>=escape(trim(@"),'/\')<CR><CR>

" easymotion
" map  / <Plug>(easymotion-sn)
" omap / <Plug>(easymotion-tn)
" map  n <Plug>(easymotion-next)
" map  N <Plug>(easymotion-prev)

" highlight STOPSHIPs
autocmd Syntax * syn keyword bonusTodo STOPSHIP containedin=.*Comment.*
hi def link bonusTodo Todo


" sh
autocmd FileType sh setlocal tw=0

" make
autocmd BufNewFile,BufReadPost Makefile.* set filetype=make
autocmd FileType make setlocal noet

" JSON
let g:vim_json_syntax_conceal=0
autocmd FileType json setlocal foldmethod=syntax

" Markdown, text, etc.
autocmd BufNewFile,BufReadPost *.md set filetype=markdown
autocmd FileType markdown setlocal tw=0
autocmd FileType markdown setlocal linebreak
autocmd FileType text setlocal tw=0
autocmd FileType text setlocal linebreak

" Python
autocmd FileType python setlocal ts=4 sw=4 sts=4
autocmd FileType python setlocal foldmethod=indent
autocmd BufRead,BufNewFile */google/appengine/* setlocal ts=2 sw=2 sts=2
autocmd BufRead,BufNewFile */frankenserver/* setlocal ts=2 sw=2 sts=2
autocmd BufRead,BufNewFile */frankenserver-khansrc/* setlocal ts=2 sw=2 sts=2
" let g:ale_linters.python = ['flake8', 'pyls']
let g:ale_fixers.python = ['autopep8']
" autopep8 is too aggressive about things not fixed by pycodestyle, so we have
" to turn off all of E301 and E303 autofixes :(.  Sadly that also means we have
" to duplicate webapp's .flake8 setting for --ignore.
" TODO: remove if autopep8#431 gets fixed.
let g:ale_python_autopep8_options = '--ignore E301,E303,W503,E266,E402,E501,E712,E731,E741'

" JS(X)
let g:ale_fixers.javascript = ['eslint']
autocmd BufRead,BufNewFile */khan/webapp* let b:ale_javascript_eslint_executable = $HOME."/khan/devtools/khan-linter/node_modules/.bin/eslint"
autocmd BufRead,BufNewFile */khan/webapp* let b:ale_javascript_eslint_use_global = 1

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

" Groovy
autocmd Filetype groovy setlocal tabstop=3 shiftwidth=3 softtabstop=3

" Kotlin
autocmd BufRead,BufNewFile */khan/* let g:ale_kotlin_ktlint_executable = $HOME."/khan/devtools/khan-linter/vendor/ktlint"
" turn off kotlinc -- it tries to do too much, spins, and crashes.
let g:ale_linters.kotlin = ['ktlint', 'languageserver']

" Go
autocmd FileType go setlocal noexpandtab
autocmd FileType go setlocal foldmethod=indent
let g:ale_linters.go = ['gofmt', 'golint', 'govet', 'gopls']
let g:ale_fixers.go = ['gofmt', 'goimports']
