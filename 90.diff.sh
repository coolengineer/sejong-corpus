#!/bin/bash
#
# (C) Copyright 2017 Hojin Choi <hojin.choi@gmail.com>
#
# vim: ts=4 noexpandtab sw=4 sts=4

mkdir -p ./tmp

. sejongrc

count=0
newcount=0
while read INFILE1
do
	count=$((count + 1))
	FILE=${INFILE1##*/}
	INFILE2=corpus-utf8/$FILE
	echo -n -e "Comparing $INFILE1 $INFILE2\r"
	if cmp $INFILE1 $INFILE2; then
		:
	else
		INFILE3=./tmp/$FILE
		cp "$INFILE1" "$INFILE3"
		patch_preexists "$INFILE3"
		if cmp $INFILE3 $INFILE2; then
			echo "$INFILE3" "$INFILE2" identical
			echo ""
			rm -f "$INFILE3"
			continue
		fi
		idx=0
		while true
		do
			PATCHFILE=patches/${FILE%.txt}-$(printf %03d $idx).patch
			if test -f $PATCHFILE; then
				idx=$(( idx + 1 ))
				continue
			fi
			break
		done
		newcount=$((newcount + 1))
		diff -u --label=old/$FILE $INFILE3 --label=new/$FILE $INFILE2 | tee $PATCHFILE
		rm -f "$INFILE3"
		echo "Patch file: $PATCHFILE created"
		echo "=============================================="
	fi
done <<EOT
$(find corpus-utf8.orig -name '*.txt')
EOT
echo ""
echo "$count files scanned.."
if test "$newcount" -gt 0; then
	echo "Add newly created patch files to git, please"
	echo "git add patches"
else
	echo "No new diff found"
fi
