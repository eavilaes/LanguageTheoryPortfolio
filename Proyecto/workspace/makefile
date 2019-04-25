#fichero Makefile

FUENTE = pruebaDSLP.cpp

fin: prueba
	./prueba 
	
prueba : prueba.o entorno_dspl.o 
	g++ -oprueba entorno_dspl.o prueba.o -lallegro -lallegro_acodec -lallegro_audio -lallegro_color -lallegro_dialog -lallegro_font -lallegro_image -lallegro_main -lallegro_memfile -lallegro_physfs -lallegro_primitives -lallegro_ttf

entorno_dspl.o : entorno_dspl.cpp
	g++ -c entorno_dspl.cpp

prueba.o : $(FUENTE)
	g++ -c -oprueba.o $(FUENTE) 

clean :
	rm -f *.o	
