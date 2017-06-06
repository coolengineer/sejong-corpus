# sejong-corpus

# 사용법
$ make

# 산출물
dictionary/(POS).dic 코퍼스에서 사용된 품사별 사전
dictionary/combinations.txt: 품사조합

logs/list.idx : 국립국어원 언어정보나눔터 게시판 글 번호
html:게시판 원문
download:게시판 첨부파일
corpus:첨부파일에서 말뭉치 추출
corpus-utf8:말뭉치를 UTF8으로 변환
logs/download.log: 첨부파일 다운로드 기록
logs/word-analysis.txt: 단어/품사분석 추출 원본
logs/word-analysis-uniq.txt: 한 단어 하나씩만 추출
logs/posseq.txt: 추출된 단어별 품사 조합
logs/posseq-freq.txt: 추출된 단어별 품사 조합 빈도 (6개이상)
