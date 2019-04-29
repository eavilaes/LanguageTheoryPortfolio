%{

#include <iostream>
#include <cmath>

using namespace std;

bool real=false;
bool error=false;

extern int n_lineas;
extern int yylex();
extern FILE* yyin;

void yyerror(const char* s){         /*    llamada por cada error sintactico de yacc */
	cout << "Error sintáctico en la línea "<< n_lineas+1<<endl;
	real=false;
	error=false;
}

%}

%start entrada

%token SEPARADOR
%token <c_cadena> TIPO
%token <c_cadena> ID
%token <c_entero> ENTERO
%token <c_real> REAL
%token <c_bool> BOOL
%token <c_cadena> STRING
%token <c_cadena> SCENE
%token <c_cadena> START
%token <c_cadena> PAUSE

%left '+' '-'
%left '*' '/' '%'
%right '^'

%left menos

%union {
  int c_entero;
  float c_real;
  char c_cadena[50];
  char c_bool;
}

%type <c_real> expr

%%

entrada: parte1	SEPARADOR parte2 {}
	;
parte1:   declaracion ';'		{}
	| asignacion ';'		{}
	| sensor ';'			{}
	| declaracion ';' parte1	{}
	| asignacion ';' parte1		{}
	| sensor ';' parte1		{}
	| error ';' {yyerrok;} parte1
	;
/*En la declaración se incluyen también actuadores*/
declaracion: TIPO ID		{cout<<"declaración: "<<$2<<endl;}
	   | declaracion ',' ID	{cout<<"declaración recursiva: "<<$3<<endl;}
	   ;
asignacion:  ID '=' expr	{}
	   ;
expr:     ENTERO		{cout<<"numero entero: "<<$1<<endl;}
	| REAL			{cout<<"numero real: "<<$1<<endl;}
	| posicion		{}
	| BOOL			{cout<<"ON/OFF"<<endl;}
	| ID			{cout<<"variable ya existente: "<<$1<<endl;}
	| cadena		{cout<<endl;}
	| expr '+' expr 	{$$=$1+$3;}
	| expr '-' expr 	{$$=$1-$3;}
	| expr '*' expr 	{$$=$1*$3;}
	| expr '/' expr 	{if(real){$$=$1/$3;real=false;}else{$$=(int)$1/(int)$3;};}
	| expr '%' expr		{if(!real){$$=(int)$1%(int)$3;}else error=true;}
	| expr '^' expr		{$$=pow($1,$3);}
	|'-' expr %prec menos	{$$= -$2;}
	|'(' expr ')'		{$$=$2;}
	;
posicion: '<' expr ',' expr '>'	{cout<<"posicion"<<endl;}
	;
cadena:	  STRING		{cout<<"cadena de caracteres: \""<<$1<<"\"";}
	;
/*Las dos reglas de los sensores son válidas también para los actuadores, ya que se definen igual.*/
sensor:   TIPO ID posicion cadena	{cout<<endl<<$1<<" "<<$2<<" posicionTipo<,> "<<endl;}
	| TIPO ID ID cadena		{cout<<endl<<$1<<" "<<$2<<" posicionEnVariable "<<endl;}
	;
parte2:	  escena ';'		{}
	| escena ';' parte2	{}
	| error ';' {yyerrok;} parte2
	;
escena:	SCENE ID '[' bloque ']'	{cout<<"Escena: "<<$2<<endl;}
	;
bloque:   instr ';'		{}
	| instr ';' bloque	{}
	;
instr:	  START			{cout<<"Start"<<endl;}
	| PAUSE expr		{cout<<"Pausa"<<endl;}
	| ID expr		{cout<<"Sensor "<<$1<<" ha detectado algo"<<endl;}
	;
%%

int main(int argc, char *argv[]){
	printf("\n");
	if(argc==3){
		yyin = fopen(argv[1],"rt");
		n_lineas=0;
		yyparse();
	}else
		printf("Error en la llamada. Ejemplo: %s ficheroEntrada ficheroSalida\n", argv[0]);
	return 0;
}
