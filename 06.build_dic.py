#!/usr/bin/env python
#
# (C) Copyright 2017 Hojin Choi <hojin.choi@gmail.com>
#

from __future__ import print_function, unicode_literals
from io import open
from bs4 import BeautifulSoup
import sys
import os

try: os.mkdir( 'logs' )
except: pass

outf = open('logs/word-analysis.txt', 'w')
outp = open('logs/pos-analysis.txt', 'w')
count = 0

def analyze(text):
	global count
	content = ''
	for s in str(text).split('\n'):
		try:
			(dummy,line) = s.split('\t',1)
			content = content + line + '\n'
		except:
			pass
	doc = BeautifulSoup( content, 'html.parser' )
	for e in doc.find_all('s'):
		try:
			for f in e.stripped_strings:
				posarr = []
				f = f.encode('utf8').replace("::","")
				for line in f.split('\n'):
					if line.find('\t') < 0:
						raise Exception("Invalid line: %s" % line)
					a = line[line.find('\t')+1:]
					word_posarr = []
					for b in a.split('+'):
						if b.find('/') < 0:
							raise Exception("Invalid line: %s" % line)
						word_posarr.append( b[b.find('/')+1:] )
					while len(word_posarr) > 0:
						if word_posarr[-1][0] != 'S':
							break
						word_posarr = word_posarr[0:-1]
					posarr.append( "+".join(word_posarr) )
				if len(posarr) > 0:
					p = " ".join(posarr)
					outf.write( '%s\n' % f )
					outp.write( '%s\n' % p )
					count = count + 1
		except Exception as e:
			pass
		#print "-----------".join(words)

def extract(path):
	global count
	doc = BeautifulSoup(open(path,'rb'), 'html.parser')
	#doc = ElementTree.parse(source,parser).getroot()
	if len(doc.find_all('body')) != 0:
		return
	print "Process:", path, 
	count = 0
	for text in doc.find_all('text'):
		analyze(text)
	print ":", count

if __name__ == '__main__':
    for p in sys.argv[1:]:
        extract(p)
# vim: ts=4 noexpandtab sw=4 sts=4
