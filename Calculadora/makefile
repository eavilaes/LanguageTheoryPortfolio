OBJ = expresiones.o lexico.o tabla.o

IN = entrada.txt
OUT = salida.txt

execute: expresiones
	./expresiones $(IN) $(OUT)

expresiones : $(OBJ)     #segunda fase de la tradicción. Generación del código ejecutable 
	g++ -oexpresiones $(OBJ)

expresiones.o : expresiones.c        #primera fase de la traducción del analizador sintáctico
	g++ -c -oexpresiones.o  expresiones.c 
	
lexico.o : lex.yy.c		#primera fase de la traducción del analizador léxico
	g++ -c -olexico.o  lex.yy.c

tabla.o : tabla.c
	g++ -c -otabla.o tabla.c

expresiones.c : expresiones.y       #obtenemos el analizador sintáctico en C
	bison -d -v -oexpresiones.c expresiones.y

lex.yy.c: lexico.l	#obtenemos el analizador léxico en C
	flex lexico.l

clean : 
	rm  -f  *.o *.output
