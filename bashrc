# Best bashrc in history
#
# Dave Eddy <dave@daveeddy.com>

# If not running interactively, don't do anything
[[ -z $PS1 ]] && return

# Load basher
. ~/.basher/basher || echo '> failed to load basher'

# Set environment
export BROWSER='chromium'
export EDITOR='vim'
export GREP_COLOR='1;36'
export GREP_OPTIONS='--color=auto'
export HISTCONTROL='ignoredups'
export PAGER='less'
export PATH="$PATH:$HOME/bin"
export TZ='US/Eastern'
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
alias cpp2c="sed -e 's#//\(.*\)#/*\1 */#'"
alias chomd='chmod'
alias externalip='curl -s http://ifconfig.me/ip'
alias gerp='grep'
alias joyentstillpaying="sdc-listmachines | json -a -c \"state !== 'running'\" name state"
alias l='ls -CF'
alias lsdisks='kstat -lc disk :::class | field 3 :'
alias lsnpm='npm ls -g --depth=0'
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
# Conditonally output `%\n` based on the current column of the cursor (like zsh)
__fancy_newline() {
	if (( $(curcol) != 0 )); then
		tput bold
		tput rev
		echo '%'
		tput sgr0
	fi
}
#PROMPT_COMMAND="$PROMPT_COMMAND; __fancy_newline;"

# Enable color support of ls
if ls --color=auto &>/dev/null; then
	alias ls='ls -p --color=auto'
else
	alias ls='ls -p -G'
fi

# Like zlogin(1) except takes a Joyent machine alias
alogin() {
	zlogin "$(vmadm list -o uuid -H alias="$1")"
}
# Switch to qwerty
aoeu() {
	[[ -z $DISPLAY ]] && sudo loadkeys us || setxkbmap us
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
	[[ -z $DISPLAY ]] && sudo loadkeys dvorak || setxkbmap dvorak
}
# Print all supported colors
colors() {
	for i in {0..255}; do
		printf "\x1b[38;5;${i}mcolor %d\n" "$i"
	done
	tput sgr0
}
# Add commas to a given input
commas() {
	sed -e :a -e 's/\(.*[0-9]\)\([0-9]\{3\}\)/\1,\2/;ta'
}
# http://stackoverflow.com/questions/2575037/how-to-get-the-cursor-position-in-bash
# Print the current column of the cursor
curcol() {
	local pos oldstty row=0 col=0
	exec < /dev/tty
	oldstty=$(stty -g)
	stty raw -echo min 0
	tput u7 > /dev/tty
	IFS=';' read -r -d R -a pos
	stty "$oldstty"
	# change from one-based to zero based so they work with: tput cup $row $col
	col=${pos[1]}
	col=$((${col:-1} - 1))
	echo "$col"
}
# Convert epoch to human readable
epoch() {
	local num=${1//[^0-9]/}
	(( ${#num} < 13 )) && num=${num}000
	node -pe "new Date($num);"
}
# Grab a field from given input on the IFS
# Taken from http://www.brendangregg.com/Shell/field
field() {
	local fs=
	[[ -n $2 ]] && fs="-F$2"
	awk $fs '{ print $'${1:-1}' }'
}
# frequency count
freq() {
	sort | uniq -c | sort -n
}
# print gaps in numbers
# http://stackoverflow.com/questions/15867557/finding-gaps-sequential-numbers
gaps() {
	awk '($1!=p+1) {print p+1 "-" $1-1} {p=$1}'
}
# Platform-independent interfaces
interfaces() {
	node <<-EOF
	var os = require('os');
	var i = os.networkInterfaces();
	var ret = {};
	Object.keys(i).forEach(function(name) {
		var ip4 = null;
		i[name].forEach(function(int) {
			if (int.family === 'IPv4') {
				ip4 = int.address;
				return;
			}
		});
		ret[name] = ip4;
	});
	console.log(JSON.stringify(ret, null, 2));
	EOF
}
# Limit the number of columns printed
limitcolumns() {
	local cols=$1
	local red=$(tput setaf 1)
	local reset=$(tput sgr0)
	cols=${cols:-$COLUMNS}
	cols=${cols:-$(tput cols)}
	cols=${cols:-80}
	awk "
	{
		if (length(\$0) > $cols)
			\$0 = substr(\$0, 0, $cols - 1) \"$red>$reset\";
		print \$0
	}"
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
# Parallel ssh (not really)
pssh() {
	while read host; do
		echo -n "$host: "
		ssh -qn "$host" "$@"
	done
}
# Remove percent20 from filenames in the current dir
remove_percent20() {
	local f=
	for f in *%20*; do
		mv -v "$f" "${f//\%20/ }"
	done
}
# Total a given field using awk
# Taken from http://www.brendangregg.com/Shell/total
total() {
	awk '{ s += $'${1:-1}' } END { print s }'
}
# Follow redirects to untiny a tiny url
untiny() {
	local location=$1 last_location=
	while [[ -n $location ]]; do
		[[ -n $last_location ]] && echo " -> $last_location"
		last_location=$location
		read -r _ location < \
		    <(curl -sI "$location" | grep 'Location: ' | tr -d '[[:cntrl:]]')
	done
	echo "$last_location"
}
# Undo github flavor markdown
ungithubmd() {
	awk '/^```/ { flag=!flag; $0 = "" } { if (flag) print "    " $0; else print $0; }'
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
