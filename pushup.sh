#!/bin/bash
git add *.Mod
git add *.Pkg
git add *.md
cmt=$1
if [ "$1" eq "" ]; then
	cmt='sync local to upstream'
fi
git commit -m "$cmt"
git push origin
