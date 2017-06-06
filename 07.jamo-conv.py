#!/usr/bin/env python
# -*- encoding: utf8 -*-

import sys

convmap = {
    0x1100: 'ㄱ', 0x1102: 'ㄴ', 0x1103: 'ㄷ', 0x1105: 'ㄹ', 0x1106: 'ㅁ',
    0x1107: 'ㅂ', 0x1109: 'ㅅ', 0x110B: 'ㅇ', 0x110C: 'ㅈ', 0x110E: 'ㅊ',
    0x110F: 'ㅋ', 0x1110: 'ㅌ', 0x1111: 'ㅍ', 0x1112: 'ㅎ',
    0x11A8: 'ㄱ', 0x11AB: 'ㄴ', 0x11AE: 'ㄷ', 0x11AF: 'ㄹ', 0x11B7: 'ㅁ',
    0x11B8: 'ㅂ', 0x11BA: 'ㅅ', 0x11BC: 'ㅇ', 0x11BD: 'ㅈ', 0x11BE: 'ㅊ',
    0x11BF: 'ㅋ', 0x11C0: 'ㅌ', 0x11C1: 'ㅍ', 0x11C2: 'ㅎ',
}

while True:
	line = sys.stdin.readline()
	if not line:
		break
	line = line.decode('utf8')
	if ord(line[0]) < 0x100:
		continue
	if line.find('::') != -1:
		continue
	if line.find('\t') == -1:
		continue
	i = 0
	L = len(line)
	while i < L:
		ch = line[i:i+1]
		code = ord(ch)
		if code in convmap:
			sys.stdout.write(convmap[code])
		else:
			sys.stdout.write(ch.encode('utf8'))
		i = i + 1
