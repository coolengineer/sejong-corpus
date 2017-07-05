.PHONY: prepare all all-core download clean clean-dic

all:
	time make all-core

all-core: stamp.prepare stamp.dic

stamp.prepare: 00.prepare.sh
	./00.prepare.sh
	touch $@

logs/list.idx: 01.list.sh
	@./01.list.sh

stamp.download: logs/list.idx 02.schedule.sh
	@./02.schedule.sh
	@touch $@

stamp.utf8: stamp.download 05.utf16to8.sh
	@./05.utf16to8.sh
	@touch $@

logs/word-analysis.txt: stamp.utf8 06.build_dic.py
	find corpus-utf8 -name '?CT_*.txt' -print0 | xargs -0 ./06.build_dic.py

logs/word-analysis-uniq.txt: logs/word-analysis.txt 07.jamo-conv.py
	cat logs/word-analysis.txt | ./07.jamo-conv.py | sort -u > logs/word-analysis-uniq.txt

stamp.dic: logs/word-analysis-uniq.txt 08.extract.py
	#build logs/posseq.txt and dictionary/*.dic
	./08.extract.py logs/word-analysis-uniq.txt
	for d in dictionary/*.dic; do sort $$d | uniq -c | awk '{if($$1 > 3) print $$2}' > $$d.tmp; mv $$d.tmp $$d; done
	#build dictionary/combinations.txt
	sort logs/posseq.txt | uniq -c | awk '{if( $$1 > 6 ) print $$0}' > dictionary/combinations.txt
	@#cat logs/posseq-freq.txt | awk '{print $$2}' | sort > dictionary/combinations.txt
	touch $@

clean: clean-dic
	rm -f list.idx logs/*.txt stamp.utf8

clean-dic:
	rm -rf dictionary stamp.dic
