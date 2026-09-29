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

# use vardump instead of parr
alias parr='vardump'

# -- Environment

# Set environment and configure bash
HISTCONTROL='ignoredups'
HISTSIZE=5000
HISTFILESIZE=5000

export EDITOR='vim'
export GREP_COLOR='1;36'
export LSCOLORS='ExGxbEaECxxEhEhBaDaCaD'
export MANPAGER='less'
export PAGER='less'
export TZ='America/New_York'
export VISUAL='vim'

# Support colors in less
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;31m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[1;33;44m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[4;1;32m'
export LESS_TERMCAP_mr=$'\e[7m'
export LESS_TERMCAP_mh=$'\e[2m'
export LESS_TERMCAP_ZN=$'\e[74m'
export LESS_TERMCAP_ZV=$'\e[75m'
export LESS_TERMCAP_ZO=$'\e[73m'
export LESS_TERMCAP_ZW=$'\e[75m'

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
alias ag='rg' # sorry silver searcher
alias chomd='chmod'
alias externalip='curl -sS https://ysap.sh/ip'
alias gerp='grep'
alias hl='rg --passthru'
alias l='ls'
alias ll='ls -lha'
alias suod='sudo'

# Aliases (if applicable)
grep --color=auto < /dev/null &>/dev/null &&
    alias grep='grep --color=auto'
command -v xdg-open &>/dev/null &&
    alias open='xdg-open'
command -v system_profiler &>/dev/null &&
    alias wattage='system_profiler SPPowerDataType | grep Wattage'

# Enable color support of ls
if ls --color=auto /dev/null &>/dev/null; then
	alias ls='ls -p --color=auto'
else
	alias ls='ls -p -G'
fi

# -- Git Aliases

alias nb='git checkout -b "$USER-$(date +%s)"' # new branch
alias ga='git add . --all'
alias gb='git branch'
alias gc='git clone'
alias gci='git commit -a'
alias gco='git checkout'
alias gd="git diff ':!*lock'"
alias gdf='git diff' # git diff (full)
alias gi='git init'
alias gl='git log'
alias gp='git push origin HEAD'
alias gr='git rev-parse --show-toplevel' # git root
alias gs='git status'
alias gt='git tag'
alias gu='git pull' # gu = git update

# because `master` is sometimes `main` (or others), these must be functions.
gmb() { # git main branch
	local main
	main=$(git symbolic-ref --short refs/remotes/origin/HEAD)
	main=${main#origin/}
	[[ -n $main ]] || return 1
	echo "$main"
}

# show the diff from inside a branch to the main branch
gbd() { # git branch diff
	local mb
	mb=$(gmb) || return 1
	git diff "$mb..HEAD"
}

# checkout the main branch and update it
gcm() { # git checkout $main
	local mb
	mb=$(gmb) || return 1
	git checkout "$mb" && git pull
}

# merge the main branch into our branch
gmm() { # git merge $main
	local mb
	mb=$(gmb) || return 1
	git merge "$mb"
}

# -- Prompt logic

# change the prompt colors to a theme
# there are 116 possible themes - themes are 0-115
prompt-set-theme() {
	local theme=${1:-0}
	local j=0
	for ((i = theme; i <= 255; i += 30)); do
		PROMPT_COLORS[j]=$'\e[38;5;'${i}m
		((j++))
	done
}

prompt-init() {
	local red=$'\e[31m'
	local reset=$'\e[0m'
	local bold=$'\e[1m'

	# custom prompt for YSAP videos
	if [[ $ITERM_PROFILE == 'YSAP'* ]]; then
		# username
		PS1='\[${PROMPT_COLORS[0]}\]\u\['"$reset"'\]'

		# @
		PS1+='\[${PROMPT_COLORS[1]}\]\['"$bold"'\]@\['"$reset"'\]'

		# hostname
		PS1+='\[${PROMPT_COLORS[3]}\]ysap '

		# cwd (this makes it too horizontal)
		# PS1+='\[${PROMPT_COLORS[5]}\]\w '

		# prompt character
		PS1+='\[${PROMPT_COLORS[2]}\]\$\['"$reset"'\] '

		PROMPT_DIRTRIM=1

		return
	fi

	# get host info only once
	local zonename=$(zonename 2>/dev/null)
	local uname=$(uname | tr '[:upper:]' '[:lower:]')

	# Construct the prompt:
	# [(exit code)] <user> - <hostname> <uname> <cwd> [git branch] <$|#>

	# exit code of last process
	PS1='$(c=$?;((c!=0))&&echo "\['"$red"'\]($c) \['"$reset"'\]")'

	# username (red for root)
	PS1+='\[${PROMPT_COLORS[0]}\]\['"$bold"'\]$(((UID==0))&&echo "\['"$red"'\]")\u\['"$reset"'\] - '

	# zonename (global zone warning)
	if [[ $zonename == 'global' ]]; then
		PS1+='\['"$red"'\]\['"$bold"'\]GZ:\['"$reset"'\]'
	fi

	# hostname
	PS1+='\[${PROMPT_COLORS[3]}\]\h '

	# uname
	PS1+='\[${PROMPT_COLORS[2]}\]'"$uname"' '

	# cwd
	PS1+='\[${PROMPT_COLORS[5]}\]\w '

	# optional git branch
	#
	# THIS IS UNFORTUNATE LOL. i hate how long this line is, but i
	# purposefully try to keep this as tight as possible because even just
	# spacing it all out has a noticeable effect on speed.
	PS1+='$(b=$(git rev-parse --abbrev-ref HEAD 2>/dev/null);[[ -n $b ]]&&echo -n "\[${PROMPT_COLORS[2]}\](\[${PROMPT_COLORS[3]}\]git:$b\[${PROMPT_COLORS[2]}\]) ")'

	# prompt character
	PS1+='\[${PROMPT_COLORS[0]}\]\$\['"$reset"'\] '

	# initalize a basic theme just to ensure some colors are set
	prompt-set-theme 0
}

prompt-update() {
        local user=$USER
        local host=${HOSTNAME%%.*}

	# get the PWD from the prompt as that handles escaping dangerous chars
	# for us
	local s='\w'
	local pwd=${s@P}

	# update title bar
        local ssh=
        [[ -n $SSH_CLIENT ]] && ssh='[ssh] '
        printf '\e]0;%s%s@%s:%s\a' "$ssh" "$user" "$host" "$pwd"
}

PROMPT_COLORS=()
PROMPT_COMMAND=prompt-update
PROMPT_DIRTRIM=6

prompt-init
prompt-set-theme 24

# -- Useful functions

# upload a file to my personal CDN
cdn() {
	local file=$1
	local bname=${file##*/}

	[[ -n $file && -n $bname ]] || return 1

	local url
	printf -v url '%(%Y/%m/%d)T/%s' -1 "$bname"
	local remote_file="./cdn/$url"

	# use rsync over scp because we can skip overwriting files
	rsync -avh --mkpath --progress --ignore-existing -- \
	    "$file" "cdn:$remote_file" || return 1

	echo "https://cdn.ysap.sh/$url"
}

# print a colorized diff
colordiff() {
	local red=$'\e[31m'
	local green=$'\e[32m'
	local cyan=$'\e[36m'
	local reset=$'\e[0m'

	diff -u "$@" | awk \
		-v "red=$red" -v "green=$green" \
		-v "cyan=$cyan" -v "reset=$reset" \
		'
	/^-/ {
		printf("%s", red);
	}
	/^\+/ {
		printf("%s", green);
	}
	/^@/ {
		printf("%s", cyan);
	}

	{
		print $0 reset;
	}'

	return "${PIPESTATUS[0]}"
}

# Print all 256 colors
colors() {
	local i
	for i in {0..255}; do
		printf '\e[38;5;%dmcolor %d\n' "$i" "$i"
	done
	printf '\e[0m'
}

# Copy stdin to the clipboard
copy() {
	pbcopy 2>/dev/null ||
	    xsel 2>/dev/null ||
	    clip.exe

}

dump-palette() {
	exec {fd}<>/dev/tty || fatal 'failed to open TTY'

	re='rgb:([0-9a-f]{4})\/([0-9a-f]{4})\/([0-9a-f]{4})'
	for code in 4\;{0..15} 10 11 12 17 19; do
		# query the terminal for palette info
		printf '\e]%s;?\e\\' "$code" >&$fd

		# read the response into a string (removing escape chars)
		read -rs -d '\\' -u "$fd" s
		s=${s//$'\e'}

		if ! [[ $s =~ $re ]]; then
			echo "$code = <failed>"
			continue
		fi

		# parse the response
		r=${BASH_REMATCH[1]}
		g=${BASH_REMATCH[2]}
		b=${BASH_REMATCH[3]}

		r=$((16#$r / 257))
		g=$((16#$g / 257))
		b=$((16#$b / 257))

		printf '%s = #%02x%02x%02x\n' "$code" "$r" "$g" "$b"
	done
	exec {fd}>&-
}

# Convert epoch to human readable (print current date if no args)
epoch() {
	local num=${1:--1}
	printf '%(%B %d, %Y %-I:%M:%S %p %Z)T\n' "$num"
}

# Open the current path or file in GitHub
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
	IFS=:/ read -r -a a <<< "$url"
	local len=${#a[@]}
	local user=${a[len-2]}
	local repo=${a[len-1]%.git}

	url="https://github.com/$user/$repo/tree/$branch$path"
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
			if (int.family === 'IPv4') {
				console.log('%s: %s', name, int.address);
			}
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
	local c=${1:-80}
	expand | awk -v "c=$c" 'length($0) > c {
		printf("%4d %s\n", NR, $0);
	}'
}

# print a rainbow if truecolor is available to the terminal
truecolor-rainbow() {
	local i r g b
	for ((i = 0; i < 77; i++)); do
		r=$((255 - (i * 255 / 76)))
		g=$((i * 510 / 76))
		b=$((i * 255 / 76))
		((g > 255)) && g=$((510 - g))
		printf '\033[48;2;%d;%d;%dm ' "$r" "$g" "$b"
	done
	printf '\e[0m\n'
}

# Follow redirects to untiny a tiny url
untiny() {
	local location=$1
	local last_location=''

	while [[ -n $location ]]; do
		echo "-> $location"
		read -r _ location < \
		    <(curl -sI "$location" | grep -i '^location: ' | tr -d '[:cntrl:]')
	done
	true
}

# Load external files
. ~/.bash_aliases    2>/dev/null || true
. ~/.bashrc.local    2>/dev/null || true

# load completion
. /etc/bash/bash_completion 2>/dev/null ||
	. ~/.bash_completion 2>/dev/null

path_clean

true
