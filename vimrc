" TODO cleanup all the unecessary stuff

set nocompatible

"" {{ From sensible plugin
set autoindent
set backspace=indent,eol,start
set complete-=i
set smarttab

set nrformats-=octal
set shiftround


set ttimeout
set ttimeoutlen=100

set incsearch
" Use <C-L> to clear the highlighting of :set hlsearch.
if maparg('<C-L>', 'n') ==# ''
  nnoremap <silent> <C-L> :nohlsearch<CR><C-L>
endif

set showcmd
if !&scrolloff
  set scrolloff=1
endif
if !&sidescrolloff
  set sidescrolloff=5
endif
set display+=lastline

if &encoding ==# 'latin1' && has('gui_running')
  set encoding=utf-8
endif

if &listchars ==# 'eol:$'
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif

if &shell =~# 'fish$'
  set shell=/bin/bash
endif

set autoread

if &history < 1000
  set history=1000
endif
if &tabpagemax < 50
  set tabpagemax=50
endif
if !empty(&viminfo)
  set viminfo^=!
endif
set sessionoptions-=options

" Allow color schemes to do bright colors without forcing bold.
if &t_Co == 8 && $TERM !~# '^linux'
  set t_Co=16
endif

inoremap <C-U> <C-G>u<C-U>
""}}

