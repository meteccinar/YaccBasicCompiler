all: lex yacc 
	g++ lex.yy.c y.tab.c -ll -o compile

yacc: compile.y
	yacc -d  compile.y

lex: compile.l
	lex compile.l

clean: lex.yy.c y.tab.c compile y.tab.h
	rm lex.yy.c y.tab.c compile y.tab.h
