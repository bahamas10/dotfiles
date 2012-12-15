# Best bashrc in history
#
# Dave Eddy <dave@daveeddy.com>

# If not running interactively, don't do anything
[[ -z "$PS1" ]] && return

# Set environment
export BROWSER='chromium'
export EDITOR='vim'
export GREP_COLOR='1;36'
export GREP_OPTIONS='--color=auto'
export HISTCONTROL='ignoredups'
export PAGER='less'
export PATH="$PATH:$HOME/bin"
export PRETTYJSON_DASH='black'
export PRETTYJSON_KEYS='cyan'
export TZ='US/Pacific'
export VISUAL='vim'

# support colors in less
# (shamelessly stolen from grmlrc http://grml.org/zsh/)
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Shell Options
shopt -s cdspell
shopt -s checkwinsize
shopt -s extglob
# Bash Version >= 4
shopt -s autocd   2>/dev/null || alias ..='cd ..'
shopt -s dirspell 2>/dev/null || true

# Aliases
alias cdir='cd "${_%/*}"'
alias chomd='chmod'
alias freq='sort | uniq -c | sort -n'
alias externalip='curl -s http://ifconfig.me/ip'
alias gerp='grep'
alias joyentstillpaying="sdc-listmachines | json -a -c \"state !== 'running'\" name state"
alias json_decode="python -c'from simplejson.tool import main; main()'"
alias l='ls -CF'
alias lsdisks='kstat -lc disk :::class | field 3 :'
alias lsnpm='npm ls -g --depth=0'
alias scratch='cd "$(mktemp -d)" && pwd'
alias urldecode="python -c 'import sys;import urllib as u;print u.unquote_plus(sys.stdin.read());'"
alias urlencode="python -c 'import sys;import urllib as u;print u.quote_plus(sys.stdin.read());'"

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

# Like zlogin(1) except takes a Joyent machine alias
alogin() {
	zlogin "$(vmadm list -o uuid -H alias="$1")"
}
# Switch to qwerty
aoeu() {
	[[ -z "$DISPLAY" ]] && sudo loadkeys us || setxkbmap us
}
# Print arguments as read from the command line after wordsplitting
# http://mywiki.wooledge.org/Arguments
args() {
	printf '%d args:' $#
	printf ' <%s>' "$@"
	echo
}
# Switch to dvorak
asdf() {
	[[ -z "$DISPLAY" ]] && sudo loadkeys dvorak || setxkbmap dvorak
}
# Add commas to a given input
commas() {
	sed -e :a -e 's/\(.*[0-9]\)\([0-9]\{3\}\)/\1,\2/;ta'
}
# Convert epoch to human readable
epoch() {
	local num=${1//[^0-9]/}
	(( ${#num} < 13 )) && num=${num}000
	node -e "console.log(new Date($num));"
}
# Grab a field from given input on the IFS
# Taken from http://www.brendangregg.com/Shell/field
field() {
	local fs=
	[[ -n $2 ]] && fs="-F$2"
	awk $fs '{ print $'${1:-1}' }'
}
# Platform-independent memory usage
meminfo() {
	node <<-EOF
	var os = require('os');
	var free = os.freemem();
	var total = os.totalmem();
	var used = total - free;
	console.log('memory: %dmb / %dmb (%d%%)',
	    Math.round(used / 1024 / 1024),
	    Math.round(total / 1024 / 1024),
	    Math.round(used * 100 / total));
	EOF
}
# Process age
psage() {
	local o= args=$(ps -eo pid,args)
	for proc in /proc/*; do
		echo "$(stat -c %Y "$proc") $proc";
	done | sort | \
	while read -r time pid; do
		o=$(grep "${pid##*/}" <<< "$args") && echo "[$(epoch "$time")] $o";
	done
}
# Parallel ssh
pssh() {
	while read host; do
		echo -n "$host: ";
		ssh -qn "$host" "$@";
	done
}
# Remove percent20 from filenames in the current dir
remove_percent20() {
	local f=
	for f in *%20*; do
		mv -v "$f" "${f//\%20/ }"
	done
}
# Taken from Joyents smart machines bashrc
svclog() {
	tail -20 "$(svcs -L "$1")"
}
# Taken from Joyents smart machines bashrc
svclogf() {
	tail -20f "$(svcs -L "$1")"
}
# Total a given field using awk
# Taken from http://www.brendangregg.com/Shell/total
total() {
	awk '{ s += $'${1:-1}' } END { print s }'
}
# Follow redirects to untiny a tiny url
untiny() {
	local location=$1 last_location=
	while [[ -n "$location" ]]; do
		[[ -n "$last_location" ]] && echo " -> $last_location"
		last_location=$location
		read -r _ location < \
		    <(curl -sI "$location" | grep 'Location: ' | tr -d '[[:cntrl:]]')
	done
	echo "$last_location"
}
# parse URL's to JSON for easy screen scraping on the shell
urlparse() {
	node -e "
	var fs = require('fs');
	var url = require('url');
	var stdin = fs.readFileSync('/dev/stdin').toString();
	console.log(JSON.stringify(url.parse(stdin, true), null, 2));
	"
}

# Load external files
. /etc/bash_completion 2>/dev/null || true
. ~/.bash_completion   2>/dev/null || true
. ~/.bash_aliases      2>/dev/null || true
. ~/.bashrc.local      2>/dev/null || true
