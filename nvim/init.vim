scriptencoding utf-8
source ~/.config/nvim/plugins.vim

" ============================================================================ "
" ===                           EDITING OPTIONS                            === "
" ============================================================================ "

" Remap leader key to Space
let mapleader="\<Space>"
let maplocalleader="\,"

" Don't show last command
set noshowcmd

" Yank and paste with the system clipboard
set clipboard=unnamed

" Hides buffers instead of closing them
set hidden

" === TAB/Space settings === "
" Insert spaces when TAB is pressed.
set expandtab

" Change number of spaces that a <Tab> counts for during editing ops
set softtabstop=2

" Indentation amount for < and > commands.
set shiftwidth=2

" do not wrap long lines by default
set nowrap

" Don't highlight current cursor line
set nocursorline

" Disable line/column number in status line
" Shows up in preview window when airline is disabled if not
set noruler

" Only one line for command line
set cmdheight=1

" === Completion Settings === "

" Don't give completion messages like 'match 1 of 2'
" or 'The only match'
set shortmess+=c

" Allow mouse movement
set mouse=a
set mouse=n

" Make gf work well
set suffixesadd+=.js

" Code folding
set foldmethod=indent


au BufNewFile,BufRead *.ejs set filetype=html

" Keep all folds open when a file is opened
augroup OpenAllFoldsOnFileOpen
  autocmd!
  autocmd BufRead * normal zR
augroup END

" syntax highlight
syntax enable

" filetype plugin
filetype plugin indent on

" === Cusomt functions === "
function! DeleteFile(...)
  if(exists('a:1'))
    if has_key(a:1['targets'][0], 'action__bufnr')
      let theFile=a:1['targets'][0].action__bufnr
    else
      let theFile=a:1['targets'][0].action__path
    endif
  elseif ( &ft == 'help' )
    echohl Error
    echo "Cannot delete a help buffer!"
    echohl None
    return -1
  else
    let theFile=expand('%:p')
  endif
  if input('delete '.theFile.' ? (y/n)') ==# 'y'
    if !delete(theFile,'rf')
      let a = getpos('.')
      if &ft ==? 'dirvish'
        e
        call setpos('.',a)
      elseif &ft ==? 'netrw'
        if search('^\.\/$','Wb')
          exe "norm \<cr>"
          call setpos('.',a)
        endif
      endif
    endif
  endif
endfunction

" Change the directory
function! ChangeDirectory(...)
  let theDirectory=a:1['targets'][0].action__path
  if input('Change the directory to '.theDirectory.' ? (y/n)') ==# 'y'
    if exists('*nvim_set_current_dir')
      call nvim_set_current_dir(theDirectory)
    else
      silent execute 'lcd' fnameescape(theDirectory)
    endif
  endif
endfunction

function! CreateNewEntityHelper(theDirectory)
  call inputsave()
  let newFileName = input('Type new file or directory '.a:theDirectory.' ? ')
  call inputrestore()
  let directories = split(newFileName, '/')[0:-2]
  if len(directories) > 0
    " Create directories
    let newDirectories = join([a:theDirectory] + directories, '/')
    if input('Creating the following directory ? '.newDirectories.'/'.' ? (y/n)') ==# 'y'
      call mkdir(newDirectories, "p")
    endif
  endif
  let newFile = join([a:theDirectory, newFileName], '/')
  if input('Creating the following file ? '.newFile.' ? (y/n)') ==# 'y'
    call system(join(['touch', newFile], ' '))
    silent execute "edit +0 " . newFile
  endif
endfunction

" Create a new file or directory
function! CreateNewEntityInSpecifiedDirectory(...)
  let theDirectory=a:1['targets'][0].action__path
  call CreateNewEntityHelper(theDirectory)
endfunction

" Create a new file in current directory
function! CreateNewEntityInCurrentDirectory(...)
  let theDirectory=a:1['targets'][0].action__path
  let directories = split(theDirectory, '/')[0:-2]
  let currentDirectory = join(directories, '/')
  call CreateNewEntityHelper(currentDirectory)
endfunction

" Find and replace matched keyword in specified projects
"function! FindAndReplaceMatches(...)
"endfunction

" Window operations
function! HOpen(dir,what_to_open)
    let [type,name] = a:what_to_open
    if a:dir=='left' || a:dir=='right'
        vsplit
    elseif a:dir=='up' || a:dir=='down'
        split
    endif
    if a:dir=='down' || a:dir=='right'
        exec "normal! \<leader>\<leader>"
    endif
    if type=='buffer'
        exec 'buffer '.name
    else
        exec 'edit '.name
    endif
