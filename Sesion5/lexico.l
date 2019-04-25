%{
#include "expresiones.h"
#include <math.h>
int n_lineas;
%}
digito				[0-9]
caracter			[A-Za-z_]

%option noyywrap
 
%%
SALIR					|
[Ss][aA][lL][iI][rR]			return SALIR;
{caracter}+({caracter}{digito})*	return ASIGNACION;
[0-9]+					yylval = atoi(yytext);return NUMERO;
\n					n_lineas++; return (yytext[0]);
[\t ]					;	
. 					return (yytext[0]);
%%
