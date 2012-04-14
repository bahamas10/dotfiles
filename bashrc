#
# Custom bashrc
# Dave Eddy <dave@daveeddy.com>
#

# If not running interactively, don't do anything
[[ -z "$PS1" ]] && return

# Set environment
export HISTCONTROL=ignoredups
export PATH=$PATH:$HOME/bin
export VISUAL='vim'
export EDITOR='vim'
export PAGER='less'
export GREP_COLOR='1;36'

# Shell Options
shopt -s extglob
shopt -s checkwinsize
shopt -s cdspell
# Bash Version >= 4
shopt -s autocd   2>/dev/null || true
shopt -s dirspell 2>/dev/null || true

# Aliases
alias l='ls -CF'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias chomd='chmod'
alias gerp='grep'
alias cdir='cd "${_%/*}"'
alias externalip='curl -s http://ifconfig.me/ip'
alias json_decode="python -c'from simplejson.tool import main; main()'"
alias count_states='ps ax -o state | sort | uniq -c'

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
		# Store colors for later use in $
		__RED=$red
		__GREEN=$green
		PROMPT_COMMAND='(( $? == 0 )) && __DOLLAR="$__GREEN" || __DOLLAR="$__RED"'
		PS1="\[$bold\]\[$green\]\u\[$reset\]\[$cyan\] @ \[$bold\]\[$blue\][\[$reset\]\[$green\] \h \[$yellow\]:: "
		PS1="$PS1\[$magenta\](\[$yellow\]$(uname)\[$magenta\])\[$reset\] \[$bold\]\[$blue\]]\[$reset\] \[$cyan\]\w \["'$__DOLLAR'"\]\\$ \[$reset\]"
	fi
}
__fancy_prompt

# Enable color support of ls
case "$(uname)" in
	'Darwin') alias ls='ls -p -G';;
	*)        alias ls='ls -p --color=auto';;
esac

# Load functions
remove_percent20() {
	# Remove percent20 from filenames
	for f in *%20*; do
		mv "$f" "${f//\%20/ }"
	done
}
aoeu() {
    [[ -z "$DISPLAY" ]] && sudo loadkeys us || setxkbmap us
}
asdf() {
    [[ -z "$DISPLAY" ]] && sudo loadkeys dvorak || setxkbmap dvorak
}

# Load external files
[[ -f /etc/bash_completion ]] && . /etc/bash_completion || true
[[ -f ~/.bash_aliases ]]      && . ~/.bash_aliases      || true
[[ -f ~/.bashrc.local ]]      && . ~/.bashrc.local      || true
