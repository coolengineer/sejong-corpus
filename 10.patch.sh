#!/bin/bash
#
# (C) Copyright 2017 Hojin Choi <hojin.choi@gmail.com>
#
# vim: ts=4 noexpandtab sw=4 sts=4

cd $(dirname $0)

. sejongrc

DESTDIR=${DESTDIR-corpus-utf8}
mkdir -p "$DESTDIR"

find corpus -name '[0-9A-Z]*[A-Z]*[0-9A-Z]*.txt' | 
	while read FILE
	do
		INFILE=${FILE/corpus/$DESTDIR}
		STAMPFILE=${FILE/corpus\//stamps/patch-}
		if test "$INFILE" -ot "$STAMPFILE"; then
			echo "Skip patch $INFILE"
			continue
		fi
		PREFIX="" patch_preexists "$INFILE"
		touch "$STAMPFILE"
	done
