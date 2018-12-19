#!/bin/bash
#
# (C) Copyright 2017 Hojin Choi <hojin.choi@gmail.com>
#
# vim: ts=4 noexpandtab sw=4 sts=4

cd $(dirname $0)

## UTF8 Converting
INFILE="$1"
OUTFILE="$2"
LOGFILE=${INFILE%.txt}.log

exec 2> "$LOGFILE"

echo "Convert: $INFILE > $OUTFILE"
cat $INFILE | iconv -f utf-16 -t utf-8 | tr -d '\r' > $OUTFILE.tmp

## non-XML tag escaping
cat $OUTFILE.tmp | ./32.convert-xml-tag.py > $OUTFILE.tmp2 2>> logs/unknown-xml-tags.log
mv $OUTFILE.tmp2 $OUTFILE

if test -z "$(head -2 $LOGFILE)"; then
	rm -f $OUTFILE.tmp "$LOGFILE"
fi
