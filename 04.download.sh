#!/bin/bash

. sejongrc

REFERER="https://ithub.korean.go.kr/user/total/database/electronicDicView.do"
URL="https://ithub.korean.go.kr/common/boardFileZipDownload.do"
SEQ="$1"
ATTIDX="$2"
OUTFILE="download/$SEQ.zip"
DESC="Attachment of $SEQ"
mkdir -p download
mkdir -p corpus
if test -f $OUTFILE; then
    eval $(stat -s $OUTFILE)
    if test $st_size -gt 0; then
        echo "Skip already downloaded: $OUTFILE"
        exit 0
    fi
    echo "Download again (0 sized file): $OUTFILE"
fi
LOGFILE="html/attachment-$SEQ.html"
DATA="boardSeq=2&boardGb=T&boardType=CORPUS&articleSeq=$SEQ&roleGb=U&userId=0&fNo=$SEQ&thread=A&lan=1&attachIdx=$ATTIDX&fileSeq=1&fileSeqValues=1%2C2&dataGb=E&regGb=1&isInsUpd=U&upperLowerGb=T&pageIndex=1&commentPageIndex=1&subListPageIndex=1&paramClass1Depth=11&paramClass2Depth=1157&searchStartDt=&searchEndDt=&searchDataGb=E&searchCondition=&searchKeyword=&beforePage=&searchWsType=&searchClass1Depth=&searchClass2Depth=&searchAnalType=&searchStartPublishYear=&searchEndPublishYear=&searchPublisher=&searchAuthor=&searchCclAll=&searchCclFree=&searchCommercialUseGb=&searchWorkChangeGb=&searchConditionPermit=&searchCclNoLimit=&searchCclLimit=&searchPlaceTop=&corpusBasketList=&searchYn=Y&cclGb=1&commercialUseGb=2&workChangeGb=2&orgFileSeq=1&posFileSeq=2&agreementYn=on&commentSeq=&commentContents="
curl_post 2> "$LOGFILE"

FILENAME=`cat $LOGFILE | grep Content-Disposition | iconv -f cp949 -t utf8-mac | tr -d ';\r' | awk -F= '{printf $NF}'`
echo "$OUTFILE $FILENAME" >> logs/download.log
if file "$OUTFILE" | grep -q Zip; then
    unzip -o "$OUTFILE" -d corpus 2>/dev/null
    echo "Unzipping $OUTFILE"
fi
