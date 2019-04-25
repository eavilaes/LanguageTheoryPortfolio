//============================================================================
// Name        : pruebaDSLP.cpp
// Author      : Elena Jurado
// Version     :
// Copyright   : Your copyright notice
// Description : Este proyecto ayuda a conocer el entorno gráfico del proyecto DSLP        Se incluyen diferentes ficheros de configuración para hacer pruebas con facilidad
//============================================================================

#include <iostream>
#include "entorno_dspl.h"

using namespace std;
/* Este procedimiento permite representar los dispositivos
 * en una situación inicial, es decir, los actuadores de tipo switch apagados
 * y los sensores sin ningún valor captado*/
void inicio (){
	entornoPonerSensor(25,25,S_temperature,0,"T1");
	entornoPonerSensor(250,250,S_smoke,0,"SH");
	entornoPonerAct_Switch(150,550,false,"CA");
	entornoBorrarMensaje();
}

int main() {
	if (entornoIniciar()){
	entornoPonerEscenario("Winter");	
	inicio();
	entornoPulsarTecla();
	entornoPonerSensor(25,25,S_temperature,18.2,"T1");
	entornoPonerAct_Switch(150,550,true,"CA");
	entornoMostrarMensaje("Calefacción encendida");
	entornoPausa(3);
	entornoBorrarMensaje();
	entornoPonerSensor(25,25,S_temperature,28.2,"T1");
	entornoPonerAct_Switch(150,550,false,"CA");
	entornoMostrarMensaje("Calefacción apagada");
	entornoPulsarTecla();
	entornoBorrarMensaje();

	entornoPonerEscenario("Fire");	
	inicio();
	entornoPausa(1);
	entornoPonerSensor(250,250,S_smoke,100,"SH");
	entornoMostrarMensaje("Alarma. Alta probabilidad de incendio");

	entornoAlarma();
	entornoPausa(1);

	entornoAlarma();
	entornoPausa(1);

    	entornoBorrarMensaje();
	
	entornoTerminar();
	}
	return 0;
}

