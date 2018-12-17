#!/bin/bash

cd $(dirname $0)

OUTFILE="$1"

if test -z "$OUTFILE"; then
    echo "Usage: $0 <grand morpheme extract file>"
    exit 1
fi
rm -f logs/extract.log
TOTAL=
COUNT=0
export COUNT TOTAL
while read INFILE
do
    if test -z "$TOTAL"; then
        TOTAL=$INFILE
        continue
    fi
    let COUNT++
    MORPHFILE=${INFILE/corpus-utf8/logs}
    MORPHFILE=${MORPHFILE%.txt}.morph.txt
    if test "$INFILE" -nt "$MORPHFILE"; then
        ./41.extract.py $INFILE $MORPHFILE.tmp 2>> logs/extract.log || exit 1
        ./42.jamo-conv.py $MORPHFILE.tmp $MORPHFILE || exit 1
        rm -f $MORPHFILE.tmp
    else
        echo "($COUNT/$TOTAL) Skip extract morpheme $INFILE"
    fi
done <<EOT
$(find corpus-utf8 \( -name '?CT_*.txt' -o -name '?T*.txt' \) | wc -l)
$(find corpus-utf8 \( -name '?CT_*.txt' -o -name '?T*.txt' \))
EOT

find logs -name '*.morph.txt' -exec cat {} \; > $OUTFILE
echo "Log file: logs/extract.log"
