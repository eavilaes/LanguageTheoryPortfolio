%{
#include "fallos.h"

int n_lineas;
%}
%option noyywrap
 
%%
if					return IF;
else					return ELSE;
while					return WHILE;
[a-zA-Z_][0-9a-zA-Z_]*			return IDENTIFICADOR;
[0-9]+					yylval=atoi(yytext);return NUMERO;
\n					n_lineas++; 
[ \t]					;
. 					return (yytext[0]);
%%
