%{

#include <iostream>
#include <fstream>
#include <cmath>
#include "tabla.h"
#include <string.h>

using namespace std;

bool real=false;
bool error=false;
bool cmp=false;
bool nodef=false;

Tabla* tabla = (Tabla*)malloc(sizeof(Tabla));
tipo_datoTS *dato = (tipo_datoTS*)malloc(sizeof(tipo_datoTS*));
union tipo_valor valor;

//elementos externos al analizador sintácticos por haber sido declarados en el analizador léxico y en la función main
extern int n_lineas;
extern int yylex();
extern FILE* yyin;

//definición de procedimientos auxiliares
void yyerror(const char* s){         /*    llamada por cada error sintactico de yacc */
	cout << "Error sintáctico en la línea "<< n_lineas+1<<endl;
	real=false;
	error=false;
} 

%}

%start entrada

%token <c_entero> ENTERO
%token <c_cadena> IDENTIFICADOR
%token <c_real> REAL
%token <c_bool> BOOL
%token LE GE EQ NE	/* comparadores */
%token AND OR NOT	/* operadores lógicos */

%left OR	/* asociativo por la izquierda, prioridad más baja */
%left AND
%right NOT
%left '<' LE '>' GE EQ NE
%left '+' '-'
%left '*' '/' '%'
%right '^'	/* asociativo por la derecha, prioridad más alta */
 
%left menos

%union{		/* Redefine YYSTYPE */
  int c_entero;
  float c_real;
  char c_cadena[20];
  char c_bool;
}

%type <c_real> expr
%type <c_bool> comp

%%
entrada: 		{}
      |entrada linea
      ;
linea:   asignacion '\n'	{real=false; error=false;}
	|error '\n'		{yyerrok;}
	;
expr:    ENTERO 		{$$=$1;}
       | REAL			{real=true;$$=$1;}
       | BOOL			{cmp=true;$$=$1;}
       | IDENTIFICADOR		{if(tabla->buscar($1,dato)){if(dato->tipo==0) $$=dato->valor.valor_entero;else{ $$=dato->valor.valor_real;real=true;}}else{ cout<<"Error semántico en la línea "<<++n_lineas<<", la variable "<<$1<<" no ha sido definida."<<endl;nodef=true;}}
       | expr AND expr		{if($1==$3)$$=1;else $$=0;}
       | expr OR expr		{if($1==1||$3==1)$$=1;else $$=0;}
       | NOT expr		{$$=!$2;}
       | comp			{$$=$1;}
       | expr '+' expr 		{$$=$1+$3;}
       | expr '-' expr    	{$$=$1-$3;}
       | expr '*' expr          {$$=$1*$3;}
       | expr '/' expr          {if(real){$$=$1/$3;real=false;}else{$$=(int)$1/(int)$3;};}
       | expr '%' expr		{if(!real){$$=(int)$1%(int)$3;}else error=true;}
       | expr '^' expr		{$$=pow($1,$3);}
       |'-' expr %prec menos    {$$= -$2;}
       |'(' expr ')'		{$$=$2;}
       ;
comp:    expr '<' expr		{cmp=true;if($1<$3) $$=true;else $$=false;}
       | expr LE expr		{cmp=true;if($1<$3||$1==$3) $$=true;else $$=false;}
       | expr '>' expr		{cmp=true;if($1>$3) $$=true;else $$=false;}
       | expr GE expr		{cmp=true;if($1>$3||$1==$3) $$=true;else $$=false;}
       | expr EQ expr		{cmp=true;if($1==$3) $$=true;else $$=false;}
       | expr NE expr		{cmp=true;if($1!=$3) $$=true;else $$=false;}
       ;
asignacion:	IDENTIFICADOR '=' expr	{if(!error && !nodef){if(cmp){strcpy(dato->nombre,$1);dato->tipo=2;valor.valor_bool=$3;dato->valor=valor;tabla->insertar(dato);}else if(real){strcpy(dato->nombre,$1);dato->tipo=1;valor.valor_real=$3;dato->valor=valor;tabla->insertar(dato);real=false;}else{strcpy(dato->nombre,$1);dato->tipo=0;valor.valor_entero=$3;dato->valor=valor;tabla->insertar(dato);}}else if(!nodef){cout << "Error semántico en la línea " << n_lineas+1 << ": El operador % no se puede usar con datos de tipo real " << endl;};cmp=false;real=false;nodef=false;error=false;}
	;
%%

int main(int argc, char *argv[]){

	printf("\n");

	if(argc==3){
		yyin = fopen(argv[1],"rt");
		//ifstream ent (argv[1], std::ifstream::in);
		ofstream sal (argv[2], std::ofstream::trunc);

		n_lineas = 0;
		extern Tabla *tabla;

		yyparse();

			sal << "******************************************" << endl;
			sal << "**  TIPO	NOMBRE		VALOR	**" << endl;
			sal << "******************************************" << endl;
		nodo *aux = tabla->getPrimero();
		while(aux!=NULL){
			if(aux->elem.tipo==0){
			sal << "**  entero	"; sal<< aux->elem.nombre; sal << "		"; sal<<aux->elem.valor.valor_entero; sal<<"	**\n";
			}else if(aux->elem.tipo==1){
			sal << "**  real	"; sal<< aux->elem.nombre; sal << "		"; sal<<aux->elem.valor.valor_real; sal<<"	**\n";
			}else if(aux->elem.tipo==2){
				if(aux->elem.valor.valor_bool==false){
			sal << "**  lógico	"; sal<< aux->elem.nombre; sal << "		false	**\n";
				}else{
			sal << "**  lógico	"; sal<< aux->elem.nombre; sal << "		true	**\n";
			}
			}
			aux=aux->sig;
		}
			sal << "******************************************" << endl;

	}else 
		printf("Error en la llamada. Ejemplo: %s ficheroEntrada ficheroSalida\n", argv[0]);
     return 0;
}
