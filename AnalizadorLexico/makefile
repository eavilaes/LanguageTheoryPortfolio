LEX = flex
CXX = g++
ENTRADA = entrada.txt
SALIDA = salida.txt
LEXICO = lexico
$(LEXICO) : $(LEXICO).cpp
	$(CXX) -o $(LEXICO) $(LEXICO).cpp
	./$(LEXICO) $(ENTRADA) $(SALIDA)
$(LEXICO).cpp : $(LEXICO).l
	$(LEX) -o $(LEXICO).cpp $(LEXICO).l
clean :
	rm *.cpp
