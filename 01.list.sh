#!/bin/bash

. sejongrc

URL="https://ithub.korean.go.kr/user/total/database/corpusList.do"
DATA="boardSeq=2&articleSeq=&boardType=CORPUS&roleGb=U&userId=0&deleteValues=&isInsUpd=I&pageIndex=1&searchStartDt=&searchEndDt=&searchDataGb=E&searchCondition=&searchKeyword=&pageUnit=10000"
OUTFILE="html/list.html"
DESC="게시물 목록"
curl_post 2>/dev/null

mkdir -p logs
grep goView $OUTFILE | awk -F"'" '{print $2}' > logs/list.idx
