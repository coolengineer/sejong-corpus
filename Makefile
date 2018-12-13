.PHONY: prepare all all-core clean clean-dic clean-all help
SHELL=/bin/bash
M=4

all:
	time -p make all-core

all-core: stamp.prepare stamp.dic

stamp.prepare: 00.prepare.sh
	@echo "** Checking programs"
	@./00.prepare.sh
	touch $@

logs/list.idx: 01.list.sh
	@echo "** Fetching corpus document list"
	@./01.list.sh

stamp.download: logs/list.idx 02.schedule.sh
	@echo "** Downloading attachments"
	@CONCURRENT=$(M) ./02.schedule.sh
	@touch $@

stamp.convert: stamp.download 05.convert.sh
	@echo "** Converting and patching corpus as UTF8"
	@./05.convert.sh
	@touch $@

logs/words.dic: stamp.convert 06.build_dic.py
	@echo "** Extracting morphemes"
	@rm -f logs/extract.log
	@find corpus-utf8 \( -name '?CT_*.txt' -o -name '?T*.txt' \) -print0 | xargs -0 ./06.build_dic.py $@ 2> logs/extract.log

logs/words-uniq.dic: logs/words.dic 07.jamo-conv.py
	@echo "** Sort and uniq morphemes"
	@echo "JAMO normalizing (JONGSUNG to CHOSUNG)..."
	@time -p ./07.jamo-conv.py logs/words.dic logs/words.tmp
	@echo "Sorting ..."
	@time -p sort -u logs/words.tmp > $@

stamp.dic: logs/words-uniq.dic 08.extract.py
	@echo "** Building dictionaries..."
	@./08.extract.py logs/words-uniq.dic
	touch $@

clean: clean-dic
	rm -f list.idx logs/*.txt stamp.convert

clean-dic:
	rm -rf dictionary stamp.dic

clean-all: clean
	rm -rf corpus-utf8 corpus dictionary download html logs stamp.* cookie.txt

help:
	@echo 'make all        : do all jobs'
	@echo 'make clean-all  : Delete all intermediate files and outputs'
	@echo 'make clean      : Delete all but downloaded files'
	@echo 'make clean-dic  : Delete dictionary files only'
