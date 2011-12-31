# Dave Eddy <dave@daveeddy.com>
# My default bashrc file

# If not running interactively, don't do anything
[[ -z "$PS1" ]] && return

# Set environment
export HISTCONTROL=ignoredups
export PATH=$PATH:$HOME/bin
export VISUAL='vim'
export EDITOR='vim'
export PAGER='less'
export GREP_COLOR='1;36'

shopt -s extglob
shopt -s checkwinsize

alias l='ls -CF'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias chomd='chmod'
alias gerp='grep'
alias cdir='cd $(dirname $_)'

# Set the prompt
function __fancy_prompt() {
	# In a function to not clobber namespace
	local black=$(tput setaf 0)
	local red=$(tput setaf 1)
	local green=$(tput setaf 2)
	local yellow=$(tput setaf 3)
	local blue=$(tput setaf 4)
	local magenta=$(tput setaf 5)
	local cyan=$(tput setaf 6)
	local white=$(tput setaf 7)
	local bold=$(tput bold)
	local reset=$(tput sgr0)

	if (( $UID == 0 )); then
		PS1="\[$bold\]\[$red\]\u\[$reset\]@\h \[$bold\]\w \[$reset\]\\$  \[$green\]"
	else
		PROMPT_COMMAND='(( $? == 0 )) && _DOLLAR="$(tput setaf 2)" || _DOLLAR="$(tput setaf 1)"'
		PS1="\[$bold\]\[$green\]\u\[$reset\]\[$cyan\]@\[$red\][\h]\[$reset\]:\[$cyan\]\w\["'$_DOLLAR'"\]\\$ \[$reset\]"
	fi
}
__fancy_prompt

# Enable color support of ls
[[ "$(uname)" == "Darwin" ]] && _opt='-G'
if [[ "$TERM" != "dumb" ]] && [[ -x /usr/bin/dircolors ]]; then
	eval "$(dircolors -b)"
	alias ls="ls -p --color=auto"
else # dumb terminal
	alias ls="ls -p $_opt"
fi
unset _opt

# Load external files
[[ -f /etc/bash_completion ]] && . /etc/bash_completion || true
[[ -f ~/.bash_aliases ]]      && . ~/.bash_aliases      || true
[[ -f ~/.bashrc.local ]]      && . ~/.bashrc.local      || true
