%{
#include "expresiones.h"
#include <math.h>
int n_lineas;
%}
digito				[0-9]
caracter			[A-Za-z_]

%option noyywrap
 
%%
[Ss][aA][lL][iI][rR]			return SALIR;
{caracter}+({caracter}{digito})*	strcpy(yylval.c_cadena, yytext);return IDENTIFICADOR;
[0-9]+					yylval.c_entero = atoi(yytext);return NUMERO;
{digito}+[.]{digito}*([e][+-]?{digito}+)?	|
{digito}*[.]{digito}+([e][+-]?{digito}+)?	yylval.c_real = atof(yytext);return REAL;
\n					n_lineas++; return (yytext[0]);
[\t ]					;	
. 					return (yytext[0]);
%%
