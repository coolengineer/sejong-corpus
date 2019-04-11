#!/bin/bash
#
# (C) Copyright 2017 Hojin Choi <hojin.choi@gmail.com>
#
# vim: ts=4 noexpandtab sw=4 sts=4

. sejongrc

URL="https://ithub.korean.go.kr/user/total/database/corpusView.do"
TOTAL=$(wc -l logs/list.idx | awk '{print $1}')
CONCURRENT=${CONCURRENT-20}
STEP=$(( ($TOTAL-1)/$CONCURRENT + 1))
PROCNUM=0
_PROCNUM=
PIDS=""
echo "Download with $CONCURRENT processes"
while test $PROCNUM -lt $CONCURRENT
do
	if test $CONCURRENT -gt 1; then
		_PROCNUM=$(printf "%03d" $PROCNUM)
	fi
	./21.getcontent.sh $(($STEP * $PROCNUM + 1)) $STEP $_PROCNUM &
	PIDS="$PIDS $!"
	PROCNUM=$(( 10#$PROCNUM + 1))
done
trap 'kill $PIDS; sleep 1; exit 1' SIGINT
STATUS=0
for pid in $PIDS
do
	wait $pid
	_STATUS=$?
	if test $_STATUS -ne 0; then
		STATUS=$_STATUS
		echo "Error occurred: $pid"
	else
		echo "Work done: $pid"
	fi
done
exit $STATUS
