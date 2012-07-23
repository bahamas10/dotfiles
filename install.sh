#!/usr/bin/env bash
#
# install all files to ~ by symlinking them,
# this way, updating them is as simple as git pull

for f in bash_profile bashrc htoprc screenrc tmux.conf vimrc; do
	printf '%-50s -> %s\n' "$PWD/$f" "$HOME/.$f"
	ln -sf "$PWD/$f" ~/."$f"
done
