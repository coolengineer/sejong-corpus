#!/usr/bin/env python
#
# (C) Copyright 2017 Hojin Choi <hojin.choi@gmail.com>
#

from __future__ import absolute_import, print_function, unicode_literals
from io import open
from bs4 import BeautifulSoup
import sys
import os
import re

lastchunk = ''


def analyze_chunk(outf, text):
    global lastchunk
    samples = []
    count = 0

    try:
        text = text.replace("::", "")

        # for f in text:
        #     f = f.replace("::", "")
        #     for line in f.split('\n'):
        #         tabidx = line.find('\t')
        #         if tabidx < 0:
        #             raise Exception("Invalid line: [%s]" % line)
        #         a = line[tabidx + 1:]
        #         samples.append(a)
        #         for b in re.split(' ?\+ ?', a):
        #             b = b.strip()
        #             slashidx = b.rfind('/')
        #             if slashidx < 0:
        #                 continue
        #             outf.write('%s\n' % b)
        # print(text)
        outf.write('%s\n' % text)
        count += 1
    except Exception as e:
        pass

    if len(samples):
        lastchunk = u'\n'.join(samples)
        # In python3, type(u'') is str
        # In python2, type(u'') is unicode
        # print() with sys.stderr function requires 'bytes' in python2, so encode() needed.
        # print() in python3, keep it not touched
        if not isinstance(lastchunk, str):
            lastchunk = lastchunk.encode('utf-8')

    return count


def analyze_type1(outf, text):
    count = 0
    content = ''
    for t in text.split('\n'):
        try:
            # Screening only tab contained lines
            (dummy, line, morph) = t.split('\t', 2)
            content = content + line + ' '

        except Exception as e:
            pass
    count += analyze_chunk(outf, content)
    return count


def analyze_type2(outf, text):
    count = 0
    content = []

    for t in text.split('\n'):
        try:
            # Screening only tab contained lines
            t = re.sub('<phon>.*</phon>', '', t)
            (dummy, line, morph) = t.split('\t', 2)
            content.append(line)

        except Exception as e:
            pass

    count += analyze_chunk(outf, ' '.join(content))
    return count


def extract(outfile, path, idx, total):
    outf = open(outfile, mode='at', encoding='utf-8')
    content = open(path, mode='rt', encoding='utf-8').read()
    doc = BeautifulSoup(content, 'html.parser')

    count = 0

    texts = doc.select('text body p, text p')
    for text in texts:
        text = text.get_text()
        count += analyze_type1(outf, text)

    texts = doc.select('text s')
    for text in texts:
        text = text.get_text()
        count += analyze_type2(outf, text)

    print("(%d/%d) Extract %s >> %s %d sentences" % (idx, total, path, outfile, count))
    if not sys.stderr.isatty():
        print("(%d/%d) Extract %s >> %s %d sentences" % (idx, total, path, outfile, count), file=sys.stderr)
        print("Last chunk", file=sys.stderr)
        print(lastchunk, file=sys.stderr)


if __name__ == '__main__':
    try:
        if len(sys.argv) != 3:
            print("Usage: %s <corpus file> [<corpus file>...] <sentence extract file>" % sys.argv[0])
            sys.exit(0)
        files = sys.argv[1:-1]
        outfile = sys.argv[-1]

        # Truncate
        outf = open(outfile, mode='w')
        outf and outf.close()

        total = len(files)
        count = 0
        for p in files:
            count += 1
            if 'TOTAL' in os.environ and 'COUNT' in os.environ:
                count = int(os.environ['COUNT'] or 0)
                total = int(os.environ['TOTAL'] or 0)
            extract(outfile, p, count, total)
    except KeyboardInterrupt:
        print("\nOk, take a rest!")
    except:
        raise

outf.close()

# vim: ts=4 noexpandtab sw=4 sts=4
