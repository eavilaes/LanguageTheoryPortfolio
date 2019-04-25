%{
#include "expresiones.h"
#include "tabla.h"
#include <math.h>
int n_lineas;
%}
digito				[0-9]
caracter			[A-Za-z_]

%option noyywrap

%x COM

%%
"//"						BEGIN(COM);
<COM>"\n"					BEGIN(0);
<COM>.						;

true						yylval.c_bool = 1;return BOOL; 
false						yylval.c_bool = 0;return BOOL;
{caracter}+({caracter}{digito})*		strcpy(yylval.c_cadena, yytext);return IDENTIFICADOR;
[<][=]						return LE;
[>][=]						return GE;
[=][=]						return EQ;
[!][=]						return NE;
[&][&]						return AND;
[|][|]						return OR;
[!]						return NOT;
[0-9]+						yylval.c_entero = atoi(yytext);return ENTERO;
{digito}+[.]{digito}*([e][+-]?{digito}+)?	|
{digito}*[.]{digito}+([e][+-]?{digito}+)?	yylval.c_real = atof(yytext);return REAL;
\n						n_lineas++; return (yytext[0]);
[\t ]						;
. 						return (yytext[0]);
%%
