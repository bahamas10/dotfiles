#!/usr/bin/env bash
#
# install all files to ~ by symlinking them,
# this way, updating them is as simple as git pull

for f in bash_profile bashrc htoprc jshintrc screenrc tmux.conf vimrc; do
	printf '%40s -> %s\n' "$PWD/$f" "$HOME/.$f"
	ln -sf "$PWD/$f" ~/."$f"
done

if [[ -d ~/Library ]]; then
	echo 'Installing KeyBindings for MacOS'
	mkdir -p ~/Library/KeyBindings
	cp DefaultKeyBinding.dict ~/Library/KeyBindings
fi
