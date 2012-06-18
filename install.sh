#!/usr/bin/env bash
#
# install all files to ~ by symlinking them,
# this way, updating them is as simple as git pull
set -x
for f in *; do
	ln -sf "$PWD/$f" ~/."$f"
done
set +x
