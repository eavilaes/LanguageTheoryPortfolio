/**

	TEORÍA DE LENGUAJES
	Curso 2018/2019

	Nombre: entorno_dspl.h
	Descripción: Especificación del Entorno Gráfico para el proyecto DSPL
	     	 	 versión allegro 5
	Autor:	Elena Jurado
    Fecha última modificación: 9/04/2019

*/

#ifndef ENTORNO_DSPL_H_
#define ENTORNO_DSPL_H_

#include <string>
using namespace std;

// -------------------------------------------------------------
// Definicion de tipos para sensores
// -------------------------------------------------------------

enum TipoSensor {S_temperature,S_smoke,S_light};


// -------------------------------------------------------------
// Declaración de interfaz (módulos) PÚBLICA
// -------------------------------------------------------------


 /*
  *	POST: Inicia el entorno gráfico, abriendo una ventana de 800 columnas y 600 filas
  */
bool entornoIniciar ();


 /*
  *	POST: Libera los recursos usados por el entorno gráfico
  */
void entornoTerminar ();


/*
  * PRE: { 0 <= fila <= 400 }
  *      { 0 <= columna <= 600 }
  * POST: Coloca en la posición (fila,columna) del plano un círculo que representa al sensor
  *       El color de fondo depende de "ts" (tipo del sensor)
  *       Si num != 0, este valor (valor detectado por el sensor) aparece en el centro del círculo
  *       En caso contrario, el circulo queda vacío (si el sensor no ha detectado ningún valor)
  *       "alias" es la etiqueta que aparece sobre el círculo para identificar al sensor
  */
void entornoPonerSensor    (int fila, int columna, TipoSensor ts, float num, string alias);


/*
 * PRE: { 0 <= fila <= 400 }
 *      { 0 <= columna <= 600 }
 * POST: Coloca en la posición (fila,columna) del plano un cuadrado que representa actuador de tipo switch
 *       Si encendido es true, el color del cuadrado es rojo y aparece dentro la palabra ON
 *       En caso contrario, el color del cuadrado es azul y aparece dentro la palabra OFF
 *       "alias" es la etiqueta que aparece sobre el cuadrado para identificar al actuador
 */
void entornoPonerAct_Switch      (int fila, int columna, bool encendido, string alias);


/*
 * POST: Hace sonar la alarma
 * */
void entornoAlarma();


/*
 * POST:	Escribe un mensaje, indicado por el parámetro "msg", en la zona reservada para ello
 */
void entornoMostrarMensaje (string msg);


/*
 * POST:	Borra el mensaje (limpia la zona en la que aparecen los mensajes)
 */
void entornoBorrarMensaje ();


/*
 * POST:	Escribe el nombre del escenario en la zona habilitada
 */
void entornoPonerEscenario(string nombre);


/*
 * POST:	Interrumpe la ejecución del programa hasta que se pulse una tecla,
 * 			además, muestra un mensaje al usuario indicándole que debe pulsar una tecla
 */
void entornoPulsarTecla();


/*
* PRE: 0 < pausa  (es el tiempo en segundos que dura la pausa)
* POST: lleva a cabo una pausa en la ejecución del programa
*/
void entornoPausa(float pausa);


/*
 * PRE: { 0 <= fila1, fila2 <= 400 }
 *      { 0 <= col1, col2 <= 600 }
 * POST: Dibuja una línea desde el punto de coordenadas (fila1, col1) hasta el punto (fila2,col2)
 * */
void entornoLinea (int fila1, int col1, int fila2, int col2);



#endif
