#!/usr/bin/env bash
#
# install all files to ~ by symlinking them,
# this way, updating them is as simple as git pull

defaults() {
	echo "$@"
	command defaults "$@"
}

for f in bash_profile bashrc htoprc jshintrc screenrc tmux.conf vimrc; do
	printf '%40s -> %s\n' "$PWD/$f" "$HOME/.$f"
	ln -sf "$PWD/$f" ~/."$f"
done

if [[ -d ~/Library ]]; then
	mkdir -p ~/Library/KeyBindings

	f='DefaultKeyBinding.dict'
	printf '%40s -> %s\n' "$PWD/$f" ~/Library/KeyBindings/"$f"
	ln -sf "$PWD/$f" ~/Library/KeyBindings/"$f"
fi

if defaults read com.apple.finder &>/dev/null; then
	defaults write com.apple.finder _FXShowPosixPathInTitle Yes
	defaults write com.apple.dashboard mcx-disabled -boolean YES
fi
