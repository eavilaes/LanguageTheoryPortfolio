contador: lex.yy.c
	g++ -o contador lex.yy.c
lex.yy.c: contador.l
	flex contador.l
clean:
	rm -f *.o
