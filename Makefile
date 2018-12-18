.PHONY: prepare all all-core dic clean clean-dic clean-all help
.PHONY:	step1 step2 step3 step4 step5 step6
.PHONY:	clean1 clean2 clean3 clean4 clean5 clean6
.PHONY: patch diff

SHELL=/bin/bash
M=4

all:
	@time -p make stamps/corpus
	@echo ""
	@echo "You can build dictionary, try this."
	@echo ""
	@echo "  make dic"
	@echo ""

all-core: stamps/dic

step1: logs/list.idx
step2: stamps/download
step3: stamps/corpus
step4: logs/words.dic
step5: logs/words-uniq.dic
step6 dic: stamps/dic

stamps/prepare: 00.prepare.sh
	@echo "** STEP 0. Checking programs"
	@./00.prepare.sh
	touch $@

logs/list.idx: stamps/prepare 10.list.sh
	@echo "** STEP 1. Fetching corpus document list"
	@./10.list.sh

stamps/download: logs/list.idx 20.schedule.sh
	@echo "** STEP 2. Downloading attachments"
	@CONCURRENT=$(M) ./20.schedule.sh
	@touch $@

CORPUS_FILES := $(wildcard corpus-utf8/*.txt)
stamps/corpus: stamps/download 30.convert.sh $(CORPUS_FILES)
	@echo "** STEP 3. Converting and patching corpus as UTF8"
	@./30.convert.sh
	@./33.patch.sh
	@touch $@

MORPHEME_FILES := $(wildcard logs/*.morph.txt)
logs/words.dic: stamps/corpus 60.build_dic.py $(MORPHEME_FILES)
	@echo "** STEP 4. Extracting morphemes"
	@./40.extract.sh $@

logs/words-uniq.dic: logs/words.dic
	@echo "** STEP 5. Sort and uniq morphemes"
	@echo Sorting... from logs/words.dic to $@
	@time -p sort -u logs/words.dic > $@
	@echo "Done..."

stamps/dic: logs/words-uniq.dic ./60.build_dic.py
	@echo "** STEP 6. Building dictionaries..."
	@rm -rf dictionary
	@mkdir dictionary
	@echo Build from logs/words-uniq.dic
	@./60.build_dic.py logs/words-uniq.dic
	@echo "Dictionary extracted: ./dictionary"
	@touch $@

stamps/utf8.orig:
	@echo "** DIFF prepare. Fetching original corpus (in corpus-utf8.orig)..."
	@DESTDIR=corpus-utf8.orig ./30.convert.sh
	@touch $@

diff: stamps/utf8.orig
	@echo "** DIFF. Make diff file between corpus-utf8.orig and corpus-utf8"
	@./90.diff.sh

patch:
	@echo "** PATCH. Test patch"
	@./33.patch.sh

clean: clean-dic
	rm -f logs/list.idx stamps/corpus

clean-dic:
	rm -rf dictionary stamps/dic logs/*.dic

clean-all: clean
	rm -rf corpus-utf8 corpus dictionary download html logs stamps/*

clean1:
	rm -f logs/list.idx
clean2:
	rm -f stamps/download
clean3:
	rm -f stamps/corpus
clean4:
	rm -f logs/words.dic
clean5:
	rm -f logs/words-uniq.dic
clean6:
	rm -f stamps/dic

help:
	@echo 'make all        : do all jobs'
	@echo 'make clean-all  : Delete all intermediate files and outputs'
	@echo 'make clean      : Delete all but downloaded files'
	@echo 'make clean-dic  : Delete dictionary files only'
