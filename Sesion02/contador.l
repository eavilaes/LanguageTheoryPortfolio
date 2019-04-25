%{
/*
 *      Este programa cuenta el número de caracteres, palabras y líneas
 *      que hay en un texto
 */

#include <iostream>
using namespace std;

int n_caracteres, n_palabras,  n_lineas, n_enteros, n_reales, n_eric, n_reservadas, n_identificadores, n_cadenas, n_lineasblancas;      /* variables globales: contadores */
%}

%option noyywrap

%%

^\n			n_lineasblancas++; //Líneas en blanco

\n               	 n_lineas++;    //la primera regla detecta el fin de una línea e incrementa el contador de las líneas

[0-9]+[.][0-9]*		 	{n_reales++;n_caracteres+=yyleng;}
[0-9]*[.][0-9]+		 	{n_reales++;n_caracteres+=yyleng;}
[0-9]*[.][0-9]+[e][+][1-9]+	{n_reales++;n_caracteres+=yyleng;}
[0-9]+[.][0-9]*[e][+][1-9]+	{n_reales++;n_caracteres+=yyleng;}

[0-9]+			 {n_enteros++;REJECT} //numero de enteros en el fichero

[eE][rR][iI][cC]	 {n_eric++; //numero de veces que aparece mi nombre en el fichero
			  n_caracteres = n_caracteres + yyleng;}

main			 {n_reservadas++;REJECT} //Palabras reservadas
int			 {n_reservadas++;REJECT}
float			 {n_reservadas++;REJECT}
for			 {n_reservadas++;REJECT}
cout			 {n_reservadas++;REJECT}
endl			 {n_reservadas++;REJECT}

["][^"]*["]			n_cadenas++;

[A-Za-z_]+[A-Za-z0-9_]*	 {n_identificadores++;REJECT} //Identificadores

[A-Za-z0-9Ññ]+       	 {n_palabras++;  //la segunda regla detecta una palabra e incrementa 
			  n_caracteres = n_caracteres + yyleng;}     //los contadores de palabras y caracteres

.		cout<<"";	//No imprime basura

%%
int main(){
	n_caracteres = 0;   //inicialización de los contadores
	n_palabras = 0;
	n_lineas = 0;
	n_enteros = 0;
	n_reales = 0;
	n_eric = 0;
	n_reservadas = 0;
	n_identificadores = 0;
	n_cadenas = 0;
	n_lineasblancas = 0;
  	
	yylex();    //llamada al analizador léxico
  	
	cout <<endl<<"Número de caracteres= "<< n_caracteres<<endl;    //se muestra el valor de los contadores tras el proceso
  	cout <<"Número de palabras= "<< n_palabras<<endl;
  	cout <<"Número de líneas= "<< n_lineas<<endl;
	cout <<"Número de enteros= "<< n_enteros<<endl;
	cout <<"Número de reales= "<< n_reales<<endl;
	cout <<"Número de \"Eric\"= "<< n_eric<<endl;
	cout <<"Número de reservadas= "<< n_reservadas<<endl;
	cout <<"Número de identificadores= "<< n_identificadores<<endl;
	cout <<"Número de cadenas= "<< n_cadenas<<endl;
	cout <<"Número de lineas blancas= "<< n_lineasblancas<<endl;
  	
  	return 0;  
}
