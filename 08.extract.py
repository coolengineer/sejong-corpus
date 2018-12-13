#!/usr/bin/env python
#
# (C) Copyright 2017 Hojin Choi <hojin.choi@gmail.com>
#

from __future__ import print_function, unicode_literals
from io import open
import re
import sys
import os

try: os.mkdir('logs')
except: pass

fds = {}
posseq_fd = open('logs/posseq.txt', 'wt')

try: os.mkdir( 'dictionary' )
except: pass

dictionaries = []

def get_fd(pos):
	if not pos in fds:
		filename = 'dictionary/%s.dic' % pos
		dictionaries.append(filename)
		fds[pos] = open(filename, "wt")
	return fds[pos]

def extract(path):
	print( "Loading: %s" % path )
	f = open(path)
	count = 0
	for line in f:
		count = count + 1
		line2 = re.sub( r'<[^>]+>', '', line )
		if line != line2:
			print("Invalid format: %s", line)
			continue
		posseq = []
		for w in re.split( '[\s+]+', line ):
			idx = w.rfind('/')
			if idx == -1:
				continue
			(word,pos) = (w[0:idx], w[idx+1:])
			word = word.strip()
			pos = pos.strip()
			if re.match( r'^[A-Z]+$', pos ):
				get_fd(pos).write(word + "\n")
			posseq.append(pos)
		posseq_fd.write( "%s\n" % ('+'.join(posseq)) )
	print( "Loaded %d words" % (count,) )
	if count > 0:
		f = open( "logs/morphanals.log", "a" )
		f.write( path + '\n' )
	
if __name__ == '__main__':
	for p in sys.argv[1:]:
		extract(p)

# vim: ts=4 noexpandtab sw=4 sts=4
