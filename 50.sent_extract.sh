#!/bin/bash
# vim: ts=4 noexpandtab sw=4 sts=4

cd $(dirname $0)

OUTFILE="$1"

if test -z "$OUTFILE"; then
    echo "Usage: $0 <grand sentence extract file>"
    exit 1
fi
SENTDIR="tmp/s"
mkdir -p "$SENTDIR"

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
    SENTFILE=${INFILE/corpus-utf8/$SENTDIR}
    SENTFILE=${SENTFILE%.txt}.sent.txt
    if test "$INFILE" -nt "$SENTFILE"; then
        ./51.sent_extract.py $INFILE $SENTFILE 2>> $LOGFILE || { echo "Check $LOGFILE"; exit 1; }
    else
        echo "($COUNT/$TOTAL) Skip extract sentence $INFILE >> $SENTFILE"
    fi
done <<EOT
$(find corpus-utf8 \( -name '?CT_*.txt' -o -name '?T*.txt' \) | wc -l)
$(find corpus-utf8 \( -name '?CT_*.txt' -o -name '?T*.txt' \))
EOT

echo "Concatenate tmp/s/*.sent.txt > $OUTFILE"
find tmp/s -name '*.sent.txt' -exec cat {} \; > $OUTFILE 2>>$LOGFILE
echo "Log file: $LOGFILE"
