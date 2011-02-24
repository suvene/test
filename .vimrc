"***********************************************************
"let $LANG='ja'
" vim 設定
"   @see http://www15.ocn.ne.jp/~tusr/vim/vim_text2.html
"   @see http://d.hatena.ne.jp/yuroyoro/20101104/1288879591
"---------------------------------------

"---------------------------------------
" 初期設定 {{{
"---------------------------------------
" 日本語設定(encode_japan.vim)
"   - iconv.dll配布サイト (日本語ドキュメント有り)
"       http://www.kaoriya.net/
"   - libiconv開発サイト(Bruno Haible氏)
"       http://sourceforge.net/cvs/?group_id=51585
"       http://ftp.gnu.org/pub/gnu/libiconv/
if &encoding !=? 'utf-8'
    set encoding=japan
    set fileencoding=japan
endif
if has('iconv')
    let s:enc_cp932 = 'cp932'
    let s:enc_eucjp = 'euc-jp'
    let s:enc_jisx = 'iso-2022-jp'
    let s:enc_utf8 = 'utf-8'
    let s:enc_utf7 = 'utf-7'
    " http://www.kawaz.jp/pukiwiki/?vim
    " iconvがeucJP-msに対応しているかをチェック
    if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
        let s:enc_eucjp = 'euc-jp-ms,euc-jp'
        let s:enc_jisx = 'iso-2022-jp-3,iso-2022-jp'
        " 比較的新しいJISX0213をサポートしているか検査する。euc-jisx0213が定義している
        " 範囲の文字をcp932からeuc-jisx0213へ変換できるかどうかで判断する。
    elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
        let s:enc_eucjp = 'euc-jisx0213,euc-jp'
        let s:enc_jisx = 'iso-2022-jp-3,iso-2022-jp'
    else
        let s:enc_eucjp = 'euc-jp'
        let s:enc_jisx = 'iso-2022-jp'
    endif
    let value = 'ucs-bom,ucs-2le,ucs-2'
    if &encoding ==? 'utf-8'
        "        let value = value . ',' . s:enc_jisx . ',' . s:enc_cp932 . ',' . s:enc_eucjp . ',' . s:enc_utf7
        let value = s:enc_jisx . ',' . s:enc_eucjp . ',' . s:enc_cp932 . ',' . s:enc_utf8 . ',' . value
    elseif &encoding ==? 'cp932'
        let value = value . ',' . s:enc_jisx . ',' . s:enc_utf8 . ',' . s:enc_eucjp . ',' . s:enc_utf7
    elseif &encoding ==? 'euc-jp'  || &encoding ==? 'euc-jisx0213'|| &encoding ==? 'eucjp-ms'
        let value = value . ',' . s:enc_jisx . ',' . s:enc_utf8 . ',' . s:enc_cp932 . ',' . s:enc_utf7
        let &encoding = s:enc_eucjp
        let &fileencoding = s:enc_eucjp
    else
        " TODO: 必要ならばその他のエンコード向けの設定をココに追加する
        let value = &fileencodings . ',' . s:enc_eucjp
    endif
    if has('guess_encode') | let value = 'guess,' . value | endif
    let &fileencodings = value . ',' . &fileencodings
else
    set encoding=utf-8
    set fileencodings=usc-bom,ucs-2le,ucs-2,cp932,euc-jp
endif
" □とか○の文字があってもカーソル位置がずれないようにする
if exists('&ambiwidth') | set ambiwidth=double | endif

" ファイル名に大文字小文字の区別がないシステム用の設定:
"   (例: DOS/Windows/MacOS)
if filereadable($VIM . '/vimrc') && filereadable($VIM . '/ViMrC')
    " tagsファイルの重複防止
    set tags=./tags,tags
endif

" コンソールでのカラー表示のための設定(暫定的にUNIX専用)
if has('unix') && !has('gui_running')
    let uname = system('uname')
    if uname =~? "linux"
        set term=builtin_linux
    elseif uname =~? "freebsd"
        set term=builtin_cons25
    elseif uname =~? "Darwin"
        "set term=beos-ansi
        set term=builtin_xterm
    else
        set term=builtin_xterm
    endif
    unlet uname
endif

" コンソール版で環境変数$DISPLAYが設定されていると起動が遅くなる件へ対応
if !has('gui_running') && has('xterm_clipboard')
    set clipboard=exclude:cons\\\|linux\\\|cygwin\\\|rxvt\\\|screen
endif

" プラットホーム依存の特別な設定
" WinではPATHに$VIMが含まれていないときにexeを見つけ出せないので修正
if has('win32') && $PATH !~? '\(^\|;\)' . escape($VIM, '\\') . '\(;\|$\)'
    let $PATH = $VIM . ';' . $PATH
