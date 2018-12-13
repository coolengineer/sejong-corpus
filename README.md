#### sejong-corpus ####

국립국어원 세종 말뭉치를 다운로드하는 스크립트입니다.
세종 말뭉치 라이센스는 LICENSE.txt 입니다

### 사용법 ###

```
$ make
```

### 산출물 ###
* logs/list.idx : 국립국어원 언어정보나눔터 게시판 글 번호
* html/*:게시판 원문
* download/*:게시판 첨부파일
* corpus/*:첨부파일에서 말뭉치 추출
* corpus-utf8/*:말뭉치를 UTF8으로 변환
* logs/download.log: 첨부파일 다운로드 기록
* logs/words.txt: 단어/품사분석 추출 원본
* logs/words-uniq.txt: 한 단어 하나씩만 추출
* dictionary/(POS).dic 품사별 사전

### 제공되는 도구 ###
## 00.prepare.sh ##
* 필요한 유틸리티 혹은 인터프리터의 설치를 확인합니다

## 01.list.sh ##
* 언어정보나눔터 웹페이지에 접속하여 필요한 파일들의 리스트를 받아옵니다.
* logs/list.idx 파일에 글의 시쿽스가 저장됩니다.

## 02.schedule.sh ##
* 다운로드를 병렬로 진행하기 위한 스케쥴러입니다.
* logs/list.idx 를 각 다운로더에 분배합니다.
* make 명령에 동시에 접속할 수를 M이라는 변수로 지정할 수 있습니다. 기본은 4 입니다.
```
make M=10
```

## 03.getcontent.sh ##
* 02.schedule.sh 에 의해 실행되는 게시글 다운로더입니다.
* logs/list.idx 의 시작위치와 갯수를 입력받아 실행합니다. (Makefile 참조)

## 04.download.sh ##
* 03.getcontent.sh에 의해 실행되는 첨부파일 다운로더입니다.
* 웹서버는 첨부파일이 한 개인 경우 txt 파일로, 여러개인경우 zip 파일로 묶여 제공합니다.
* 받은 파일은 corpus/XXXXXX.txt 파일로 저장 혹은 압축이 풀립니다.
* 모든 파일은 XML 형식으로 제공되며, 원문, 형태소분석, 단어의미분석 등 여러 형식이 섞여 있습니다.

## 05.convert.sh
* 받은 파일은 utf16 포맷입니다. 이 파일을 utf8 형식으로 변환할 대상을 찾습니다.

## 05.convert-file.sh
* 원본, 출력 파일 이름을 받아 실제 변환을 수행합니다.
* UTF16을 UTF8으로 변환합니다.
* 05.convert-xml-tag.py 파일을 이용하여 xml escaping을 합니다.

## 05.convert-xml-tag.py
* XML 파일 본문에 CDATA 영역에 해당하는 내용이 XML 규약에 따라 escaping되어 있지 않습니다.
* 말뭉치를 구성하는 태그들을 제외한 태그형식의 '<', '>' 문자를 '&lt;', '&gt;' 로 변환합니다.

## 06.build_dic.py
* 받은 파일 중에서 형태소분석파일들을 대상으로 형태소 분석 결과만을 추출합니다.
* Makefile에 의해 입력 소스 파일 형식에 따라 인자로 해당 파일들만 넘겨 받습니다.
* Makefile에 의해 출력되는 결과는 logs/words.dic 에 저장됩니다.

## 07.jamo-conv.py
* 형태소 분석 결과중에서 특정 연구 결과는 종성을 그대로 종성 코드로 저장한 경우가 있습니다. 이를 초성으로 변환합니다.

## 08.extract.py
* 하나로 합쳐있는 형태소 분석 결과 뭉치에서 각 형태소별로 dictionary/(POS).dic 파일로 분할정리합니다.

