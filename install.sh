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

for f in bash_profile bashrc htoprc jshintrc screenrc tmux.conf vimrc vim; do
	rm -r ~/."$f"
	symlink "$PWD/$f" ~/."$f"
done

# Keyboard shortcuts for Mac OS X
if [[ -d ~/Library ]]; then
	mkdir -p ~/Library/KeyBindings

	f='DefaultKeyBinding.dict'
	symlink "$PWD/$f" ~/Library/KeyBindings/"$f"
fi

# Mac OS X NSUserDefaults modifications
if defaults read com.apple.finder &>/dev/null; then
	defaults write com.apple.finder _FXShowPosixPathInTitle Yes
	defaults write com.apple.dashboard mcx-disabled -boolean YES
fi
