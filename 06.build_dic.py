#!/usr/bin/env python
from bs4 import BeautifulSoup
import sys
import os

try: os.mkdir( 'logs' )
except: pass

outf = open('logs/word-analysis.txt', 'w')
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
		for f in e.stripped_strings:
			outf.write( ('%s\n' % f).encode('utf8') )
			count = count + 1

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