endfunction

function! HYankWindow()
    let g:window = winnr()
    let g:buffer = bufnr('%')
    let g:bufhidden = &bufhidden
endfunction

function! HPasteWindow(direction)
    let old_buffer = bufnr('%')
    call HOpen(a:direction,['buffer',g:buffer])
    let g:buffer = old_buffer
    let &bufhidden = g:bufhidden
endfunction

noremap <leader>yy :call HYankWindow()<cr>
noremap <leader>pp :call HPasteWindow('here')<cr>

noremap <leader>fe :Explore<CR>
" ============================================================================ "
" ===                           PLUGIN SETUP                               === "
" ============================================================================ "

" Wrap in try/catch to avoid errors on initial install before plugin is available
" === Denite setup ==="
" Use ripgrep for searching current directory for files
" By default, ripgrep will respect rules in .gitignore
"   --files: Print each file that would be searched (but don't search)
"   --glob:  Include or exclues files for searching that match the given glob
"            (aka ignore .git files)
"
call denite#custom#var('file/rec', 'command', ['ag', '--nocolor', '--nogroup', '--ignore', '*node_modules*', '-g', ''])
call denite#custom#var('file/rec', 'command', ['ag', '--nocolor', '--nogroup', '--ignore', '*node_modules*', '-g', ''])

" Use ripgrep in place of "grep"
call denite#custom#var('grep', 'command', ['ag', '--ignore', '*node_modules*', '--ignore', '*public*'])

call denite#custom#source(
\ 'grep', 'matchers', ['matcher_regexp'])

" Recommended defaults for ag via Denite docs
call denite#custom#var('grep', 'default_opts',
    \ ['-i', '--vimgrep'])
call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#var('grep', 'pattern_opt', [])
call denite#custom#var('grep', 'separator', ['--'])
call denite#custom#var('grep', 'final_opts', [])

" Remove date from buffer list
call denite#custom#var('buffer', 'date_format', '')

" === actions === "
call denite#custom#action('buffer,file,directory', 'delete_entity', function('DeleteFile'))
call denite#custom#action('buffer,file,directory', 'change_directory', function('ChangeDirectory'))
call denite#custom#action('buffer,file,directory', 'create_new_entity_in_target_directory', function('CreateNewEntityInSpecifiedDirectory'))
call denite#custom#action('buffer,file,directory', 'create_new_entity_in_current_directory', function('CreateNewEntityInCurrentDirectory'))
"call denite#custom#action('buffer,file,directory', 'replace_matches', function('FindAndReplaceMatches'))


call denite#custom#filter('matcher/ignore_globs', 'ignore_globs',
	      \ [ '*node_modules*'])

" Open file commands
call denite#custom#map('insert,normal', "<C-t>", '<denite:do_action:tabopen>')
call denite#custom#map('insert,normal', "<C-v>", '<denite:do_action:vsplit>')
call denite#custom#map('insert,normal', "<C-d>", '<denite:do_action:delete_entity>')
call denite#custom#map('insert,normal', "<C-h>", '<denite:move_up_path>')
call denite#custom#map('insert,normal', "<C-p>", '<denite:do_action:preview>')
call denite#custom#map('insert,normal', "<C-g>", '<denite:do_action:change_directory>')
call denite#custom#map('insert,normal', "<C-e>", '<denite:do_action:create_new_entity_in_target_directory>')
call denite#custom#map('insert,normal', "<C-n>", '<denite:do_action:create_new_entity_in_current_directory>')
call denite#custom#map('insert,normal', "<C-q>", '<denite:do_action:quickfix>')


" Move cursor in Denite
call denite#custom#map('insert', '<C-j>', '<denite:move_to_next_line>', 'noremap')
call denite#custom#map('insert', '<C-k>', '<denite:move_to_previous_line>', 'noremap')

" Show the denite status
call denite#get_status('path')

" Custom options for Denite
"   auto_resize             - Auto resize the Denite window height automatically.
"   prompt                  - Customize denite prompt
"   direction               - Specify Denite window direction as directly below current pane
"   winminheight            - Specify min height for Denite window
"   highlight_mode_insert   - Specify h1-CursorLine in insert mode
"   prompt_highlight        - Specify color of prompt
"   highlight_matched_char  - Matched characters highlight
"   highlight_matched_range - matched range highlight
let s:denite_options = {'default' : {
\ 'auto_resize': 1,
\ 'prompt': 'λ:',
\ 'direction': 'rightbelow',
\ 'winminheight': '10',
\ 'highlight_mode_insert': 'Visual',
\ 'highlight_mode_normal': 'Visual',
\ 'prompt_highlight': 'Function',
\ 'highlight_matched_char': 'Function',
\ 'highlight_matched_range': 'Normal'
\ }}

