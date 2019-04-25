/**

 TEORÍA DE LENGUAJES
 Curso 2018/2019

 Nombre: entorno.cpp
 Descripción: Implementación del TAD Entorno para el proyecto SPDL

 Autor:	Elena Jurado

 Fecha última modificación: 9/04/2019 Allegro5

 */

#include "entorno_dspl.h"

#include <stdlib.h>
#include <allegro5/allegro_primitives.h>
#include <allegro5/allegro_font.h>
#include <allegro5/allegro_ttf.h>
#include <allegro5/allegro_image.h>
#include <allegro5/allegro5.h>
#include <allegro5/allegro_audio.h>
#include <allegro5/allegro_acodec.h>


#include <iostream>
#include <fstream>
#include <sstream>
#include <cstring>

using namespace std;

// -------------------------------------------------------------
// Definicion de constantes privadas
// -------------------------------------------------------------
// Definición de colores que usa el entorno

const int COLOR_AZUL      		= 1;
const int COLOR_BLANCO    		= 2;
const int COLOR_ROJO      		= 3;
const int COLOR_NEGRO     		= 4;
const int COLOR_GRIS      		= 5;
const int COLOR_AMARILLO  		= 6;
const int COLOR_AMARILLO_CLARO  = 7;
const int COLOR_VERDE     		= 8;
const int COLOR_GRIS_CLARO 		= 9;

//Tamaño de la ventana gráfica
const int ANCHO_VENTANA = 800;
const int ALTO_VENTANA  = 600;

// Definicón de constantes para posicionar los elementos dentro del plano
int ORIGEN		= 100;
const int RADIO = 26;

ALLEGRO_DISPLAY     *display;   			//ventana gráfica
ALLEGRO_FONT        *font;   				//fuente del texto
ALLEGRO_EVENT_QUEUE *colaEventos = NULL;   	//cola de eventos (pulsación de teclas)
ALLEGRO_SAMPLE 		*sample = NULL; 		//Declara un sample para simular el sonido de la alarma


// -------------------------------------------------------------
// Definición de módulos PRIVADOS
// -------------------------------------------------------------


// define el color en función del valor de color

ALLEGRO_COLOR makecolor2(int color) {

	ALLEGRO_COLOR alColor;

	switch (color) {
	case COLOR_BLANCO:
		alColor = al_map_rgb (255, 255, 255);
		break;
	case COLOR_ROJO:
		alColor = al_map_rgb (255,   69,  0);
		break;
	case COLOR_NEGRO:
		alColor = al_map_rgb (0,    0,   0);
		break;
	case COLOR_AZUL:
		alColor = al_map_rgb (70,   150, 255);
		break;
	case COLOR_GRIS:
		alColor = al_map_rgb ( 47, 100, 100);
		break;
	case COLOR_AMARILLO:
		alColor = al_map_rgb ( 255, 255, 000);
		break;
	case COLOR_AMARILLO_CLARO:
		alColor = al_map_rgb ( 255,160,122);
		break;
	case COLOR_VERDE:
		alColor = al_map_rgb ( 036,231,017);
		break;
	case COLOR_GRIS_CLARO:
		alColor = al_map_rgb ( 192,192,192);
		break;
	default:
		alColor = al_map_rgb (255, 255, 255);
		break; //color blanco
	}

	return alColor;
}

void invertirFC(int &fila, int &columna) {
	int aux = columna;
	columna = fila;
	fila = aux;
}

string toString(float numero) {
	stringstream flujo;
	string cadena;
	flujo << numero;
	flujo >> cadena;
	return cadena;
}

// -------------------------------------------------------------
// Definición de módulos PÚBLICOS
// -------------------------------------------------------------

