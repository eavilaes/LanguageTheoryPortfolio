//============================================================================
// Name		: salida.cpp
// Author	: Eric Ávila
// Version	: 
// Copyright	: Your copyright notice
// Description	: Este proyecto ayuda a conocer el entorno gráfico del proyecto DSLP. Se incluyen diferentes ficheros de configuración para hacer pruebas con facilidad
//============================================================================

#include <iostream>
#include "entorno_dspl.h"

using namespace std;

/* Este procedimiento permite representar los dispositivos
 * en una situación inicial, es decir, los actuadores de tipo switch apagados
 * y los sensores sin ningún valor captado*/
void inicio(){
	entornoPonerSensor(-2147483648,21,S_temperature,0,"T1");
	entornoPonerSensor(250,250,S_smoke,0,"SH");
}