" Loop through denite options and enable them
function! s:profile(opts) abort
  for l:fname in keys(a:opts)
    for l:dopt in keys(a:opts[l:fname])
      call denite#custom#option(l:fname, l:dopt, a:opts[l:fname][l:dopt])
    endfor
  endfor
endfunction

call s:profile(s:denite_options)

" === Coc.nvim === "
" use <tab> for trigger completion and navigate to next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

" Show all diagnostics
nnoremap <leader>cn  :<C-u>CocList diagnostics<cr>

"Close preview window when completion is done.
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

" === NeoSnippet === "
" Map <C-k> as shortcut to activate snippet if available
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)
xmap <C-k> <Plug>(neosnippet_expand_target)

" Load custom snippets from snippets folder
let g:neosnippet#snippets_directory='~/.config/nvim/snippets'

" Hide conceal markers
let g:neosnippet#enable_conceal_markers = 0

" === NERDTree === "
" Show hidden files/directories
let g:NERDTreeShowHidden = 1

" Remove bookmarks and help text from NERDTree
let g:NERDTreeMinimalUI = 1

" Custom icons for expandable/expanded directories
let g:NERDTreeDirArrowExpandable = '⬏'
let g:NERDTreeDirArrowCollapsible = '⬎'

" Hide certain files and directories from NERDTree
let g:NERDTreeIgnore = ['^\.DS_Store$', '^tags$', '\.git$[[dir]]', '\.idea$[[dir]]', '\.sass-cache$']

" Wrap in try/catch to avoid errors on initial install before plugin is available
try

" === Vim airline ==== "
" Enable extensions
let g:airline_extensions = ['branch', 'hunks', 'coc']

" Update section z to just have line number
" let g:airline_section_z = airline#section#create(['linenr'])

" Do not draw separators for empty sections (only for the active window) >
let g:airline_skip_empty_sections = 1

" Smartly uniquify buffers names with similar filename, suppressing common parts of paths.
let g:airline#extensions#tabline#formatter = 'unique_tail'

" Custom setup that removes filetype/whitespace from default vim airline bar
let g:airline#extensions#default#layout = [['a', 'b', 'c'], ['x', 'z', 'warning', 'error']]

let airline#extensions#coc#stl_format_err = '%E{[%e(#%fe)]}'

let airline#extensions#coc#stl_format_warn = '%W{[%w(#%fw)]}'

" Configure error/warning section to use coc.nvim
let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'

" Hide the Nerdtree status line to avoid clutter
let g:NERDTreeStatusline = ''

" Disable vim surround default keymapping
let g:surround_no_mappings = 1

" Disable vim-airline in preview mode
let g:airline_exclude_preview = 1

" Enable powerline fonts
let g:airline_powerline_fonts = 1

" Enable caching of syntax highlighting groups
let g:airline_highlighting_cache = 1

" Define custom airline symbols
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

" unicode symbols
let g:airline_left_sep = '❮'
let g:airline_right_sep = '❯'

" Don't show git changes to current file in airline
let g:airline#extensions#hunks#enabled=1

" Show window number
function! WindowNumber(...)
    let builder = a:1
    let context = a:2
    call builder.add_section('airline_b', '%{tabpagewinnr(tabpagenr())} ')
    return 0
endfunction

call airline#add_statusline_func('WindowNumber')
call airline#add_inactive_statusline_func('WindowNumber')

catch /.*/
  echo "Caught error: " . v:exception
  echo 'Airline not installed. It should work after running :PlugInstall'
endtry

" === echodoc === "
" Enable echodoc on startup
let g:echodoc#enable_at_startup = 1

" === vim-javascript === "
" Enable syntax highlighting for JSDoc
let g:javascript_plugin_jsdoc = 1

" === vim-jsx === "
" Highlight jsx syntax even in non .jsx files
let g:jsx_ext_required = 0

" === javascript-libraries-syntax === "
let g:used_javascript_libs = 'underscore,requirejs,chai,jquery'

" === Signify === "
let g:signify_sign_delete = '-'

" === Ack === "
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

" ============================================================================ "
" ===                                UI                                    === "
" ============================================================================ "

" Enable true color support
set termguicolors

" Editor theme
set background=dark
try
  colorscheme OceanicNext
catch
  colorscheme slate
endtry

" Vim airline theme
let g:airline_theme='distinguished'

