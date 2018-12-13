#!/bin/bash
#
# (C) Copyright 2017 Hojin Choi <hojin.choi@gmail.com>
#
# vim: ts=4 noexpandtab sw=4 sts=4

. sejongrc

TOTAL=$(wc -l logs/list.idx | awk '{print $1}')

if test ! -f logs/list.idx; then
	echo "There is no logs/list.idx file, run 00.list.sh"
	exit 1
fi
if test -z "$1" -o -z "$2"; then
	echo "Usage: ./03.getcontent.sh <begin-line number of list.idx> <number of lines>"
	exit 1
fi

BEGIN=$1
NUMOFLINES=$2
PROCNUM=$3
COUNT=$BEGIN

for SEQ in $(tail -n +$1 logs/list.idx | head -n $NUMOFLINES)
do
	URL="https://ithub.korean.go.kr/user/total/database/corpusView.do"
	OUTFILE="html/article-$SEQ.html"
	DATA="boardSeq=2&articleSeq=$SEQ&boardType=CORPUS&roleGb=U&userId=0&deleteValues=&isInsUpd=&pageIndex=1&searchStartDt=&searchEndDt=&searchDataGb=E&searchCondition=&searchKeyword=&pageUnit=10"
	DESC="$SEQ ($COUNT/$TOTAL)"
    PREFIX="($SEQ) "
	if test -n "$PROCNUM"; then
		PREFIX="[$PROCNUM] $PREFIX"
	fi
	curl_post 2>/dev/null
	ATTIDX=$(grep attachIdx $OUTFILE | awk -F'"' '{print $8}')
	FILESEQ="1"
	if grep posFileSeq $OUTFILE | grep -q checkbox; then
		FILESEQ="$FILESEQ,2"
	fi
	if grep semFileSeq $OUTFILE | grep -q checkbox; then
		FILESEQ="$FILESEQ,3"
	fi
	if grep synFileSeq $OUTFILE | grep -q checkbox; then
		FILESEQ="$FILESEQ,4"
	fi
	./04.download.sh $SEQ "$ATTIDX" "$FILESEQ" "$PROCNUM"
	COUNT=$(( $COUNT + 1 ))
done
