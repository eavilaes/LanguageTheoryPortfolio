

%{

#include <stdio.h>
#include <iostream>
#include <string.h>
using namespace std;

typedef char TCadena[20];
extern int n_lineas;
extern int yylex();
extern FILE* yyin;

void yyerror(const TCadena s )             /* llamada por cada error sintactico de yacc */
{
	cout << "error en la linea "<< n_lineas<<endl;
}


%}
%start lista_instrucciones
%token NUMERO SALIR IDENTIFICADOR
%token IF ELSE WHILE



%%
lista_instrucciones: 	instruccion 
			|lista_instrucciones  instruccion 
			;

instruccion: 	  asignacion ';'		{cout <<"A una variable se le ha asignado el valor "<< $1<<endl; }
      		| alternativa 
		| bucle	
		| error ';' 			{yyerrok;}	
		;

asignacion : 	 IDENTIFICADOR '='  expr 	 	{$$ = $3;}
		|IDENTIFICADOR '=' expr_logica 	 	{$$ = $3;}
		;
alternativa: 	  IF expr_logica bloque			{cout <<  "Hemos encontrado un IF simple"<< endl;}
		| IF expr_logica bloque ELSE bloque	{cout <<  "Hemos encontrado un IF con ELSE"<< endl;}
		;

bucle: WHILE expr_logica bloque  {cout <<  "Hemos encontrado un bucle"<< endl;}
	;

bloque: '{' lista_instrucciones '}'
	|instruccion 
	;

expr: 	IDENTIFICADOR			{ $$ = 0; }
   	| NUMERO                       	{ $$ = $1; }
        | expr '+' expr                	{ $$ = $1 + $3; }       	
       	| expr '*' expr                	{ $$ = $1 * $3; }     
       ;

expr_logica :	IDENTIFICADOR		{ $$ = false; }
	 	|expr '<' expr		{$$= $1 < $3;}
		|expr '>' expr		{$$= $1 > $3;}
		;
%%






int main( int argc, char *argv[] ){     
	if (argc != 2) 
		cout <<"error en los argumentos"<<endl;
	else {
     		yyin=fopen(argv[1],"rt");
     		n_lineas = 0;
       		yyparse();
         	return 0;
	}
}