"" {{{ Patohogen init
filetype off
call pathogen#infect() 
call pathogen#helptags()
filetype plugin indent on
syntax on
" }}}


" {{{ File managment
set nobackup
set noswapfile
" }}}


" {{{Error bells
set visualbell
set noerrorbells
" }}}"


" {{{ Colorscheme
"let g:solarized_termcolors= 256 
let g:solarized_termtrans = 0  
let g:solarized_degrade = 0 
let g:solarized_bold = 1  
let g:solarized_underline = 1  
let g:solarized_italic = 1  
let g:solarized_contrast = "normal" "| “high” or “low” 
let g:solarized_visibility= "normal" "| “high” or “low”
set background=dark
colorscheme solarized
" }}}



" Menu {
set wildmenu
set wildmode=list:longest,full
" }
let mapleader = ","


" Mouse {
set mouse=a
" }



" Since I use linux, I want this
let g:clipbrdDefaultReg = '+'

" When I close a tab, remove the buffer
set nohidden

syntax on
set bs=2

" {{{ ########### open file at latest position #############
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
" }}}



" {{{ ############### Syntastic configuration ############"
let g:syntastic_auto_loc_list=1
let g:syntastic_python_checkers = ['flake8']
let g:syntastic_python_flake8_args = '--ignore="E501,E302,E261,E701,E241,E126,E127,E128,W801"'

" }}}

" {{{ ########## disable pyflakes
let b:did_pyflakes_plugin = 1
" }}}



" {{{ ########## fswitch ###############

" }}}

" {{{ ############## CTAGS ###########################
" deplacement avec les fleches
map <silent><C-Left> <C-T>
map <silent><C-Right> <C-]>

" }}}

" Easy tags {
" Tags creation in the background

let g:easytags_always_enabled = 0
let g:easytags_on_cursorhold = 0
let g:easytags_auto_update = 1
let g:easytags_auto_highlight = 0
let g:easytags_dynamic_files = 1
let g:easytags_include_members = 1
let g:easytags_events = ['BufWritePost']

set tags+=tags;/ "read tags from anywhere
set tags+=~/.vim/tags/cpp
set tags+=~/.vim/tags/gl
set tags+=~/.vim/tags/qt4

" }

" Showmarks{
" Don't leave on by default, use :ShowMarksOn to enable
        let g:showmarks_enable = 0

"}

" {{{ ########## Tag bar #####################
let g:tagbar_type_tex = {
\ 'ctagstype' : 'latex',
\ 'kinds' : [
\ 's:sections',
\ 'g:graphics',
\ 'l:labels',
\ 'r:refs:1',
\ 'p:pagerefs:1'
\ ],
\ 'sort' : 0,
\ }
"\  'deffile' : expand('<sfile>:p:h:h') . '/ctags/latex.cnf'


" ### CPC things ###
let g:tagbar_type_z80 = {
  \ 'ctagstype' : 'z80',
  \ 'kinds' : [
    \	'd:define',
    \	'l:label',
    \	'm:macro',
    \   's:struct',
  \ ],
  \ 'sort' : 1,
\}

" Open tagbar for cpc files
autocmd BufEnter *.asm nested TagbarOpen
nmap <F8> :TagbarToggle<CR>
" }}}


" {{{ ########### Latex  (9 tex)###############
" voir si je peux mettre rubber
let g:tex_flavor='latex'
let g:tex_synctex=1
let g:tex_viewer={'app': 'evince', 'target': 'pdf'}
let g:tex_nine_config={'compiler': 'pdflatex', 'leader': ';'}
let g:tex_fold_enabled = 1

autocmd FileType tex :NoMatchParen
au FileType tex setlocal nocursorline
" }}}



" {{{ ########### LanguageTool correction grammatical #########
let g:languagetool_jar='~/.vim/spell/LanguageTool.jar'
let g:languagetool_disable_rules='WHITESPACE_RULE,EN_QUOTES,FRENCH_WHITESPACE'
" }}}


" {{{ ########### modeline ###############
set modeline 	"Enable the feature, don't forget :set modelines=xxx
set modelines=5 "	Check the first five lines in a file for vim: 
" }}}


" {{{ ############## Z80 #################
au BufRead,BufNewFile *.z80		set filetype=z80
au BufRead,BufNewFile *.src		set filetype=z80
au BufRead,BufNewFile *.asm		set filetype=z80
" }}}


" {{{ #################### rst #####################
" Allow to automatically write lines for titles and so on
" need to write @h symbol
" source http://www.programmerq.net/rsttricks.html
" do it only in .rst
let @h = "yypVr"
" }}}


"{{{ ################## Python ########################
"au BufRead,BufNewFile *.py		set filetype=python
"au BufRead,BufNewFile *.pyx		set filetype=pyrex
"
"autocmd FileType python set omnifunc=pythoncomplete#Complete
"autocmd FileType python compiler pylint
"let g:pylint_onwrite = 0
" Completion avec espace
"inoremap <Nul> <C-x><C-o>
" make pour tester els erreurs
"autocmd BufRead *.py set makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
"autocmd BufRead *.py set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%
 
augroup vimrc_autocmds
    autocmd!
    " highlight characters past column 120
    autocmd FileType python highlight Excess ctermbg=DarkGrey guibg=Black
    autocmd FileType python match Excess /\%120v.*/
    autocmd FileType python set nowrap
augroup END



" }}}
" {{{ ################ Template #########################
au BufNewFile *.html 0r ~/.vim/templates/xhtml.html

let $hostfile= $HOME . '/.vim/templates/' . hostname() . '.python.py'
if filereadable($hostfile)
    au BufNewFile *.py 0r $hostfile
else
    au BufNewFile *.py 0r ~/.vim/templates/python.py
endif
" }}}








" {{{ ACK
let g:ackprg="ack-grep -H --nocolor --nogroup --column"
" }}}

" {{{ Status line
" VIM va donner une priorite moindre aux fichiers ayant les extensions suivantes dans la selection (exemple tabnew)
set suffixes=.aux,.bak,.bbl,.blg,.gif,.gz,.idx,.ilg,.info,.jpg,.lof,.log,;lot,.o,.obj,.pdf,.png,.swp,.tar,.toc,~



set laststatus=2 " Affiche la barre de status quoi qu'il en soit (0 pour la masquer, 1 pour ne l'afficher que si l'ecran est divise)
if has("statusline")
    set statusline=\ %f%m%r\ [%{strlen(&ft)?&ft:'aucun'},%{strlen(&fenc)?&fenc:&enc},%{&fileformat},ts:%{&tabstop}]%=%l,%c%V\ %P 

    " syntastsic things
    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*

    " fugitive
    set statusline+=%{fugitive#statusline()}

elseif has("cmdline_info")
    set ruler " Affiche la position du curseur en bas a gauche de l'ecran
endif
" }}}

" {{{Thesaurus
set thesaurus+=/home/romain/.vim/spell/mthesaur.unix.txt
"}}}



"{{{ Ultisnip
   let g:UltiSnipsUsePythonVersion = 2
   let g:UltiSnipsSnippetsDir="~/.vim/ultisnips_snippets"
   let g:UltiSnipsEditSplit="horizontal"
   let g:UltiSnipsExpandTrigger="<c-j>"
"   let g:UltiSnipsJumpForwardTrigger="<tab>"
"   let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
   let g:UltiSnipsSnippetDirectories=["vim-snippets/UltiSnips", "ultisnips_snippets"]
"}}}


"{{{ Ctrlp
let g:ctrlp_working_path_mode = 'ra'
"}}}


"{{{Supertab
let g:SuperTabDefaultCompletionType = "context"
"}}}
"

"{{{Fswitch
 "Switch to the file and load it into the current window >
nmap <silent> <Leader>of :FSHere<cr>

 "Switch to the file and load it into the window on the right >
nmap <silent> <Leader>ol :FSRight<cr>

 "Switch to the file and load it into a new window split on the right >
nmap <silent> <Leader>oL :FSSplitRight<cr>

 "Switch to the file and load it into the window on the left >
nmap <silent> <Leader>oh :FSLeft<cr>

 "Switch to the file and load it into a new window split on the left >
nmap <silent> <Leader>oH :FSSplitLeft<cr>

 "Switch to the file and load it into the window above >
nmap <silent> <Leader>ok :FSAbove<cr>

 "Switch to the file and load it into a new window split above >
nmap <silent> <Leader>oK :FSSplitAbove<cr>

 "Switch to the file and load it into the window below >
nmap <silent> <Leader>oj :FSBelow<cr>

 "Switch to the file and load it into a new window split below >
nmap <silent> <Leader>oJ :FSSplitBelow<cr>




 augroup mycppfiles
   au!
   au BufEnter *.h let b:fswitchdst  = 'cpp,cxx,C,cc'
   au BufEnter *.h let b:fswitchlocs = '.,../src,../source,../../src,../../source'
 augroup END

augroup myhfiles
   au!
   au BufEnter *.cpp,*.cc let b:fswitchdst  = 'h,hxx'
   au BufEnter *.cpp,*.cc let b:fswitchlocs = '.,../include,../include/Tulip'
 augroup END


"}}}
"
"
"{{{YMC
nnoremap <leader>g :YcmCompleter GoToDefinitionElseDeclaration<CR>
let g:ycm_collect_identifiers_from_tags_files = 1
let g:ycm_seed_identifiers_with_syntax = 0
let g:ycm_add_preview_to_completeopt = 1
let g:ycm_confirm_extra_conf = 0
let g:ycm_cache_omnifunc = 0
let g:ycm_semantic_triggers =  {
  \   'c' : ['->', '.'],
  \   'cpp' : ['->', '.'],
  \   'objc' : ['->', '.'],
  \   'ocaml' : ['.', '#'],
  \   'cpp,objcpp' : ['->', '.', '::'],
  \   'perl' : ['->'],
  \   'php' : ['->', '::'],
  \   'cs,java,javascript,d,vim,python,perl6,scala,vb,elixir,go' : ['.'],
  \   'ruby' : ['.', '::'],
  \   'lua' : ['.', ':'],
  \   'erlang' : [':'],
  \   'tex' : ['\ref{','\cite{']
  \ }
"}}}
"""""""""""" General
set ruler
set number

