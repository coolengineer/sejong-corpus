#!/bin/bash
#
# (C) Copyright 2017 Hojin Choi <hojin.choi@gmail.com>
#
# vim: ts=4 noexpandtab sw=4 sts=4

. sejongrc

REFERER="https://ithub.korean.go.kr/user/total/database/electronicDicView.do"
SEQ="$1"
ATTIDX="$2"
FILESEQ="$3"
if test "$FILESEQ" = "1"; then
	ZIP=N
	FILESEQVALUES=""
	URL="https://ithub.korean.go.kr/common/boardFileDownload.do"
	OUTFILE="download/$SEQ.txt"
else
	ZIP=Y
	FILESEQVALUES="$FILESEQ"
	FILESEQ=1
	URL="https://ithub.korean.go.kr/common/boardFileZipDownload.do"
	OUTFILE="download/$SEQ.zip"
fi
DESC="Attachment of $SEQ"
mkdir -p download
mkdir -p corpus

if stat -s . >/dev/null 2>&1; then
	STATOPTION="-s"
else
	STATOPTION="-c st_size=%s"
fi

LOGFILE="html/attachment-$SEQ.html"
DATA="boardSeq=2&boardGb=T&boardType=CORPUS&articleSeq=$SEQ&roleGb=U&userId=0&fNo=$SEQ&thread=A&lan=1&attachIdx=$ATTIDX&fileSeq=$FILESEQ&fileSeqValues=$FILESEQVALUES&dataGb=E&regGb=1&isInsUpd=U&upperLowerGb=T&pageIndex=1&commentPageIndex=1&subListPageIndex=1&paramClass1Depth=11&paramClass2Depth=1157&searchStartDt=&searchEndDt=&searchDataGb=E&searchCondition=&searchKeyword=&beforePage=&searchWsType=&searchClass1Depth=&searchClass2Depth=&searchAnalType=&searchStartPublishYear=&searchEndPublishYear=&searchPublisher=&searchAuthor=&searchCclAll=&searchCclFree=&searchCommercialUseGb=&searchWorkChangeGb=&searchConditionPermit=&searchCclNoLimit=&searchCclLimit=&searchPlaceTop=&corpusBasketList=&searchYn=Y&cclGb=1&commercialUseGb=2&workChangeGb=2&orgFileSeq=1&posFileSeq=2&agreementYn=on&commentSeq=&commentContents="

SHOULDDOWNLOAD=Y
if test -f $OUTFILE; then
    eval $(stat $STATOPTION $OUTFILE)
    if test $st_size -gt 0; then
        echo "Skip already downloaded: $OUTFILE"
        SHOULDDOWNLOAD=
    else
        echo "Download again (0 sized file): $OUTFILE"
    fi
fi

if test -n "$SHOULDDOWNLOAD"; then
    curl_post 2> "$LOGFILE"
fi
echo "Log file: $LOGFILE"

if test "$(uname -s)" = "Darwin"; then
	ICONV="iconv -f cp949 -t utf8-mac"
else
	ICONV="iconv -f cp949 -t utf8"
fi

FILENAME=`cat $LOGFILE | grep Content-Disposition | $ICONV | tr -d ';\r' | awk -F= '{printf $NF}'`
echo "$OUTFILE $FILENAME" >> logs/download.log
if file "$OUTFILE" | grep -q Zip; then
    unzip -o "$OUTFILE" -d corpus 2>/dev/null
    echo "Unzipping $OUTFILE"
else
    if cmp "$OUTFILE" corpus/$FILENAME; then
        :
    else
        cp "$OUTFILE" corpus/$FILENAME
        echo "Copying $OUTFILE to corpus/$FILENAME"
    fi
    exit
fi
