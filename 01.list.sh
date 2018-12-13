#!/bin/bash
#
# (C) Copyright 2017 Hojin Choi <hojin.choi@gmail.com>
#
# vim: ts=4 noexpandtab sw=4 sts=4

. sejongrc

URL="https://ithub.korean.go.kr/user/total/database/corpusList.do"
DATA="boardSeq=2&articleSeq=&boardType=CORPUS&roleGb=U&userId=0&deleteValues=&isInsUpd=I&pageIndex=1&searchStartDt=&searchEndDt=&searchDataGb=E&searchCondition=&searchKeyword=&pageUnit=10000"
OUTFILE="html/list.html"
DESC="게시물 목록"
curl_post 2>/dev/null

mkdir -p logs
grep goView $OUTFILE | awk -F"'" '{print $2}' > logs/list.idx
