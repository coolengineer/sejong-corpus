#!/bin/bash
#
# (C) Copyright 2017 Hojin Choi <hojin.choi@gmail.com>
#
# vim: ts=4 noexpandtab sw=4 sts=4

cd $(dirname $0)

## UTF8 Converting
INFILE="$1"
OUTFILE="$2"

echo "Convert: $INFILE > $OUTFILE"
cat $INFILE | iconv -f utf-16 -t utf8 | tr -d '\r' > $OUTFILE.tmp

## non-XML tag escaping
cat $OUTFILE.tmp | ./05.convert-xml-tag.py > $OUTFILE.tmp2 2>> logs/unknown-xml-tags.log
mv $OUTFILE.tmp2 $OUTFILE