endif
if has('mac')
    " Macではデフォルトの'iskeyword'がcp932に対応しきれていないので修正
    set iskeyword=@,48-57,_,128-167,224-235
endif

"---------------------------------------
" vimrc_example.vim {{{
"---------------------------------------
" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible
if has("vms")
    set nobackup      " do not keep a backup file, use versions instead
else
    set backup        " keep a backup file
endif
set history=100     " keep 100 lines of command line history
set ruler       " show the cursor position all the time
set incsearch       " do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" In many terminal emulators the mouse works just fine, thus enable it.
set mouse=a

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
    syntax on
    set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

    " Enable file type detection.
    " Use the default filetype settings, so that mail gets 'tw' set to 72,
    " 'cindent' is on in C files, etc.
    " Also load indent files, to automatically do language-dependent indenting.
    filetype plugin indent on

    " Put these in an autocmd group, so that we can delete them easily.
    augroup vimrcEx
        au!

        " For all text files set 'textwidth' to 78 characters.
        autocmd FileType text setlocal textwidth=78

        " When editing a file, always jump to the last known cursor position.
        " Don't do it when the position is invalid or when inside an event handler
        " (happens when dropping a file on gvim).
        autocmd BufReadPost *
                    \ if line("'\"") > 0 && line("'\"") <= line("$") |
                    \   exe "normal! g`\"" |
                    \ endif

    augroup END

else

    set autoindent        " always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
            \ | wincmd p | diffthis
" }}} /vimrc_example.vim

" }}} /初期設定
"---------------------------------------

"---------------------------------------
" 表示系 {{{
"---------------------------------------
" タイトルを表示
set title
" 行番号を表示
set number
" タブや改行を('listchars' の設定を利用して)表示
set list
"set listchars=tab:>-,trail:c
set listchars=tab:>-
" 長い行を折り返して表示 (nowrap:折り返さない)
set wrap
" 常にステータス行を表示 (詳細は:he laststatus)
set laststatus=2
" ステータスバーのフォーマット
set statusline=%f%m%=%-25(%l/%L,%c(%P)%)[%{&fileencoding}][%{&fileformat}]%H%W%y
" hlserch の hilight を消す
nmap <Esc><Esc> ;nohlsearch<CR><Esc>
" http://d.hatena.ne.jp/kasahi/20070902/1188744907
highlight WhitespaceEOL ctermbg=red guibg=red          
match WhitespaceEOL /\s\+$/
autocmd WinEnter * match WhitespaceEOL /\s\+$/

" カーソル行をハイライト
set cursorline
" カレントウィンドウにのみ罫線を引く
augroup cch
  autocmd! cch
  autocmd WinLeave * set nocursorline
  autocmd WinEnter,BufRead * set cursorline
augroup END
":hi clear CursorLine
":hi CursorLine gui=underline
"highlight CursorLine ctermbg=black guibg=black
" }}} /表示系
"---------------------------------------

"---------------------------------------
" 編集系 {{{
"---------------------------------------
set tabstop=4
set shiftwidth=4
" タブをスペースに展開する
set expandtab
" バックスペースでインデントや改行を削除できるようにする
set backspace=2 " indent,eol,start
" テキスト挿入中の自動折り返しを日本語に対応させる
set formatoptions+=mM
" 括弧入力時に対応する括弧を表示 (noshowmatch:表示しない)
set showmatch
" 日本語整形スクリプト(by. 西岡拓洋さん)用の設定
let format_allow_over_tw = 1 " ぶら下り可能幅
" C-a で8進数の計算をしない
set nrformats-=octal
" foldする種類(manual, indent, expr, marker, syntax, diff)
set foldmethod=marker

" }}} /編集系
"---------------------------------------

"---------------------------------------
" 検索系 {{{
"---------------------------------------
" 検索時に大文字小文字を無視 (noignorecase:無視しない)
set ignorecase

" 大文字小文字の両方が含まれている場合は大文字小文字を区別
set smartcase

" 検索時にファイルの最後まで行ったら最初に戻る (nowrapscan:戻らない)
set wrapscan

" Ctrl-i でヘルプ
nnoremap <C-i> :<C-u>help<Space>
" カーソル下のキーワードをヘルプでひく
nnoremap <C-i><C-i> :<C-u>help<Space><C-r><C-w><Enter>
" }}} /検索系
"---------------------------------------

"---------------------------------------
" 動作系 {{{
"---------------------------------------
set visualbell
" 選択した文字をクリップボードに入れる
set clipboard=unnamed
" 保存していなくても別のファイルを表示できるようにする
set hidden
" コマンドライン補完するときに('wildchar'で指定されたものを利用して)強化されたものを使う(参照 :help wildmenu)
set wildmenu
" backupを1箇所に
set backupdir=$HOME/backup/vim
" swap
let &directory = &backupdir
" ファイル名だけで開けるようにするパス
"let &path += "/etc,/var/log,/var/log/httpd"

