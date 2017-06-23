#!/usr/bin/env python
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
	for line in f:
		idx = line.find('\t')
		if idx == -1:
			continue
		line = line[idx+1:]
		count = count + 1
		line = re.sub( r'<[^>]+>', '', line )
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
		if len(posseq) > 0:
			if posseq[0][0] not in('J','E','S') and posseq[-1][0] not in ('S'):
				posseq_fd.write( "%s\n" % ('+'.join(posseq)) )
			#pass
		#if len(posseq) == 1 and posseq[0] == 'EC':
			#posseq_fd.write( line )
	print( "Loaded %d words" % count )
	if count > 0:
		f = open( "logs/morphanals.log", "a" )
		f.write( path + '\n' )
	
if __name__ == '__main__':
	for p in sys.argv[1:]:
		extract(p)

