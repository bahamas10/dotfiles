#!/usr/bin/env bash
#
# Best bashrc in history
#
# Author: Dave Eddy <dave@daveeddy.com>
# Date: Sometime in 2011
# License: MIT

# If not running interactively, don't do anything
[[ -n $PS1 ]] || return

# Load bics, plugins found in bics-plugins
. ~/.bics/bics || echo '> failed to load bics' >&2

# Set environment
export BROWSER='firefox'
export EDITOR='vim'
export GREP_COLOR='1;36'
export HISTCONTROL='ignoredups'
export HISTSIZE=5000
export HISTFILESIZE=5000
export LSCOLORS='ExGxbEaECxxEhEhBaDaCaD'
export PAGER='less'
export TZ='America/New_York'
export VISUAL='vim'

# Support colors in less
export LESS_TERMCAP_mb=$(tput bold; tput setaf 1)
export LESS_TERMCAP_md=$(tput bold; tput setaf 1)
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_se=$(tput sgr0)
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4)
export LESS_TERMCAP_ue=$(tput sgr0)
export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 2)
export LESS_TERMCAP_mr=$(tput rev)
export LESS_TERMCAP_mh=$(tput dim)
export LESS_TERMCAP_ZN=$(tput ssubm)
export LESS_TERMCAP_ZV=$(tput rsubm)
export LESS_TERMCAP_ZO=$(tput ssupm)
export LESS_TERMCAP_ZW=$(tput rsupm)

# PATH
path_add ~/bin before

# Shell Options
shopt -s cdspell
shopt -s checkwinsize
shopt -s extglob

# Bash Version >= 4
shopt -s autocd   2>/dev/null || true
shopt -s dirspell 2>/dev/null || true

# Aliases
alias ..='echo "cd .."; cd ..'
alias chomd='chmod'
alias externalip='curl -sS https://www.daveeddy.com/ip'
alias gerp='grep'
alias js='jq'
alias l='ls -CF'
alias ag='rg' # sorry silver searcher
alias suod='sudo'
grep --color=auto < /dev/null &>/dev/null && alias grep='grep --color=auto'
xdg-open --version &>/dev/null && alias open='xdg-open'

# Git Aliases
alias nb='git checkout -b "$USER-$(date +%s)"' # new branch
alias ga='git add . --all'
alias gb='git branch'
alias gbd='git diff master...HEAD'
alias gc='git clone'
alias gci='git commit -a'
alias gcm='git checkout master && git pull'
alias gco='git checkout'
alias gd='git diff'
alias gi='git init'
alias gl='git log'
alias gmm='git merge master'
alias gp='git push origin HEAD'
alias gr='git rev-parse --show-toplevel' # git root
alias gs='git status'
alias gt='git tag'
alias gu='git pull' # gu = git update

# Prompt
# Store `tput` colors for future use to reduce fork+exec
# the array will be 0-255 for colors, 256 will be sgr0
# and 257 will be bold
COLOR256=()
COLOR256[0]=$(tput setaf 1)
COLOR256[256]=$(tput sgr0)
COLOR256[257]=$(tput bold)

# Colors for use in PS1 that may or may not change when
# set_prompt_colors is run
PROMPT_COLORS=()

# Change the prompt colors to a theme, themes are 0-29
set_prompt_colors() {
	local h=${1:-0}
	local color=
	local i=0
	local j=0
	for i in {22..231}; do
		((i % 30 == h)) || continue

		color=${COLOR256[$i]}
		# cache the tput colors
		if [[ -z $color ]]; then
			COLOR256[$i]=$(tput setaf "$i")
			color=${COLOR256[$i]}
		fi
		PROMPT_COLORS[$j]=$color
		((j++))
	done
}

PS1='$(ret=$?;(($ret!=0)) && echo "\[${COLOR256[0]}\]($ret) \[${COLOR256[256]}\]")'\
'\[${PROMPT_COLORS[0]}\]\[${COLOR256[257]}\]$(((UID==0)) && echo "\[${COLOR256[0]}\]")\u\[${COLOR256[256]}\] '\
'- \[${PROMPT_COLORS[3]}\]\h\[${PROMPT_COLORS[4]}\] '\
'\[${PROMPT_COLORS[2]}\]\[${PROMPT_COLORS[2]}\]'"$(uname | tr '[:upper:]' '[:lower:]')"'\[${PROMPT_COLORS[2]}\] '\
'\[${PROMPT_COLORS[5]}\]\w '\
'$(branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); [[ -n $branch ]] && echo "\[${PROMPT_COLORS[2]}\](\[${PROMPT_COLORS[3]}\]git:$branch\[${PROMPT_COLORS[2]}\]) ")'\
'\[${PROMPT_COLORS[0]}\]\$\[${COLOR256[256]}\] '