" Exploler設定
" パラメータ無しで開くディレクトリ
"set browsedir=last    " 前回にファイルブラウザを使ったディレクト
set browsedir=buffer " バッファで開いているファイルのディレクトリ
"set browsedir=current   " カレントディレクトリ
"set browsedir={&path}   " {path} で指定されたディレクトリ
" 開いているファイルをカレントディレクトリにする
" 編集中のファイルに移動するには :cd %:h
if has("autcmd")
    au BufEnter * execute ":lcd " . expand("%:p:h")
endif
" set filetype
autocmd FileType yaml set expandtab ts=2 sw=2 enc=utf-8 fenc=utf-8
autocmd BufNewFile,BufRead svk-commit*.tmp set enc=utf-8 fenc=utf-8 ft=svk
autocmd BufNewFile,BufRead COMMIT_EDITMSG set enc=utf-8 fenc=utf-8 ft=gitcommit
" }}} /動作系
"---------------------------------------

"---------------------------------------
" keymaps {{{
"---------------------------------------
" ; ; 入れ替え
noremap ; :
noremap : ;

" @see http://www15.ocn.ne.jp/~tusr/vim/vim_text2.html#mozTocId672287
" マーク位置へのジャンプを行だけでなく桁位置も復元できるようにする
map ' `

" Ctrl+Nで次のバッファを表示
map <C-N> ;bnext<CR>

" Ctrl+Pで前のバッファを表示
map <C-P> ;bprevious<CR>

" Ctrl+Shift+Jで上に表示しているウィンドウをスクロールさせる
"nnoremap <C-S-J> <C-W>k<C-E><C-W><C-W>
"nnoremap <C-S-K> <C-W>k<C-Y><C-W><C-W>
"
" j/k
nmap j gj
nmap k gk

" J/K で半画面移動
nmap J <C-d>
nmap K <C-u>

" 挿入モードでCtrl+kを押すとクリップボードの内容を貼り付けられるようにする
imap <C-K> <ESC>"*pa

" command line
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-d> <Del>
cnoremap <C-M-b> <S-Left>
cnoremap <C-M-f> <S-Right>

" CTRL-hjklでウィンドウ移動
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h

