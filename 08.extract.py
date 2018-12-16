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
		for w in re.split( '[\s+]+', line ):
			idx = w.rfind('/')
			if idx == -1:
				continue
			(word,pos) = (w[0:idx], w[idx+1:])
			word = word.strip()
			pos = pos.strip()
			if re.match( r'^[A-Z]+$', pos ):
				get_fd(pos).write(word + "\n")
	print( "Word count: %d" % (count,) )
	
if __name__ == '__main__':
	for p in sys.argv[1:]:
		extract(p)

# vim: ts=4 noexpandtab sw=4 sts=4
