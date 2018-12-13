#!/usr/bin/env python
#
# (C) Copyright 2017 Hojin Choi <hojin.choi@gmail.com>
#

import re
import sys
import os

try: os.mkdir('logs')
except: pass

fds = {}
posseq_fd = open('logs/posseq.txt', 'wt')

try: os.mkdir( 'dictionary' )
except: pass

def get_fd(pos):
	if not pos in fds:
		fds[pos] = open( "dictionary/%s.dic" % pos, "wt")
	return fds[pos]

def extract(path):
	print( "Loading: %s" % path )
	f = open(path)
	count = 0
	skipcount = 0
	for line in f:
		idx = line.find('\t')
		if idx == -1:
			continue
		line = line[idx+1:]
		count = count + 1
		line = re.sub( r'<[^>]+>', '', line )
		posseq = []
		skip = False
		symcount = 0
		for w in re.split( '[\s+]+', line ):
			idx = w.rfind('/')
			if idx == -1:
				continue
			(word,pos) = (w[0:idx], w[idx+1:])
			word = word.strip()
			pos = pos.strip()
			if re.match( r'^[A-Z]+$', pos ):
				get_fd(pos).write(word + "\n")
			if pos[0] == 'U':
				skip = True
			if pos[0] == 'S':
				symcount = symcount + 1
			posseq.append(pos)
		if symcount > 0:
			if symcount > 1:
				skip = True
			elif posseq[-1][0] == 'S':
				posseq = posseq[0:-1]
		if len(posseq) == 0:
			continue
		if posseq[0][0] in('J','E'):
			skip = True
		if skip:
			#print( "Skip %s" % ('+'.join(posseq)) )
			skipcount = skipcount + 1
		else:
			posseq_fd.write( "%s\n" % ('+'.join(posseq)) )
	print( "Loaded %d words, skip %d" % (count,skipcount) )
	if count > 0:
		f = open( "logs/morphanals.log", "a" )
		f.write( path + '\n' )
	
if __name__ == '__main__':
	for p in sys.argv[1:]:
		extract(p)

# vim: ts=4 noexpandtab sw=4 sts=4
