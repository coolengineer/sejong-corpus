#!/bin/bash
# vim: ts=4 noexpandtab sw=4 sts=4

cd $(dirname $0)

OUTFILE="$1"

if test -z "$OUTFILE"; then
    echo "Usage: $0 <grand morpheme extract file>"
    exit 1
fi
MORPHDIR="tmp/m"
mkdir -p "$MORPHDIR"

LOGFILE="logs/extract.log"
rm -f $LOGFILE

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
    MORPHFILE=${INFILE/corpus-utf8/$MORPHDIR}
    MORPHFILE=${MORPHFILE%.txt}.morph.txt
    if test "$INFILE" -nt "$MORPHFILE"; then
        ./41.extract.py $INFILE $MORPHFILE.tmp 2>> $LOGFILE || { echo "Check $LOGFILE"; exit 1; }
        ./42.jamo-conv.py $MORPHFILE.tmp $MORPHFILE 2>> $LOGFILE || { echo "Check $LOGFILE"; exit 1; }
        rm -f $MORPHFILE.tmp
    else
        echo "($COUNT/$TOTAL) Skip extract morpheme $INFILE >> $MORPHFILE"
    fi
done <<EOT
$(find corpus-utf8 \( -name '?CT_*.txt' -o -name '?T*.txt' \) | wc -l)
$(find corpus-utf8 \( -name '?CT_*.txt' -o -name '?T*.txt' \))
EOT

echo "Concatenate tmp/m/*.morph.txt > $OUTFILE"
find tmp/m -name '*.morph.txt' -exec cat {} \; > $OUTFILE 2>>$LOGFILE
echo "Log file: $LOGFILE"