" Add custom highlights in method that is executed every time a
" colorscheme is sourced
" See https://gist.github.com/romainl/379904f91fa40533175dfaec4c833f2f for
" details
function! MyHighlights() abort
  " Hightlight trailing whitespace
  highlight Trail ctermbg=red guibg=red
  call matchadd('Trail', '\s\+$', 100)
endfunction

augroup MyColors
  autocmd!
  autocmd ColorScheme * call MyHighlights()
augroup END

" Change vertical split character to be a space (essentially hide it)
set fillchars+=vert:.

" Set preview window to appear at bottom
set splitbelow

" Don't dispay mode in command line (airilne already shows it)
set noshowmode

" coc.nvim color changes
hi! link CocErrorSign WarningMsg
hi! link CocWarningSign Number
hi! link CocInfoSign Type

" Make background transparent for many things
hi! Normal ctermbg=NONE guibg=NONE
hi! NonText ctermbg=NONE guibg=NONE
hi! LineNr ctermfg=NONE guibg=NONE
hi! SignColumn ctermfg=NONE guibg=NONE
hi! StatusLine guifg=#16252b guibg=#6699CC
hi! StatusLineNC guifg=#16252b guibg=#16252b

" Try to hide vertical spit and end of buffer symbol
hi! VertSplit gui=NONE guifg=#17252c guibg=#17252c
hi! EndOfBuffer ctermbg=NONE ctermfg=NONE guibg=#17252c guifg=#17252c

" Customize NERDTree directory
hi! NERDTreeCWD guifg=#99c794

" Make background color transparent for git changes
hi! SignifySignAdd guibg=NONE
hi! SignifySignDelete guibg=NONE
hi! SignifySignChange guibg=NONE

" Highlight git change signs
hi! SignifySignAdd guifg=#99c794
hi! SignifySignDelete guifg=#ec5f67
hi! SignifySignChange guifg=#c594c5

" Call method on window enter
augroup WindowManagement
  autocmd!
  autocmd WinEnter * call Handle_Win_Enter()
augroup END

" Change highlight group of preview window when open
function! Handle_Win_Enter()
  if &previewwindow
    setlocal winhighlight=Normal:MarkdownError
  endif
endfunction

" ============================================================================ "
" ===                             KEY MAPPINGS                             === "
" ============================================================================ "
" === General shorcuts === "
" scroll faster
nnoremap <C-e> 5<C-e>
nnoremap <C-y> 5<C-y>

" Reload init.vim
nnoremap <leader>so :source $MYVIMRC<CR>

" Split windows
nnoremap <leader>w/ :vsplit<CR>
nnoremap <leader>w- :split<CR>

" Move between windows
:nnoremap <leader>ll <C-w><C-w>
:nnoremap <leader>hh <C-w>h

" Move between windows using number
nnoremap <silent> <leader> :exe nr2char(getchar()) . "wincmd w"<cr>

" map <leader>bd to :bd
:nnoremap <leader>bd :bd<CR>

" go to the previous file in buffer
:nnoremap <leader>bp :e#<CR>

" Always force write files
":nnoremap :w :w!<CR>
":nnoremap :we :w

" map jk to esc in insert mode
imap jk <Esc>

" map leader s to save
:nnoremap <leader>s :w<CR>

"=== Terminal mode ==="
:tnoremap jk <C-\><C-n>

"=== Ack ==="
cnoreabbrev Ack Ack!
nnoremap <leader>fw :Ack! --ignore-dir={dist,node_modules,js_packages/web/cypress/data}<Space>
nnoremap <leader>r :cdo s/// | update<left><left>

"=== Denite shorcuts === "
"   <leader>l - Browser currently open buffers
"   <leader>t - Browse list of files in current directory
"   <leader>g - Search current directory for occurences of given term and
"   close window if no results
"   <leader>j - Search current directory for occurences of word under cursor
nmap <leader>fl :Denite buffer -split=floating -winrow=1<CR>
nmap <leader>fg :Denite buffer file/rec -split=floating -winrow=1<CR>
nmap <leader>ff :DeniteBufferDir file -split=floating -winrow=1<CR>
nmap <leader>fr :Denite -resume<CR>
"nmap <leader>fw :Denite -buffer-name=project-grep -split=floating -winrow=1 grep:::!<CR>
nnoremap <leader>fh :DeniteBufferDir -buffer-name=bugger-grep -split=floating -winrow=1 grep:::!<CR>

"nnoremap <leader>pf :DeniteBufferDir -buffer-name=grep -split=floating -winrow=1 grep:::!<CR>
nnoremap <leader>fj :<C-u>DeniteCursorWord grep:. -mode=normal<CR>

