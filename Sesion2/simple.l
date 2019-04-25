%{
/*
Este programa elimina de un fichero de texto lineas en blanco,
espacios en blanco al principio o al final de las lineas y
compacta los espacios entre palabras reduciéndolos a uno
*/

#include <iostream>
using namespace std;
%}

%option noyywrap

%%

[\t ]+$         ;    /*esta regla elimina tabuladores y espacios al final de la linea*/

[ ]+            cout<<" ";       /*esta regla compacta los espacios*/

^[\n\t]         ;           /*esta regla elimina los tabuladores al comienzo de linea y las lineas en blanco*/

.               ECHO;       /*almacena en la salida cualquier caracter menos el fin de linea*/

\n              ECHO;       /* almacena en la salida el caracter de fin de linea */

%%

int main(){
	yylex();
	return 0;
}
