{
  description = "vim with config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      rec {
        packages = with pkgs;  rec {
          devShell = buildEnv {
            name = "vim-with-config";
            paths = [
              nodePackages.prettier
              nodePackages.typescript-language-server
              nodePackages.stylelint
              vim-vint
              shfmt
              yamllint
              ripgrep
              fd
              (vim_configurable.customize {
                name = "vim-with-config";
                vimrcConfig = {
                  customRC = ''
                    if &encoding !=? 'utf-8'
                      let &termencoding = &encoding
                      setglobal encoding=utf-8
                    endif
                    scriptencoding utf-8

                    let g:loaded_rrhelper = 1
                    let g:did_install_default_menus = 1
                    let g:sh_noisk = 1

                    augroup vimRc
                      autocmd!
                    augroup END

                    " plugins config
                    " complete + lsp
                    packadd! vim-mucomplete
                    let g:mucomplete#enable_auto_at_startup = 1
                    let g:mucomplete#always_use_completeopt = 1
                    let g:lsc_server_commands = {
                          \ 'javascript': 'typescript-language-server --stdio',
                          \ 'typescript': 'typescript-language-server --stdio'
                          \ }
                    let g:lsc_auto_map = {
                          \ 'GoToDefinition': 'gd',
                          \ 'FindReferences': 'gr',
                          \ 'ShowHover': 'K',
                          \ 'FindCodeActions': 'ga',
                          \ 'Completion': 'omnifunc'
                          \ }
                    let g:lsc_enable_autocomplete  = v:true
                    let g:lsc_enable_diagnostics   = v:false
                    let g:lsc_reference_highlights = v:false
                    let g:lsc_trace_level          = 'off'

                    " navigation
                    packadd! vim-vinegar
                    let g:netrw_altfile = 1
                    let g:netrw_preview = 1
                    let g:netrw_altv = 1
                    let g:netrw_alto = 0
                    let g:netrw_use_errorwindow = 0
                    let g:netrw_localcopydircmd = 'cp -r'
                    let g:netrw_list_hide = '^\.\.\=/\=$'
                    function! s:innetrw() abort
                      nmap <buffer><silent> <right> <cr>
                      nmap <buffer><silent> <left> -
                      nmap <buffer> <c-x> mfmx
                    endfunction
                    autocmd vimRc FileType netrw call s:innetrw()

                    " fzf
                    packadd! fzf.vim
                    let $FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude plugged'
                    let $FZF_PREVIEW_COMMAND = 'bat --color=always --style=plain -n -- {} || cat {}'
                    let g:fzf_layout = {'window': { 'width': 0.7, 'height': 0.4,'yoffset':0.85,'xoffset': 0.5 } }
                    nnoremap <c-p> :Files<cr>
                    nnoremap <bs> :Buffers<cr>

                    " ale
                    packadd ale
                    let g:ale_disable_lsp = 1
                    let g:ale_sign_error = '• '
                    let g:ale_sign_warning = '• '
                    let g:ale_set_highlights = 0
                    let g:ale_lint_on_text_changed = 'normal'
                    let g:ale_lint_on_insert_leave = 1
                    let g:ale_lint_delay = 0
                    nmap <silent> [a <Plug>(ale_previous)
                    nmap <silent> ]a <Plug>(ale_next)
                    let g:ale_fixers = {
                        \   'javascript': ['eslint'],
                        \   'typescript': ['eslint'],
                        \   'css': ['stylelint'],
                        \   'json': ['fixjson'],
                        \   'sh': ['shfmt'],
                        \   'nix': ['nixpkgs-fmt']
                        \ }

                    " git-gutter
                    let g:gitgutter_sign_priority = 8
                    let g:gitgutter_override_sign_column_highlight = 0
                    nmap ghs <Plug>(GitGutterStageHunk)
                    nmap ghu <Plug>(GitGutterUndoHunk)
                    nmap ghp <Plug>(GitGutterPreviewHunk)

                    " editorconfig
                    let g:editorconfig_root_chdir = 1
                    let g:editorconfig_verbose    = 1
                    let g:editorconfig_blacklist  = {
                          \ 'filetype': ['git.*', 'fugitive'],
                          \ 'pattern': ['\.un~$']}

                    " undotree
                    packadd! undotree
                    let g:undotree_CustomUndotreeCmd = 'vertical 50 new'
                    let g:undotree_CustomDiffpanelCmd= 'belowright 12 new'
                    let g:undotree_SetFocusWhenToggle = 1
                    let g:undotree_ShortIndicators = 1

                    " asterisk
                    packadd! vim-asterisk
                    map *  <Plug>(asterisk-z*)
                    map #  <Plug>(asterisk-z#)
                    map g* <Plug>(asterisk-gz*)
                    map g# <Plug>(asterisk-gz#)

                    " cool
                    let g:CoolTotalMatches = 1
                    packadd! vim-cool

                    " fugitive
                    packadd! goyo.vim
                    let g:goyo_width = 300
                    nnoremap <leader><leader> :Goyo<cr>
                    packadd! vim-fugitive
                    nnoremap <leader>g :G <bar> Goyo<cr>

                    " packs
                    packadd! matchit
                    packadd! targets.vim
                    packadd! vim-commentary
                    packadd! vim-surround
                    packadd! vim-repeat
                    packadd! vim-rhubarb
                    packadd! traces.vim
                    packadd! vim-mergetool

                    filetype plugin indent on

                    " options
                    " set term=xterm-256color
                    set t_Co=256
                    set t_ut=
                    set t_md=
                    let &t_SI.="\e[6 q"
                    let &t_SR.="\e[4 q"
                    let &t_EI.="\e[2 q"

                    set path+=**
                    set autoread autowrite autowriteall
                    set noswapfile
                    set nowritebackup
                    set undofile undodir=/tmp//,.
                    set nostartofline
                    set nojoinspaces
                    set nofoldenable
                    set nowrap
                    set breakindent breakindentopt=shift:4,sbr
                    set noshowmode
                    set number
                    set relativenumber
                    set mouse=a ttymouse=sgr
                    set splitright splitbelow
                    set virtualedit=onemore
                    set scrolloff=0 sidescrolloff=10 sidescroll=1
                    set sessionoptions-=options
                    set sessionoptions-=blank
                    set sessionoptions-=help
                    set lazyredraw
                    set ttimeout timeoutlen=2000 ttimeoutlen=50
                    set updatetime=50
                    set incsearch hlsearch
                    set gdefault
                    set grepprg=rg\ --vimgrep
                    set completeopt-=preview
                    set completeopt+=menuone,noselect,noinsert
                    setg omnifunc=syntaxcomplete#Complete
                    setg completefunc=syntaxcomplete#Complete
                    set pumheight=10
                    set diffopt+=context:3,indent-heuristic,algorithm:patience
                    set list
                    set listchars=tab:⇥\ ,trail:•,nbsp:␣,extends:↦,precedes:↤
                    autocmd vimRc InsertEnter * set listchars-=trail:•
                    autocmd vimRc InsertLeave * set listchars+=trail:•
                    set confirm
                    set shortmess+=sIcaF
                    set shortmess-=S
                    set autoindent smartindent
                    set expandtab
                    set tabstop=2
                    set softtabstop=2
                    set shiftwidth=2
                    set shiftround
                    set history=1000
                    set wildmenu
                    set wildmode=list,full
                    set wildignorecase
                    set wildcharm=<C-Z>
                    set backspace=indent,eol,start
                    set laststatus=2
                    set statusline=%<%.99f\ %y%h%w%m%r%=%-14.(%l,%c%V%)\ %L

                    " mappings
                    " wrap
                    noremap j gj
                    noremap k gk
                    noremap <Down> gj
                    noremap <Up> gk
                    "redline
                    cnoremap <C-a> <Home>
                    cnoremap <C-e> <End>
                    inoremap <C-a> <Home>
                    inoremap <C-e> <End>
                    " paragraph
                    nnoremap } }zz
                    nnoremap { {zz
                    " close qf
                    nnoremap <silent> <C-w>z :wincmd z<Bar>cclose<Bar>lclose<CR>
                    " objects
                    xnoremap <expr> I (mode()=~#'[vV]'?'<C-v>^o^I':'I')
                    xnoremap <expr> A (mode()=~#'[vV]'?'<C-v>0o$A':'A')
                    xnoremap <silent> il <Esc>^vg_
                    onoremap <silent> il :<C-U>normal! ^vg_<cr>
                    xnoremap <silent> ie gg0oG$
                    onoremap <silent> ie :<C-U>execute "normal! m`"<Bar>keepjumps normal! ggVG<cr>
                    " Paste continuously.
                    nnoremap ]p viw"0p
                    vnoremap ]p "0p
                    " c-g improved
                    nnoremap <silent> <C-g> :echon '['.expand("%:p:~").']'.' [L:'.line('$').']'<Bar>echon ' ['system("git rev-parse --abbrev-ref HEAD 2>/dev/null \| tr -d '\n'")']'<CR>
                    " reload syntax and nohl
                    nnoremap <silent><expr> <C-l> empty(get(b:, 'current_syntax'))
                          \ ? "\<C-l>"
                          \ : "\<C-l>:syntax sync fromstart\<cr>:nohlsearch<cr>"
                    " execute macro
                    nnoremap Q <Nop>
                    nnoremap Q @q
                    " run macro on selected lines
                    vnoremap Q :norm Q<cr>
                    " jump to window no
                    for i in range(1, 9)
                      execute 'nnoremap <silent> <space>'.i.' :'.i.'wincmd w<CR>'
                    endfor
                    execute 'nnoremap <silent> <space>0 :wincmd p<CR>'
                    " jumping
                    function! Listjump(list_type, direction, wrap) abort
                      try
                        exe a:list_type . a:direction
                      catch /E553/
                        exe a:list_type . a:wrap
                      catch /E42/
                        return
                      catch /E163/
                        return
                      endtry
                      normal! zz
                    endfunction
                    nnoremap <silent> ]q :call Listjump("c", "next", "first")<CR>
                    nnoremap <silent> [q :call Listjump("c", "previous", "last")<CR>
                    nnoremap <silent> ]l :call Listjump("l", "next", "first")<CR>
                    nnoremap <silent> [l :call Listjump("l", "previous", "last")<CR>
                    " numbers
                    nnoremap <silent> <expr> <leader>n &relativenumber ? ':windo set norelativenumber<cr>' : ':windo set relativenumber<cr>'

                    " autocmds
                    " keep cursor position
                    autocmd vimRc BufReadPost *
                          \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
                          \ |   exe "normal! g`\""
                          \ | endif

                    " format
                    autocmd vimRc FileType nix setlocal makeprg=nix-instantiate\ --parse
                    autocmd vimRc FileType nix setlocal formatprg=nixpkgs-fmt
                    autocmd vimRc BufRead,BufNewFile *.nix command! FM silent call system('nixpkgs-fmt ' . expand('%'))
                    autocmd vimRc BufRead,BufNewFile *.js,*.jsx,*.ts,*.tsx command! FM silent call system('prettier --single-quote --trailing-comma none --write ' . expand('%'))
                    autocmd vimRc BufRead,BufNewFile *.js,*.jsx command! Fix silent call system('eslint --fix ' . expand('%'))
                    autocmd vimRc FileType yaml command! FM silent call system('prettier --write ' . expand('%'))
                    autocmd vimRc FileType sh command! FM silent call system('shfmt -i 2 -ci -w ' . expand('%'))

                    " help keep widow full width
                    autocmd vimRc FileType qf wincmd J
                    autocmd vimRc BufWinEnter * if &ft == 'help' | wincmd J | end

                    " update diff / disable paste
                    autocmd vimRc InsertLeave * if &diff | diffupdate | endif
                    autocmd vimRc InsertLeave * if &paste | setlocal nopaste | echo 'nopaste' | endif

                    " external changes
                    autocmd vimRc FocusGained,CursorHold *
                          \ if !bufexists("[Command Line]") |
                          \ checktime |
                          \ if exists('g:loaded_gitgutter') |
                          \   call gitgutter#all(1) |
                          \ endif

                    " mkdir
                    autocmd vimRc BufWritePre *
                          \ if !isdirectory(expand('%:h', v:true)) |
                          \   call mkdir(expand('%:h', v:true), 'p') |
                          \ endif

                    " git
                    autocmd vimRc FileType gitcommit setlocal spell | setlocal textwidth=72 | setlocal colorcolumn=+1

                    " filetypes
                    let g:markdown_fenced_languages = ['vim', 'ruby', 'html', 'javascript', 'css', 'bash=sh', 'sh']
                    autocmd vimRc BufReadPre *.md,*.markdown setlocal conceallevel=2 concealcursor=n
                    autocmd vimRc FileType javascript setlocal formatoptions-=c formatoptions-=r formatoptions-=o
                    autocmd vimRc BufNewFile,BufRead *.gitignore setfiletype gitignore
                    autocmd vimRc BufNewFile,BufRead config      setfiletype config
                    autocmd vimRc BufNewFile,BufRead *.lock      setfiletype config
                    autocmd vimRc BufNewFile,BufRead .babelrc    setfiletype json
                    autocmd vimRc BufNewFile,BufRead *.txt       setfiletype markdown
                    autocmd vimRc BufReadPre *.json  setlocal conceallevel=0 concealcursor=
                    autocmd vimRc BufReadPre *.json  setlocal formatoptions=
                    autocmd vimRc FileType git       setlocal nofoldenable

                    " commands
                    command! -nargs=0 BO silent! execute "%bd|e#|bd#"
                    command BD bp | bd #
                    command! -nargs=0 WS %s/\s\+$// | normal! ``
                    command! -nargs=0 WT %s/[^\t]\zs\t\+/ / | normal! ``
                    command! WW w !sudo tee % > /dev/null
                    command! -bar HL echo
                          \ synIDattr(synID(line('.'),col('.'),0),'name')
                          \ synIDattr(synIDtrans(synID(line('.'),col('.'),1)),'name')

                    " functions
                    " grep
                    function! Grep(...)
                      return system(join([&grepprg] + [expandcmd(join(a:000, ' '))], ' '))
                    endfunction

                    command! -nargs=+ -complete=file_in_path -bar Grep  cgetexpr Grep(<f-args>)
                    command! -nargs=+ -complete=file_in_path -bar LGrep lgetexpr Grep(<f-args>)

                    cnoreabbrev <expr> grep  (getcmdtype() ==# ':' && getcmdline() ==# 'grep')  ? 'Grep'  : 'grep'
                    cnoreabbrev <expr> lgrep (getcmdtype() ==# ':' && getcmdline() ==# 'lgrep') ? 'LGrep' : 'lgrep'

                    autocmd vimRc QuickFixCmdPost cgetexpr cwindow
                    autocmd vimRc QuickFixCmdPost lgetexpr lwindow

                    " commit messages
                    let s:git_commit_prefix_candidates = [
                        \ {'word': 'feat: ', 'menu': 'Production - adding a new feature'},
                        \ {'word': 'fix: ', 'menu': 'Production - bug fixes'},
                        \ {'word': 'build: ', 'menu': 'Build related changes such as updating build tasks, package manager configs, etc'},
                        \ {'word': 'style: ', 'menu': 'Development - white-space, formatting, missing semi-colons, etc'},
                        \ {'word': 'refactor: ', 'menu': 'Development - removing redundant code, simplifying the code, renaming variables, etc'},
                        \ {'word': 'perf: ', 'menu': 'Production - changes such as performance improvements'},
                        \ {'word': 'test: ', 'menu': 'Refactoring existing tests or adding new tests'},
                        \ {'word': 'docs: ', 'menu': 'Documentation related changes'}]
                    function! GitcommitPrefixCandidates()
                      if empty(getline(1))
                        call complete(col('.'), s:git_commit_prefix_candidates)
                      endif
                      return '''
                    endfunc
                    autocmd vimRc FileType g*commit startinsert | call feedkeys("\<C-R>=GitcommitPrefixCandidates()\<CR>")

                    " sessions
                    if empty(glob('~/.cache/vim/sessions')) > 0
                      call mkdir(expand('~/.cache/vim/sessions'), 'p')
                    end
                    autocmd! vimRc VimLeavePre * execute "mksession! ~/.cache/vim/sessions/" . split(getcwd(), "/")[-1] . ".vim"
                    command! -nargs=0 SS :execute 'source ~/.cache/vim/sessions/' .  split(getcwd(), '/')[-1] . '.vim'

                    syntax enable
                    colorscheme seoul256
                  '';
                  packages.pack = with pkgs.vimPlugins; {
                    start = [
                      vim-lsc vim-gitgutter vim-nix vim-jsx-pretty
                      vim-javascript editorconfig-vim quickfix-reflector-vim
                    ];
                    opt = [
                      vinegar fzf-vim ale vim-mucomplete targets-vim
                      vim-highlightedyank commentary surround repeat vim-mergetool
                      fugitive rhubarb traces-vim vim-cool vim-asterisk goyo-vim undotree seoul256-vim
                    ];
                  };
                };
              })
            ];
          };
        };
        defaultPackage = packages.devShell;
      }
    );
}
