#ejemplo de fichero Makefile
LEX = flex
CXX = g++
NOMBRE = ejercicio_sesion3
FICHERO = entrada.txt

fin : a.out
	./a.out $(FICHERO)
a.out : lex.yy.c
	$(CXX) lex.yy.c
lex.yy.c : $(NOMBRE).l
	$(LEX) $(NOMBRE).l
clean :
	rm -f *.c
