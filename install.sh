#!/usr/bin/env bash
#
# install all files to ~ by symlinking them,
# this way, updating them is as simple as git pull

defaults() {
	echo "$@"
	command defaults "$@"
}

symlink() {
	printf '%40s -> %s\n' "${1/#$HOME/~}" "${2/#$HOME/~}"
	ln -sf "$@"
}

git submodule init
git submodule update

# Link dotfiles
for f in bash_completion bash_profile bashrc gitconfig htoprc jshintrc screenrc tmux.conf vimrc vim; do
	rm -r ~/."$f"
	symlink "$PWD/$f" ~/."$f"
done

# Setup basher
if [[ ! -d ~/.basher ]]; then
	bash <(curl -sS https://raw.github.com/bahamas10/basher/master/basher) init
	rm -r ~/.basher/plugins
	symlink "$PWD/basher-plugins" ~/.basher/plugins
fi

# Keyboard shortcuts for Mac OS X
if [[ -d ~/Library ]]; then
	mkdir -p ~/Library/KeyBindings

	symlink "$PWD/DefaultKeyBinding.dict" ~/Library/KeyBindings/DefaultKeyBinding.dict
fi

# Mac OS X NSUserDefaults modifications
if defaults read com.apple.finder &>/dev/null; then
	# Full POSIX path in finder windows
	defaults write com.apple.finder _FXShowPosixPathInTitle Yes
	# Disable dashboard
	defaults write com.apple.dashboard mcx-disabled -boolean YES
	# Disable the ugly mavericks dock appearance
	defaults write com.apple.dock hide-mirror  -bool true
	# Reenable key repeat for pressing and holding keys
	defaults write -g ApplePressAndHoldEnabled -bool false
	# Disable all window animations
	defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
	# Disable elastic scroll
	#defaults write -g NSScrollViewRubberbanding -int 0
	# XXX it makes going back weird, enable it for now i guess ugh
	defaults delete -g NSScrollViewRubberbanding
	# Show ~/Library in finder
	chflags nohidden ~/Library
fi
