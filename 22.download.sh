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
PROCNUM="$4"
TRYCOUNT=${TRYCOUNT-5}
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
PREFIX="($SEQ) "
if test -n "$PROCNUM"; then
	PREFIX="[$PROCNUM] $PREFIX"
fi
mkdir -p download
mkdir -p corpus

if stat -s . >/dev/null 2>&1; then
	STATOPTION="-s"
else
	STATOPTION="-c st_size=%s"
fi

LOGFILE="html/attachment-$SEQ.html"
DATA="boardSeq=2&boardGb=T&boardType=CORPUS&articleSeq=$SEQ&roleGb=U&userId=0&fNo=$SEQ&thread=A&lan=1&attachIdx=$ATTIDX&fileSeq=$FILESEQ&fileSeqValues=$FILESEQVALUES&dataGb=E&regGb=1&isInsUpd=U&upperLowerGb=T&pageIndex=1&commentPageIndex=1&subListPageIndex=1&paramClass1Depth=11&paramClass2Depth=1157&searchStartDt=&searchEndDt=&searchDataGb=E&searchCondition=&searchKeyword=&beforePage=&searchWsType=&searchClass1Depth=&searchClass2Depth=&searchAnalType=&searchStartPublishYear=&searchEndPublishYear=&searchPublisher=&searchAuthor=&searchCclAll=&searchCclFree=&searchCommercialUseGb=&searchWorkChangeGb=&searchConditionPermit=&searchCclNoLimit=&searchCclLimit=&searchPlaceTop=&corpusBasketList=&searchYn=Y&cclGb=1&commercialUseGb=2&workChangeGb=2&orgFileSeq=1&posFileSeq=2&agreementYn=on&commentSeq=&commentContents="

if test "$(uname -s)" = "Darwin"; then
	ICONV="iconv -f cp949 -t utf8-mac"
else
	ICONV="iconv -f cp949 -t utf-8"
fi

TCOUNT=0
while test $TCOUNT -lt $TRYCOUNT
do
	let "TCOUNT++"
	if test -f "$OUTFILE" -a -f "$LOGFILE"; then
		eval $(stat $STATOPTION $OUTFILE)
		if test $st_size -gt 0; then
			FILENAME=`grep -a Content-Disposition $LOGFILE | $ICONV | tr -d ';\r' | awk -F= '{printf $NF}'`
			if test -n "$FILENAME"; then
				echo "${PREFIX}Download log file: $LOGFILE"
				break
			fi
			echo "Warn: Oops I can't determine the attached filename for $OUTFILE (Try $TCOUNT/$TRYCOUNT)"
		else
			echo "${PREFIX}Download again (0 sized file): $OUTFILE (Try $COUNT/$TRYCOUNT)"
			CONTENTLENGTH=`grep -a '< Content-Length' $LOGFILE | tr -d ';\r' | awk '{printf $NF}'`
			if test "$CONTENTLENGTH" -eq "0"; then
				echo "${PREFIX}Skip zero sized file downloading: $OUTFILE (Try $COUNT/$TRYCOUNT) (Check $LOGFILE)"
				exit 0
			fi
		fi
		sleep 1
	else
		echo "${PREFIX}Download $OUTFILE (Try $TCOUNT/$TRYCOUNT)"
	fi

	rm -f "$LOGFILE" "$OUTFILE"
	curl_post
done

if test "$TCOUNT" -ge "$TRYCOUNT"; then
	echo "ERROR: Try out error to download $OUTFILE from $URL ($TCOUNT/$TRYCOUNT) (Log $LOGFILE)"
	exit 1
fi

echo "${PREFIX}Download file: $OUTFILE, orginal $FILENAME"
echo "${PREFIX}$OUTFILE [$FILENAME]" >> logs/download.log
if test "$ZIP" = "Y"; then
	if test "$OUTFILE.stamp" -nt "$OUTFILE" 2>/dev/null ; then
		echo "${PREFIX}Skip unzipping $OUTFILE, already done"
	else
		unzip -o "$OUTFILE" -d corpus 2>/dev/null | while read log; do echo "${PREFIX} $log"; done
		echo "${PREFIX}Unzipping $OUTFILE"
		touch "$OUTFILE.stamp"
	fi
else
	if test -z "$FILENAME"; then
		echo "Can't determine filename, it should be found in $LOGFILE"
		exit 1
	fi
	if cmp "$OUTFILE" corpus/$FILENAME 2>/dev/null; then
		:
	else
		cp "$OUTFILE" corpus/$FILENAME
		echo "${PREFIX}Copying $OUTFILE to corpus/$FILENAME"
	fi
fi

