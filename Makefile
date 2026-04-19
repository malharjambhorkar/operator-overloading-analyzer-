all:
	flex lexer.l
	bison -d parser.y
	g++ lex.yy.c parser.tab.c symtab.cpp -o analyzer

run:
	analyzer < input.cpp