" text-objects
" vbで{}の選択
nnoremap vb ?{<CR>%v%0
nmap vac $?\%(.*#.*class\)\@!class<CR>%V%0oj
" keymaps }}}
"--------------------------------------

"---------------------------------------
" for plugins {{{
"---------------------------------------
" pathogen.vim http://d.hatena.ne.jp/yuroyoro/20101104/1288879591 {{{
"  http://www.vim.org/scripts/script.php?script_id=2332
"  https://github.com/tpope/vim-pathogen
" pathogenでftdetectなどをloadさせるために一度ファイルタイプ判定をoff
filetype off
" pathogen.vimによってbundle配下のpluginをpathに加える
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()
set helpfile=$VIMRUNTIME/doc/help.txt
" ファイルタイプ判定をon
filetype on
"}}}

" autodate.vim"{{{
" let g:autodate_format = '%Y/%m/%d %H:%M:%S'
"}}}

" minibufexpl.vim"{{{
"   http://www.vim.org/scripts/script.php?script_id=159
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBuffs = 1
" GNU screen likeなキーバインド
let mapleader = "^F"
nnoremap <Leader><Space> :MBEbn<CR>
nnoremap <Leader>n       :MBEbn<CR>
nnoremap <Leader><C-n>   :MBEbn<CR>
nnoremap <Leader>p       :MBEbp<CR>
nnoremap <Leader><C-p>   :MBEbp<CR>
nnoremap <Leader>c       :new<CR>
nnoremap <Leader><C-c>   :new<CR>
nnoremap <Leader>k       :bd<CR>
nnoremap <Leader><C-k>   :bd<CR>
nnoremap <Leader>s       :IncBufSwitch<CR>
nnoremap <Leader><C-s>   :IncBufSwitch<CR>
nnoremap <Leader><Tab>   :wincmd w<CR>
nnoremap <Leader>Q       :only<CR>
nnoremap <Leader>w       :ls<CR>
nnoremap <Leader><C-w>   :ls<CR>
nnoremap <Leader>a       :e #<CR>
nnoremap <Leader><C-a>   :e #<CR>
nnoremap <Leader>"       :BufExp<CR>
nnoremap <Leader>1   :e #1<CR>
nnoremap <Leader>2   :e #2<CR>
nnoremap <Leader>3   :e #3<CR>
nnoremap <Leader>4   :e #4<CR>
nnoremap <Leader>5   :e #5<CR>
nnoremap <Leader>6   :e #6<CR>
nnoremap <Leader>7   :e #7<CR>
nnoremap <Leader>8   :e #8<CR>
nnoremap <Leader>9   :e #9<CR>
"}}}

" surround.vim via. http://d.hatena.ne.jp/secondlife/20061225/1167032528"{{{
"   http://www.vim.org/scripts/script.php?script_id=1697
" via. http://webtech-walker.com/archive/2009/02/08031540.html
" [key map]
" 1 : <h1>|</h1>
" 2 : <h2>|</h2>
" 3 : <h3>|</h3>
" 4 : <h4>|</h4>
" 5 : <h5>|</h5>
" 6 : <h6>|</h6>
"
" p : <p>|</p>
" u : <ul>|</ul>
" o : <ol>|</ol>
" l : <li>|</li>
" a : <a href="">|</a>
" A : <a href="|"></a>
" i : <img src="|" alt="" />
" I : <img src="" alt"|" />
" d : <div>|</div>
" D : <div class="section">|</div>

"autocmd FileType html let b:surround_49  = "<h1>\r</h1>"
autocmd FileType html call SurroundRegister('g', '3', "<h3>\r</h3>")
autocmd FileType html call SurroundRegister('g', '4', "<h4>\r</h4>")

" http://vim-users.jp/2009/11/hack105/
autocmd BufNewFile,BufRead * call SurroundRegister('g', 'jk', "「\r」")
autocmd BufNewFile,BufRead * call SurroundRegister('g', 'jK', "『\r』")
autocmd BufNewFile,BufRead * call SurroundRegister('g', 'js', "【\r】")
"}}}

" keisen.vim"{{{
"   http://www.vector.co.jp/soft/unix/writing/se266948.html
" 半角/全角の罫線を描く Vim スクリプトです。
" :Keisen で起動すれば、半角文字(+,－,|)です( 設定変更可 )。
" :Keisen -z で起動すれば全角文字です。
" :Keisen -Z で起動すれば太字です。
" hjkl キーで、罫線が描けるようになります。
" <Space> キーを押すと消去モードになります。
" <ESC> でキーマップが標準に戻ります。
" 詳しくは、:Keisen --help してください。
"}}}

" commentout.vim http://nanasi.jp/articles/vim/commentout_source.html"{{{
"}}}

" eregex.vim via. http://d.hatena.ne.jp/secondlife/20060203/1138978661"{{{
"   http://www.vector.co.jp/soft/unix/writing/se265654.html
"   http://www.vim.org/scripts/script.php?script_id=3282
"   http://github.com/othree/eregex.vim
if (has('gui_running'))
  noremap / ;M/
  noremap ,/ /
else
"  noremap / ;M/
"  noremap ,/ ;M/
endif
"}}}

" grep.vim via. http://d.hatena.ne.jp/secondlife/20060203/1138978661"{{{
"   http://blog.blueblack.net/item_199
"   http://www.vim.org/scripts/script.php?script_id=311
" let Grep_Path = 'C:\GnuWin32\bin\grep.exe'
" let Fgrep_Path = 'C:\GnuWin32\bin\grep.exe -F'
" let Egrep_Path = 'C:\GnuWin32\bin\grep.exe -E'
" let Grep_Find_Path = 'C:\GnuWin32\bin\find.exe'
" let Grep_Xargs_Path = 'C:\GnuWin32\bin\xargs.exe'
let Grep_Shell_Quote_Char = '"'
let Grep_Skip_Dirs = '.svn .git'
let Grep_Skip_Files = '*.bak *~'

" http://d.hatena.ne.jp/yuroyoro/20101104/1288879591#c
" :Gb <args> でGrepBufferする
command! -nargs=1 Gb :GrepBuffer <args>
" " カーソル下の単語をGrepBufferする
nnoremap <C-g><C-b> :<C-u>GrepBuffer<Space><C-r><C-w><Enter>
"}}}

" mru.vim via. http://d.hatena.ne.jp/secondlife/20060203/1138978661"{{{
"   http://nanasi.jp/articles/vim/mru_vim.html
"   http://www.vim.org/scripts/script.php?script_id=521
"   https://github.com/ornicar/vim-mru
let g:MRU_Max_Entries=50 " default 10
let g:MRU_Exclude_Files="^/tmp/.*\|^/var/tmp/.*"
let g:MRU_Window_Height=15 " default 8
let g:MRU_Use_Current_Window=0
let g:MRU_Auto_Close=1
map <C-@> ;MRU<CR>
"}}}

" blockdiff.vim http://nanasi.jp/articles/vim/blockdiff_vim.html"{{{
"   http://www.vim.org/scripts/script.php?script_id=2048
"}}}

" vimshell"{{{
"   https://github.com/Shougo/vimshell
" vimproc
"   https://github.com/Shougo/vimproc
"}}}

" for plugins }}}
"---------------------------------------

"im: set ts=4 sts=4 sw=4 tw=0 et:

