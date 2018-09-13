#!/bin/bash

cd $(dirname $0)
mkdir -p corpus-utf8
find corpus -name '[0-9A-Z]*[A-Z]*[0-9A-Z]*.txt' | 
    while read doc
    do
        OUTFILE=${doc/corpus/corpus-utf8}
        if test -f $OUTFILE; then
            echo "Skip $doc > $OUTFILE"
        else
            echo "Convert: $doc > $OUTFILE"
            cat $doc | iconv -f utf-16 -t utf8 | tr -d '\r' > $OUTFILE
        fi
    done
