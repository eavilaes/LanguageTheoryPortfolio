#fichero Makefile

OBJ = expresiones.o lexico.o 

expresiones : $(OBJ)     #segunda fase de la tradicción. Generación del código ejecutable 
	g++ -oexpresiones $(OBJ)

expresiones.o : expresiones.c        #primera fase de la traducción del analizador sintáctico
	g++ -c -oexpresiones.o  expresiones.c 
	
lexico.o : lex.yy.c		#primera fase de la traducción del analizador léxico
	g++ -c -olexico.o  lex.yy.c 	

expresiones.c : expresiones.y       #obtenemos el analizador sintáctico en C
	bison -d -oexpresiones.c expresiones.y

lex.yy.c: lexico.l	#obtenemos el analizador léxico en C
	flex lexico.l

clean : 
	rm  -f  *.c *.o 
