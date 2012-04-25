#
# Custom bashrc
# Dave Eddy <dave@daveeddy.com>
#

# If not running interactively, don't do anything
[[ -z "$PS1" ]] && return

# Set environment
export HISTCONTROL='ignoredups'
export PATH=$PATH:$HOME/bin
export VISUAL='vim'
export EDITOR='vim'
export PAGER='less'
export GREP_COLOR='1;36'
export GREP_OPTIONS='--color=auto'

# Shell Options
shopt -s extglob
shopt -s checkwinsize
shopt -s cdspell
# Bash Version >= 4
shopt -s autocd   2>/dev/null || true
shopt -s dirspell 2>/dev/null || true

# Aliases
alias l='ls -CF'
alias chomd='chmod'
alias gerp='grep'
alias cdir='cd "${_%/*}"'
alias externalip='curl -s http://ifconfig.me/ip'
alias count='sort | uniq -c | sort -n'
alias count_states='ps ax -o state | count'
alias json_decode="python -c'from simplejson.tool import main; main()'"
alias urlencode="python -c 'import sys;import urllib as u;print u.quote_plus(sys.stdin.read());'"
alias urldecode="python -c 'import sys;import urllib as u;print u.unquote_plus(sys.stdin.read());'"

# Set the prompt
__fancy_prompt() {
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
		PS1="$PS1\[$magenta\](\[$yellow\]$(uname)\[$magenta\])\[$reset\] \[$bold\]\[$blue\]]\[$reset\] "
		PS1="$PS1\[$cyan\]\w \["'$__DOLLAR'"\]\\$ \[$reset\]"
	fi
}
__fancy_prompt

# Enable color support of ls
case "$(uname)" in
	'Darwin') alias ls='ls -p -G';;
	*)        alias ls='ls -p --color=auto';;
esac

# Load convenience functions
remove_percent20() {
	# Remove percent20 from filenames in the current dir
	for f in *%20*; do
		mv -v "$f" "${f//\%20/ }"
	done
}
aoeu() {
	# Switch to qwerty
	[[ -z "$DISPLAY" ]] && sudo loadkeys us || setxkbmap us
}
asdf() {
	# Switch to dvorak
	[[ -z "$DISPLAY" ]] && sudo loadkeys dvorak || setxkbmap dvorak
}
total() {
	# Total a given field using awk
	# Taken from http://www.brendangregg.com/Shell/total
	awk '{ s += $'${1:-1}' } END { print s }'
}
field() {
	# Grab a field from given input on the IFS
	# Taken from http://www.brendangregg.com/Shell/field
	awk '{ print $'${1:-1}' }'
}
meminfo() {
	# Print mem stats (SunOS)
	local freemem=$(kstat -p 'unix:0:system_pages:freemem' | field 2)
	local avail=$(( $freemem * $(pagesize) / 1024 / 1024 ))
	prtconf | grep Memory
	echo "Available: $avail Megabytes"
}

# Load external files
[[ -f /etc/bash_completion ]] && . /etc/bash_completion || true
[[ -f ~/.bash_aliases ]]      && . ~/.bash_aliases      || true
[[ -f ~/.bashrc.local ]]      && . ~/.bashrc.local      || true
