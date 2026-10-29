" --- Basic Minimalist Settings ---
set nocompatible
syntax on
filetype plugin indent on

set number relativenumber
set signcolumn=yes
set hidden
set mouse=a
set termguicolors
set ignorecase smartcase
set incsearch hlsearch
set splitbelow splitright
set scrolloff=8
set updatetime=300
set completeopt=menuone,noinsert,noselect

" Indentation (4 spaces default for C/C++ and Python)
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab smartindent

" Reuse LSP binaries already installed by Mason (e.g. pyright-langserver)
let $PATH = expand('~/.local/share/nvim/mason/bin') . ':' . $PATH

" --- Drag Visual Selection Up/Down (Shift+J / Shift+K) ---
xnoremap <silent> J :m '>+1<CR>gv=gv
xnoremap <silent> K :m '<-2<CR>gv=gv

" --- Helper: Get Visual Selection ---
function! s:GetVisualSelection() abort
  let l:save_reg = getreg('"')
  let l:save_type = getregtype('"')
  noautocmd silent normal! ""y
  let l:text = substitute(getreg('"'), '\n', ' ', 'g')
  call setreg('"', l:save_reg, l:save_type)
  return l:text
endfunction

" --- File Tree (Ctrl+B) via built-in netrw ---
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_winsize = 20
nnoremap <silent> <C-b> <Cmd>Lexplore<CR>

" --- Fuzzy File Finder (Ctrl+P) via system fzf.vim ---
nnoremap <silent> <C-p> <Cmd>FZF<CR>

" --- Search Substring in Current File (Ctrl+F) ---
nnoremap <C-f> /\V
xnoremap <C-f> ""y/\V<C-r>=escape(substitute(@", '\n', ' ', 'g'), '\/')<CR>

" --- Search Substring in Project (Ctrl+Shift+F) via rg + fzf ---
function! s:OpenRgResult(line) abort
  let l:parts = matchlist(a:line, '^\(.\{-}\):\(\d\+\):\(\d\+\):')
  if !empty(l:parts)
    execute 'edit ' . fnameescape(l:parts[1])
    call cursor(str2nr(l:parts[2]), str2nr(l:parts[3]))
    normal! zz
  endif
endfunction

function! s:ProjectSearch(query) abort
  let l:rg_cmd = 'rg --column --line-number --no-heading --color=always --smart-case --fixed-strings -- '
  let l:initial = empty(a:query) ? 'true' : l:rg_cmd . fzf#shellescape(a:query) . ' || true'
  let l:reload = l:rg_cmd . '{q} || true'
  call fzf#run(fzf#wrap('rg', {
      \ 'source': l:initial,
      \ 'sink': function('s:OpenRgResult'),
      \ 'options': [
      \   '--ansi',
      \   '--disabled',
      \   '--query', a:query,
      \   '--prompt', 'Search> ',
      \   '--delimiter', ':',
      \   '--bind', 'change:reload:' . l:reload,
      \ ],
      \ }))
endfunction

nnoremap <silent> <C-S-f> <Cmd>call <SID>ProjectSearch('')<CR>
xnoremap <silent> <C-S-f> :<C-u>call <SID>ProjectSearch(<SID>GetVisualSelection())<CR>

" --- Multiple Cursors (Ctrl+J / Ctrl+K) via vim-visual-multi ---
let g:VM_maps = {}
let g:VM_maps['Add Cursor Down'] = '<C-j>'
let g:VM_maps['Add Cursor Up']   = '<C-k>'

let s:vm_dir = expand('~/.vim/pack/plugins/start/vim-visual-multi')
if !isdirectory(s:vm_dir)
  silent execute '!git clone --depth 1 https://github.com/mg979/vim-visual-multi ' . shellescape(s:vm_dir)
  packadd vim-visual-multi
endif

" --- Native Vim9 LSP (auto-bootstrapped, no plugin manager) ---
let s:lsp_dir = expand('~/.vim/pack/plugins/start/lsp')
if !isdirectory(s:lsp_dir)
  silent execute '!git clone --depth 1 https://github.com/yegappan/lsp ' . shellescape(s:lsp_dir)
  packadd lsp
endif

autocmd User LspSetup call LspOptionsSet({
    \ 'autoComplete': v:true,
    \ 'showDiagWithVirtualText': v:true,
    \ })

autocmd User LspSetup call LspAddServer([
    \ {
    \   'name': 'clangd',
    \   'filetype': ['c', 'cpp', 'objc', 'objcpp'],
    \   'path': 'clangd',
    \   'args': ['--background-index'],
    \ },
    \ {
    \   'name': 'pyright',
    \   'filetype': ['python'],
    \   'path': 'pyright-langserver',
    \   'args': ['--stdio'],
    \ },
    \ ])

" --- LSP Keybindings ---
nnoremap <silent> gd   <Cmd>LspGotoDefinition<CR>
nnoremap <silent> gD   <Cmd>LspGotoDeclaration<CR>
nnoremap <silent> gi   <Cmd>LspGotoImpl<CR>
nnoremap <silent> gr   <Cmd>LspShowReferences<CR>
nnoremap <silent> <F2> <Cmd>LspRename<CR>
nnoremap <silent> K    <Cmd>LspHover<CR>
nnoremap <silent> [d   <Cmd>LspDiagPrev<CR>
nnoremap <silent> ]d   <Cmd>LspDiagNext<CR>

" Completion menu navigation with Tab / Shift-Tab / Enter
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR>    pumvisible() ? "\<C-y>" : "\<CR>"
