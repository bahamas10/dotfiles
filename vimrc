" ---------------------------------------------
" Dave Eddy's vimrc
" dave@daveeddy.com
" License MIT
"
" Credits
"   https://github.com/Happy-Dude/
" ---------------------------------------------
set nocompatible		" Disable VI Compatibility

" ---------------------------------------------
" Init - pathogen
" ---------------------------------------------
filetype off			" Turn filetype plugin off until Pathogen loads

runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()
syntax on

" ---------------------------------------------
" Vim Options
" ---------------------------------------------
set backspace=indent,eol,start	" Backspace all characters
set hlsearch			" Highlight search results
set nonumber			" Disable line numbers
set nostartofline		" Do not jump to first character with page commands
set ruler			" Enable the ruler
set showmatch			" Show matching brackets.
set showmode			" Show the current mode in status line
set showcmd			" Show partial command in status line
set tabstop=8			" Number of spaces <tab> counts for
set title			" Set the title

" ---------------------------------------------
" Theme / Color Scheme
" ---------------------------------------------
set background=light            " Light background is best

" ---------------------------------------------
" Distribution Specific Options
" ---------------------------------------------
runtime! debian.vim

" ---------------------------------------------
" Abbreviations
" ---------------------------------------------
iab me:: Dave Eddy <dave@daveeddy.com>

" ---------------------------------------------
" File/Indenting and Syntax Highlighting
" ---------------------------------------------
filetype plugin indent on
set autoindent
if has("autocmd")
	" Jump to previous cursor location, unless it's a commit message
	autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
	autocmd BufReadPost COMMIT_EDITMSG exe "normal! gg"

	" Puppet Manifests
	autocmd BufNewFile,BufReadPre,FileReadPre   *.pp   set filetype=puppet
	autocmd filetype                            puppet set ts=2 sw=2 sts=2 et

	" Chef/Ruby
	autocmd BufNewFile,BufReadPre,FileReadPre   *.rb set filetype=ruby
	autocmd filetype                            ruby set ts=2 sw=2 sts=2 et

	" JavaScript files
	autocmd BufNewFile,BufReadPre,FileReadPre   *.json,*.js set filetype=javascript
	autocmd filetype                            javascript  set ts=2 sw=2 sts=2 et

	" Objective C / C++
	autocmd BufNewFile,BufReadPre,FileReadPre   *.m    set filetype=objc
	autocmd filetype                            objc   set ts=4 sw=4 sts=4 et
	autocmd BufNewFile,BufReadPre,FileReadPre   *.mm   set filetype=objcpp
	autocmd filetype                            objcpp set ts=4 sw=4 sts=4 et

	" Python files
	autocmd BufNewFile,BufReadPre,FileReadPre   *.py   set filetype=python
	autocmd filetype                            python set ts=4 sw=4 sts=4 et

	" Markdown files
	autocmd BufNewFile,BufRead,FileReadPre      *.md,*.markdown set filetype=ghmarkdown
	autocmd filetype                            ghmarkdown      set ts=4 sw=4 sts=4 et spell
	" Jekyll posts ignore yaml headers
	"autocmd BufNewFile,BufRead                  */_posts/*.md syntax match Comment /\%^---\_.\{-}---$/
	"autocmd BufNewFile,BufRead                  */_posts/*.md syntax region lqdHighlight start=/^{%\s*highlight\(\s\+\w\+\)\{0,1}\s*%}$/ end=/{%\s*endhighlight\s*%}/

	" EJS javascript templates
	autocmd BufNewFile,BufRead,FileReadPre      *.ejs set filetype=html
endif

" ---------------------------------------------
" Highlight Unwanted Whitespace
" ---------------------------------------------
highlight RedundantWhitespace ctermbg=green guibg=green
match RedundantWhitespace /\s\+$\| \+\ze\t/

" ---------------------------------------------
" Spell Check Settings
" ---------------------------------------------
set spelllang=en
highlight clear SpellBad
highlight SpellBad term=standout cterm=underline ctermfg=red
highlight clear SpellCap
highlight SpellCap term=underline cterm=underline
highlight clear SpellRare
highlight SpellRare term=underline cterm=underline
highlight clear SpellLocal
highlight SpellLocal term=underline cterm=underline

" ---------------------------------------------
" Source local config
" ---------------------------------------------
if filereadable(expand("~/.vimrc.local"))
	source ~/.vimrc.local
endif
