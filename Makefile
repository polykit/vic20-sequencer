all: tokenize run

tokenize:
	petcat -w2 -o vicseq.prg -- vicseq.bas

run:
	xvic -basicload vicseq.prg
