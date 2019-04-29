OBJ = expresiones.o lexico.o

demo: $(OBJ) #segunda fase de la traducción. Código ejecutable
	g++ -odemo $(OBJ)

expresiones.o: expresiones.c #primera fase de la traducción (sintáctico)
	g++ -c -oexpresiones.o expresiones.c

lexico.o: lex.yy.c #primera fase de la traduccion (léxico)
	g++ -c -olexico.o lex.yy.c

expresiones.c: expresiones.y #sintáctico en C
	bison -d -v -oexpresiones.c expresiones.y

lex.yy.c: lexico.l #léxico en C
	flex lexico.l

clean:
	rm -f *.o *.output