bool entornoIniciar() {

	// Iniciar el entorno: ventana, teclado y sonido

	if (al_init()){
	al_install_keyboard();
	if(!al_install_audio()){
	   fprintf(stderr, "failed to initialize audio!\n");
	   return false;
	}
	if(!al_init_acodec_addon()) {
	   fprintf(stderr, "failed to initialize audio codecs!\n");
	   return false;
	}
	if (!al_reserve_samples(1)){
	   fprintf(stderr, "failed to reserve samples!\n");
	   return false;
	}


	sample = al_load_sample ("test.wav");

	if (!sample) {
	   printf( "Audio clip sample not loaded!\n" );
	   return false;
	}


	al_set_new_display_option(ALLEGRO_SINGLE_BUFFER, 1, ALLEGRO_REQUIRE);
	al_set_new_display_flags (ALLEGRO_WINDOWED);


	display = al_create_display(ANCHO_VENTANA,ALTO_VENTANA);
	al_init_primitives_addon(); //

	al_init_font_addon();
	al_init_ttf_addon();


	// carga la fuente de los textos con tamaño 18
	font = al_load_ttf_font("DroidSerif-Regular.ttf",18, 0);

    // fondo de la ventana cubierto con el color negro
    al_clear_to_color(makecolor2(COLOR_NEGRO));
    al_set_window_title(display, "Proyecto TL");

    // se prepara para recibir datos del teclado
    colaEventos = al_create_event_queue();
    al_register_event_source(colaEventos, al_get_keyboard_event_source());


    int fila, columna, color;
    fila = 25; columna =ORIGEN; color = COLOR_BLANCO;
    al_draw_text(font,makecolor2(color), columna,fila, ALLEGRO_ALIGN_LEFT,"Demo Smart Place Language");
    fila = 50;
    al_draw_text(font, makecolor2(color), columna,fila,  ALLEGRO_ALIGN_LEFT,"Proyecto TL      Curso 2018/19");
    al_draw_rectangle( ORIGEN,ORIGEN,700,500,makecolor2(color), 2);

    fila=520;columna=40;color=COLOR_GRIS;
    al_draw_text(font,makecolor2(color), columna,fila, ALLEGRO_ALIGN_LEFT,"Mensajes");
    al_draw_rectangle(ORIGEN+50,520,700,550,makecolor2(color), 1);


    //Info de Sensores
    fila = 100; columna = 5;
    al_draw_text(font,makecolor2(color), columna,fila, ALLEGRO_ALIGN_LEFT,"Sensores");
    fila = 150;
    al_draw_text(font, makecolor2(color), columna+15,fila,  ALLEGRO_ALIGN_LEFT,"temp.");
    fila = fila + 10;
    al_draw_filled_rectangle( columna, fila,columna+10,fila+10,makecolor2(COLOR_VERDE));
    fila = 170;
    al_draw_text(font, makecolor2(color), columna+15,fila,  ALLEGRO_ALIGN_LEFT,"humo");
    fila = fila + 10;
    al_draw_filled_rectangle( columna, fila,columna+10,fila+10,makecolor2(COLOR_GRIS_CLARO));
    fila = 190;
    al_draw_text(font, makecolor2(color), columna+15,fila,  ALLEGRO_ALIGN_LEFT,"luz");
    fila = fila + 10;
    al_draw_filled_rectangle( columna, fila,columna+10,fila+10,makecolor2(COLOR_AMARILLO));

    //Info de actuadores
    fila = 300;
    al_draw_text(font,makecolor2(color), columna-4,fila, ALLEGRO_ALIGN_LEFT,"Actuadores");
    fila = 320;
    al_draw_text(font,makecolor2(color), columna-4,fila, ALLEGRO_ALIGN_LEFT,"switch");
    fila = 350;
    al_draw_text(font, makecolor2(color), columna+15,fila,  ALLEGRO_ALIGN_LEFT,"ON");
    fila = fila + 10;
    al_draw_filled_rectangle( columna, fila,columna+10,fila+10,makecolor2(COLOR_ROJO));
    fila = 370;
    al_draw_text(font, makecolor2(color), columna+15,fila,  ALLEGRO_ALIGN_LEFT,"OFF");
    fila = fila + 10;
    al_draw_filled_rectangle( columna, fila,columna+10,fila+10,makecolor2(COLOR_AZUL));

    //Info de escenarios a la derecha de la ventana
    fila = 100; columna = 705;
    al_draw_text(font,makecolor2(color), columna,fila, ALLEGRO_ALIGN_LEFT,"Escenario");

    al_flip_display();
    return true;
	}

	return false;
}

void entornoTerminar(){
	int i, j;
	for (i = 0, j = 0; i < 40 && j < 40; i += 10, j += 10)
		al_draw_rectangle(i + ORIGEN+100, j + ORIGEN + 200, ORIGEN + 500 - i, ORIGEN+ 320 -j, makecolor2(COLOR_BLANCO),2);

	al_draw_filled_rectangle(232 , 332,568, 388,  makecolor2(COLOR_NEGRO));
	al_draw_text(font, makecolor2(COLOR_ROJO),ORIGEN+170,ORIGEN+250, ALLEGRO_ALIGN_LEFT, "La simulación ha terminado");
	al_flip_display();
	al_rest(2);
	al_destroy_display          (display);
	al_destroy_event_queue      (colaEventos);
	al_destroy_font				(font);
	al_destroy_sample			(sample);
	al_shutdown_primitives_addon();
	al_shutdown_font_addon      ();
}


