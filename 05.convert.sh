#!/bin/bash
#
# (C) Copyright 2017 Hojin Choi <hojin.choi@gmail.com>
#
# vim: ts=4 noexpandtab sw=4 sts=4

cd $(dirname $0)
DESTDIR=${DESTDIR-corpus-utf8}
mkdir -p "$DESTDIR"
rm -f logs/unknown-xml-tags.log
find corpus -name '[0-9A-Z]*[A-Z]*[0-9A-Z]*.txt' | 
	while read INFILE
	do
		OUTFILE=${INFILE/corpus/$DESTDIR}
		if test -f $OUTFILE; then
			PARTIAL=$(head -2 $OUTFILE)
			if test -n "$PARTIAL"; then
				if test "$OUTFILE" -nt "$INFILE"; then
					echo "Skip $INFILE > $OUTFILE"
					continue
				fi
			fi
		fi

		./05.convert-file.sh $INFILE $OUTFILE
	done
if test -f logs/unknown-xml-tags.log; then
	sort logs/unknown-xml-tags.log | uniq -c | sort -nr > logs/unknown-xml-tags2.log
fi
