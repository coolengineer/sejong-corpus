#!/usr/bin/env python
# -*- encoding: utf8 -*-
#
# (C) Copyright 2018 Hojin Choi <hojin.choi@gmail.com>
#

from __future__ import print_function, unicode_literals
from io import open

import sys
import re

knowntags = [ "s", "u", "anchor", "sp", "speaker", "when", "text", "author", "timeline", "resp", "laughing", "stage", "respstmt", "vocal", "trunc", "l", "name", "change", "item", "phon", "unclear", "pb", "pause", "quotation", "tname", "person", "latching/", "trunc-iu/", "note", "q", "textclass", "sourcedesc", "revisiondesc", "publicationstmt", "projectdesc", "profiledesc", "language", "langusage", "idno", "extent", "encodingdesc", "editorialdecl", "distributor", "creation", "availability", "catref", "samplingdecl", "lg", "scnum", "bibl", "publisher", "pubplace", "notesstmt", "pause/", "gap", "poem", "event", "read", "role", "castitem", "settingdesc", "particdesc", "group", "writing", "form", "entry", "def", "p", "name1", "editionstmt", "edition", "singing", "front", "dia", "imprint", "biblstruct", "name2", "setting", "name4", "ref", "qx", "unclear-s", "formula", "name3", "name6", "kinesics", "set", "name5", "castlist", "sz", "applauding", "name18", "back", "name7", "name8", "name10", "shead", "name13", "name9", "name1", "name37", "name28", "actnum", "no", "name11", "head", "actor", "name17", "line", "life", "name14", "name12", "name3", "reading", "emph", "name2", "name32", "name19", "ieda", "samplingdesc", "name15", "tag_name", "name31", "name30", "name29", "author", "body", "stanza", "sound", "photographer", "name39", "name27", "name26", "name25", "name23", "lb", "name16", "b", "quote", "number", "name33", "name22", "name21", "dateate", "datdate", "name4", "i", "human", "tt", "title", "strong", "img", "html", "em", "case", "center", "bbc", "address", "date", "source", "page", "!entity", "titlestmt", "teiheader", "sponsor", "filedesc", "tei.2", "br", "translator", "h1", "enter", "g", "translater", "textarea", "frameset", "r", "option", "num", "font", "ul", "ol", "dl", "th", "frame", "insert", "applet", "normalization" ]

# <동철아,    </SS + 동철/NNP + 아/JKV + ,/SP
r = re.compile(r'(.*?)(<+)([^ ><]+)( ?[^><]*)(>*)(.*)')

def escape_unknown_tag(line):
	m = r.match(line)
	if m:
		tag = m.group(3).lower()
		tag = tag[1:] if tag[0] == '/' else tag
		if tag not in knowntags:
			if tag.find('@') == -1:
				print(tag.encode('utf8'), file=sys.stderr)
			lt = m.group(2).replace("<", "&lt;")
			gt = m.group(5).replace(">", "&gt;")
			line = '%s%s%s%s%s%s' % (m.group(1), lt, m.group(3), m.group(4), gt, escape_unknown_tag(m.group(6)))
		else:
			line = '%s<%s%s>%s' % (m.group(1), m.group(3), m.group(4), escape_unknown_tag(m.group(6)))
	return line

while True:
	line = sys.stdin.readline()
	line = line.decode('utf8')
	if not line:
		break
	line = line.rstrip()
	line = escape_unknown_tag(line)
	print(line.encode('utf8'))

# vim: ts=4 noexpandtab sw=4 sts=4