void entornoPonerSensor(int fila, int columna, TipoSensor sensor, float num, string nombre) {
	invertirFC(fila, columna);
	int colorFondo;

	switch (sensor) {
			case S_temperature:
				colorFondo = COLOR_VERDE;
				break;
			case S_smoke:
				colorFondo = COLOR_GRIS_CLARO;
				break;
			case S_light:
				colorFondo = COLOR_AMARILLO;
				break;
			default:
				colorFondo = COLOR_BLANCO;
				break;
		};

	al_draw_filled_circle( (ORIGEN + fila + 3)+ RADIO,
			(ORIGEN + columna + 3) + RADIO ,
			RADIO +2,
			makecolor2(colorFondo));

	al_draw_circle( (ORIGEN + fila  + 3)+ RADIO,
					(ORIGEN + columna + 3) + RADIO,
					RADIO +1,
					makecolor2(COLOR_GRIS),3);

	al_draw_text(font, makecolor2(COLOR_BLANCO), (ORIGEN + fila)-10 + RADIO, (ORIGEN + columna-40) + RADIO*0.7 , ALLEGRO_ALIGN_LEFT, nombre.c_str());
	if (num!=0)
		al_draw_text(font, makecolor2(COLOR_NEGRO), (ORIGEN + fila)- 20 + RADIO, (ORIGEN + columna) + RADIO*0.7 , ALLEGRO_ALIGN_LEFT, toString(num).c_str());

	al_flip_display();

}


void entornoPonerAct_Switch      (int fila, int columna, bool encendido, string alias){
	int color;
	string texto;
	invertirFC(fila, columna);
	if (encendido){
			color = COLOR_ROJO;
			texto="ON";
			}
	else {color = COLOR_AZUL;
			texto = "OFF";
			}
	al_draw_filled_rectangle( ORIGEN + fila  + 20,ORIGEN + columna  + 20,ORIGEN + fila   - 20,ORIGEN + columna - 20,makecolor2(color));
	al_draw_rectangle( ORIGEN + fila  + 20,ORIGEN + columna  + 20,ORIGEN + fila   - 20,ORIGEN + columna - 20,makecolor2(COLOR_GRIS),2);

	al_draw_text(font, makecolor2(COLOR_NEGRO) , (ORIGEN + fila  ), (ORIGEN + columna-10) , ALLEGRO_ALIGN_CENTER, texto.c_str());
	al_draw_text(font, makecolor2(COLOR_BLANCO), (ORIGEN + fila  ), (ORIGEN + columna-50 ) , ALLEGRO_ALIGN_CENTER, alias.c_str());

	al_flip_display();

}

void entornoAlarma(){
	  al_play_sample(sample, 2.0, 0.0,1.0,ALLEGRO_PLAYMODE_ONCE,NULL);

}

void entornoMostrarMensaje( string msg) {
	int col = 160;
	int fila = 520;

	al_draw_filled_rectangle(col-5 , fila+2,  695, 545,  makecolor2(COLOR_NEGRO));
	al_draw_text(font, makecolor2(COLOR_BLANCO),col,fila, ALLEGRO_ALIGN_LEFT, msg.c_str());
	al_flip_display();

}

void entornoBorrarMensaje() {
	int col = 160;
	int fila = 520;

	al_draw_filled_rectangle(col-5 , fila+2,  695,545,  makecolor2(COLOR_NEGRO));
	al_flip_display();

}


void entornoPonerEscenario(string nombre){
	 al_draw_filled_rectangle(702 , 152, 790, 1650,  makecolor2(COLOR_NEGRO));
	 al_draw_text(font,makecolor2(COLOR_BLANCO), 705,150, ALLEGRO_ALIGN_LEFT,nombre.c_str());
	 al_flip_display();

}

void entornoPulsarTecla() {

	al_draw_text(font, makecolor2(COLOR_BLANCO),250,560, ALLEGRO_ALIGN_LEFT, "Pulsa una tecla para continuar");
	al_flip_display();

	ALLEGRO_EVENT 		 evento;
	while (true){
		al_wait_for_event(colaEventos, &evento);
		if (evento.type == ALLEGRO_EVENT_KEY_DOWN) {
			break;
		}

	}

	al_draw_filled_rectangle(250 , 555,  700, 590,  makecolor2(COLOR_NEGRO));
	al_flip_display();
}

void entornoPausa(float pausa) {
	al_rest(pausa);
}

void entornoLinea (int x1, int y1, int x2, int y2){
	invertirFC(x1,y1);
	invertirFC(x2,y2);

	al_draw_line( ORIGEN + x1,ORIGEN + y1,ORIGEN + x2,ORIGEN + y2,	makecolor2(COLOR_ROJO),3);

	al_flip_display();
}


