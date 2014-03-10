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
set number			" Enable line numbers
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
"set background=dark            " Light background is best
set background=light            " Light background is best
"colorscheme Tomorrow-Night      " https://github.com/chriskempson/tomorrow-theme

" ---------------------------------------------
" Distribution Specefic Options
" ---------------------------------------------
runtime! debian.vim

" ---------------------------------------------
" Abbreviations
" ---------------------------------------------
iab me:: Dave Eddy <dave@daveeddy.com>

" ---------------------------------------------
" File/Indenting and Syntax Highlighting
" ---------------------------------------------
if has("autocmd")
	" Jump to previous cursor location
	au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

	" Enable filetype indenting
	filetype plugin indent on
	set autoindent

	" Puppet manifests
	autocmd BufNewFile,BufReadPre,FileReadPre   *.pp set ts=2 sw=2 sts=2 et filetype=puppet

	" Chef/Ruby
	autocmd filetype                            ruby set ts=2 sw=2 sts=2 et

	" JavaScript files
	autocmd BufNewFile,BufReadPre,FileReadPre   *.json,*.js set filetype=javascript
	autocmd filetype                            javascript  set ts=2 sw=2 sts=2 et

	" Objective C / C++
	autocmd BufNewFile,BufReadPre,FileReadPre   *.m set filetype=objc
	autocmd filetype                            objc set ts=4 sw=4 sts=4 et
	autocmd BufNewFile,BufReadPre,FileReadPre   *.mm set filetype=objcpp
	autocmd filetype                            objcpp set ts=4 sw=4 sts=4 et

	" Python files
	autocmd BufNewFile,BufReadPre,FileReadPre   *.py   set filetype=python
	autocmd filetype                            python set ts=4 sw=4 sts=4 et

	" Markdown files
	autocmd BufNewFile,BufRead,FileReadPre      *.md     set filetype=markdown
	autocmd filetype                            markdown set ts=4 sw=4 sts=4 et spell
	autocmd BufNewFile,BufRead                  */_posts/*.md syntax match Comment /\%^---\_.\{-}---$/
	autocmd BufNewFile,BufRead                  */_posts/*.md syntax region lqdHighlight   start=/^{%\s*highlight\(\s\+\w\+\)\{0,1}\s*%}$/ end=/{%\s*endhighlight\s*%}/

	" EJS javascript templates
	autocmd BufNewFile,BufRead,FileReadPre      *.md     set filetype=html

	"highlight clear SpellBad
	"highlight SpellBad cterm=underline ctermfg=red
endif

" ---------------------------------------------
" Highlight Unwanted Whitespace
" ---------------------------------------------
highlight RedundantWhitespace ctermbg=green guibg=green
match RedundantWhitespace /\s\+$\| \+\ze\t/

" ---------------------------------------------
" Source local config
" ---------------------------------------------
if filereadable(expand("~/.vimrc.local"))
	source ~/.vimrc.local
endif
