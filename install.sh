#!/usr/bin/env bash
#
# install all files to ~ by symlinking them,
# this way, updating them is as simple as git pull
for f in *; do
	ln -svf "$PWD/$f" ~/."$f"
done