" === Nerdtree shorcuts === "
"  <leader>n - Toggle NERDTree on/off
"  <leader>f - Opens current file location in NERDTree
"nmap <leader>n :NERDTreeToggle<CR>
"nmap <leader>f :NERDTreeFind<CR>

"   <Space> - PageDown
  " -       - PageUp
" noremap <Space> <PageDown>
" noremap - <PageUp>

" === coc.nvim === "
nmap <silent> <leader>dd <Plug>(coc-definition)
nmap <silent> <leader>dr <Plug>(coc-references)
nmap <silent> <leader>dj <Plug>(coc-implementation)

" === vim-better-whitespace === "
"   <leader>y - Automatically remove trailing whitespace
nmap <leader>y :StripWhitespace<CR>

" === Search shorcuts === "
"   <leader>h - Find and replace
"   <leader>/ - Claer highlighted search terms while preserving history
map <leader>h :%s///<left><left>
nmap <silent> <leader>/ :nohlsearch<CR>

" === Easy-motion shortcuts ==="
"   <leader>w - Easy-motion highlights first word letters bi-directionally
map <leader>w <Plug>(easymotion-bd-w)

" Allows you to save files you opened without write permissions via sudo
cmap w!! w !sudo tee %

" === vim-jsdoc shortcuts ==="
" Generate jsdoc for function under cursor
nmap <leader>z :JsDoc<CR>

" === vim-figitive === "
"   <leader>gitb - Git blame
nmap <leader>gb :Gblame
nnoremap <leader>gs :Gstatus<CR>

" === vim-deoplete === "
inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"

" Delete current visual selection and dump in black hole buffer before pasting
" Used when you want to paste over something without it getting copied to
" Vim's default buffer
vnoremap <leader>p "_dP

" === vim surrounding === "
nnoremap <leader>ss <Plug>Dsurround
nnoremap <leader>sys  <Plug>Ysurround

" === Open init.vim === "
command! Svim tabnew ~/.config/nvim/init.vim


command! Daily tabnew ~/Desktop/Dev/notes/daily.txt

" === Open todo.org === "
command! Todo tabnew ~/Desktop/Dev/notes/todo.org

" === Format Json === "
command! FormatJson %!python -m json.tool


" === Org mdoe === "
nnoremap <leader>oh <localleader>hN

" ============================================================================ "
" ===                                 MISC.                                === "
" ============================================================================ "

" Automaticaly close nvim if NERDTree is only thing left open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
autocmd Filetype python setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2

" === Search === "
" ignore case when searching
set ignorecase

" if the search string has an upper case letter in it, the search will be case sensitive
set smartcase

" Automatically re-read file if a change was detected outside of vim
set autoread

" Enable line numbers
set number

" Set backups
if has('persistent_undo')
  set undofile
  set undolevels=3000
  set undoreload=10000
endif
set backupdir=~/.local/share/nvim/backup " Don't put backups in current dir
set backup
set noswapfile

" Reload icons after init source
if exists('g:loaded_webdevicons')
  call webdevicons#refresh()
endif

" ============================================================================ "
" ===                                 Prettier.                                === "
" ============================================================================ "
let g:prettier#autoformat = 0
autocmd BufWritePre *.ts,*.tsx,*.js,*.jsx,*.mjs,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html Prettier
"autocmd BufWritePre *.ts,*.tsx PrettierAsync --parser babylon


" max line length that prettier will wrap on
" Prettier default: 80
"let g:prettier#config#print_width = 100

" number of spaces per indentation level
" Prettier default: 2
"let g:prettier#config#tab_width = 2

" print semicolons
" Prettier default: true
"let g:prettier#config#semi = 'true'

" single quotes over double quotes
" Prettier default: false
"let g:prettier#config#single_quote = 'true'

" print spaces between brackets
" Prettier default: true
"let g:prettier#config#bracket_spacing = 'false'

" put > on the last line instead of new line
" Prettier default: false
"let g:prettier#config#jsx_bracket_same_line = 'true'

" ============================================================================ "
" ===                                 Rust.                                === "
" ============================================================================ "
autocmd BufWritePre *.rs RustFmt

" ============================================================================ "
" ===                                 Tidal.                                === "
" ============================================================================ "
let g:tidal_target = "terminal"
" === Org mdoe === "
nnoremap <leader>tp <localleader>s

" ============================================================================ "
" ===                                 Coc.                                 === "
" ============================================================================ "
let g:coc_global_extensions = ['coc-tsserver']

" Remap keys for applying codeAction to the current line.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)
" Show autocomplete when Tab is pressed
inoremap <silent><expr> <Tab> coc#refresh()


" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
