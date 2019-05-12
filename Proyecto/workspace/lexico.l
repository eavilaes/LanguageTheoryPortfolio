%{
#include "expresiones.h"

int n_lineas;
%}

digito				[0-9]
caracter			[A-Za-z_]

%option noyywrap

%x COM STR

%%
"#"						BEGIN(COM);
<COM>\n						n_lineas++;BEGIN(0);
<COM>.						;
"\""						BEGIN(STR);
<STR>"\""					BEGIN(0);
<STR>[^"]*					strcpy(yylval.c_cadena,yytext);return STRING;

int						|
float						|
position					|
string						|
alarm						|
switch						|
message						strcpy(yylval.c_cadena,yytext);return TIPO;
temperature					return TEMPERATURE;
smoke						return SMOKE;
light						return LIGHT;

[%][%]						return SEPARADOR;
scene						return SCENE;
start						return START;
pause						return PAUSE;
ON						yylval.c_bool = 1;return BOOL;
OFF						yylval.c_bool = 0;return BOOL;
true						yylval.c_bool = 1;return BOOL; 
false						yylval.c_bool = 0;return BOOL;
if						return IF;
then						return THEN;
repeat						return REPEAT;


[<][=]						return LE;
[>][=]						return GE;
[=][=]						return EQ;
[!][=]						return NE;
[&][&]						return AND;
[|][|]						return OR;
[!]						return NOT;

{caracter}+({caracter}{digito})*		strcpy(yylval.c_cadena, yytext);return ID;
[0-9]+						yylval.c_entero = atoi(yytext);return ENTERO;
{digito}+[.]{digito}*([e][+-]?{digito}+)?	|
{digito}*[.]{digito}+([e][+-]?{digito}+)?	yylval.c_real = atof(yytext);return REAL;
\n						n_lineas++;
[\t ]						;
.						return (yytext[0]);
%%
