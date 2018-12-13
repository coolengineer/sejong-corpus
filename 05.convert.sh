#!/bin/bash
#
# (C) Copyright 2017 Hojin Choi <hojin.choi@gmail.com>
#
# vim: ts=4 noexpandtab sw=4 sts=4

cd $(dirname $0)
mkdir -p corpus-utf8
rm -f logs/unknown-xml-tags.log
find corpus -name '[0-9A-Z]*[A-Z]*[0-9A-Z]*.txt' | 
	while read INFILE
	do
		OUTFILE=${INFILE/corpus/corpus-utf8}
		LOGFILE=${INFILE%.txt}.log
		if test -f $OUTFILE; then
			echo "Skip $INFILE > $OUTFILE"
			continue
		fi

		./05.convert-file.sh $INFILE $OUTFILE 2>>$LOGFILE

		## Patching
		PATCHES=${INFILE/corpus/patches}
		PATCHES=${PATCHES%.txt}-*.patch
		for patch in $PATCHES
		do
			test -f $patch || continue
			echo "Patching ... $patch"
		done
	done
sort logs/unknown-xml-tags.log | uniq -c | sort -nr > logs/unknown-xml-tags2.log
