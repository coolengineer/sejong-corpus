#!/usr/bin/env python
# -*- encoding: utf8 -*-
#
# (C) Copyright 2017 Hojin Choi <hojin.choi@gmail.com>
#

from __future__ import print_function, unicode_literals
from io import open
import re
import sys
import os

convmap = {
	0x1100: 'ㄱ', 0x1102: 'ㄴ', 0x1103: 'ㄷ', 0x1105: 'ㄹ', 0x1106: 'ㅁ',
	0x1107: 'ㅂ', 0x1109: 'ㅅ', 0x110B: 'ㅇ', 0x110C: 'ㅈ', 0x110E: 'ㅊ',
	0x110F: 'ㅋ', 0x1110: 'ㅌ', 0x1111: 'ㅍ', 0x1112: 'ㅎ',
	0x11A8: 'ㄱ', 0x11AB: 'ㄴ', 0x11AE: 'ㄷ', 0x11AF: 'ㄹ', 0x11B7: 'ㅁ',
	0x11B8: 'ㅂ', 0x11BA: 'ㅅ', 0x11BC: 'ㅇ', 0x11BD: 'ㅈ', 0x11BE: 'ㅊ',
	0x11BF: 'ㅋ', 0x11C0: 'ㅌ', 0x11C1: 'ㅍ', 0x11C2: 'ㅎ',
}

infile = sys.argv[1]
outfile = sys.argv[2]

lines = open(infile, mode="r", encoding="utf-8").read()
outf = open(outfile, mode="w", encoding="utf-8")
for line in lines:
	i = 0
	L = len(line)
	out = ''
	while i < L:
		ch = line[i:i+1]
		code = ord(ch)
		if code in convmap:
			out += convmap[code]
		else:
			out += ch
		i = i + 1
	outf.write(out)

# vim: ts=4 noexpandtab sw=4 sts=4