# set the theme
set_prompt_colors 24

# Prompt command
_prompt_command() {
        local user=$USER
        local host=${HOSTNAME%%.*}
        local pwd=${PWD/#$HOME/\~}
        local ssh=
        [[ -n $SSH_CLIENT ]] && ssh='[ssh] '
        printf "\033]0;%s%s@%s:%s\007" "$ssh" "$user" "$host" "$pwd"
}
PROMPT_COMMAND=_prompt_command

PROMPT_DIRTRIM=6

# Enable color support of ls
if ls --color=auto &>/dev/null; then
	alias ls='ls -p --color=auto'
else
	alias ls='ls -p -G'
fi

# Like zlogin(1) except takes a Joyent machine alias
alogin() {
	zlogin "$(ualias "$1")"
}

# print a colorized diff
colordiff() {
	local red=$(tput setaf 1 2>/dev/null)
	local green=$(tput setaf 2 2>/dev/null)
	local cyan=$(tput setaf 6 2>/dev/null)
	local reset=$(tput sgr0 2>/dev/null)

	diff -u "$@" | awk "
	/^\-/ {
		printf(\"%s\", \"$red\");
	}
	/^\+/ {
		printf(\"%s\", \"$green\");
	}
	/^@/ {
		printf(\"%s\", \"$cyan\");
	}

	{
		print \$0 \"$reset\";
	}"

	return "${PIPESTATUS[0]}"
}

# Print all supported colors with raw ansi escape codes
colors() {
	local i
	for i in {0..255}; do
		printf "\x1b[38;5;${i}mcolor %d\n" "$i"
	done
	tput sgr0
}

# Copy stdin to the clipboard
copy() {
	pbcopy 2>/dev/null ||
	    xsel 2>/dev/null ||
	    clip.exe

}

# Convert epoch to human readable
epoch() {
	local num=${1//[^0-9]/}
	(( ${#num} < 13 )) && num=${num}000
	node -pe "new Date($num);"
}

# open the current path or file in GitHub
gho() {
	local file=$1
	local remote=${2:-origin}

	# get the git root dir, branch, and remote URL
	local gr=$(git rev-parse --show-toplevel)
	local branch=$(git rev-parse --abbrev-ref HEAD)
	local url=$(git config --get "remote.$remote.url")

	[[ -n $gr && -n $branch && -n $remote ]] || return 1

	# construct the path
	local path=${PWD/#$gr/}
	[[ -n $file ]] && path+=/$file

	# extract the username and repo name
	local a
	IFS=:/ read -a a <<< "$url"
	local len=${#a[@]}
	local user=${a[len-2]}
	local repo=${a[len-1]%.git}

	local url="https://github.com/$user/$repo/tree/$branch$path"
	echo "$url"
	open "$url"
}

# Platform-independent interfaces
interfaces() {
	node <<-EOF
	var os = require('os');
	var i = os.networkInterfaces();
	Object.keys(i).forEach(function(name) {
		i[name].forEach(function(int) {
			if (int.family === 'IPv4')
				console.log('%s: %s', name, int.address);
		});
	});
	EOF
}

# Calculate CPU load / Core Count
load() {
	node -p <<-EOF
	var os = require('os');
	var c = os.cpus().length;
	os.loadavg().map(function(l) {
		return (l/c).toFixed(2);
	}).join(' ');
	EOF
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

# print lines over X columns (defaults to 80)
over() {
	awk -v c="${1:-80}" 'length($0) > c {
		printf("%4d %s\n", NR, $0);
	}'
}

# Turn a Joyent machine alias into the zonename
ualias() {
	vmadm list -o uuid -H alias="$1"
}

# Load external files
. ~/.bash_aliases    2>/dev/null || true
. ~/.bashrc.local    2>/dev/null || true

# load completion
. /etc/bash/bash_completion 2>/dev/null ||
	. ~/.bash_completion 2>/dev/null

path_clean

true
