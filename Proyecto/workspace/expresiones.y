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

%start entrada /* regla de comienzo del lenguaje */

//TODO revisar los tipos
%token SEPARADOR /* separa la primera y la segunda parte del fichero de entrada */
%token <c_cadena> TIPO	/* yylval.c_cadena incluye el tipo de la variable */
%token <c_cadena> ID
%token <c_entero> ENTERO
%token <c_real> REAL
%token <c_bool> BOOL
%token <c_cadena> STRING /* contenido de un string, sin las comillas */
%token <c_cadena> SCENE
%token <c_cadena> START
%token <c_cadena> PAUSE
%token <c_cadena> IF
%token <c_cadena> THEN
%token <c_cadena> REPEAT
%token LE GE EQ NE	/* comparadores */
%token AND OR NOT	/* operadores lógicos */

%left OR		/* asociatividad con menor prioridad */
%left AND
%right NOT
%left '<' LE '>' GE EQ NE
%left '+' '-'		
%left '*' '/' '%'
%right '^'
%left menos		/* asociatividad con mayor prioridad */

%union {	/* redefinición de YYSTYPE */
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
	| sensor_actuador ';'		{}
	| declaracion ';' parte1	{}
	| asignacion ';' parte1		{}
	| sensor_actuador ';' parte1	{}
	| error ';' {yyerrok;} parte1
	;
/*En la declaración se incluyen variables, sensores y actuadores*/
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
sensor_actuador:   TIPO ID posicion cadena	{cout<<endl<<$1<<" "<<$2<<" posicionTipo<,> "<<endl;}
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
instr:	  START					{cout<<"Start"<<endl;}
	| PAUSE expr				{cout<<"Pausa de tiempo"<<endl;}
	| PAUSE					{cout<<"Pausa con tecla"<<endl;}
	| ID expr				{cout<<"Sensor/activador "<<$1<<" ha detectado algo/activado o apagado"<<endl;}
	| ID expr STRING			{cout<<"Activador de mensaje"<<endl;}
	| ID expr ID				{cout<<"Activador de mensaje en variable"<<endl;}
	| IF comp THEN '[' bloque ']'		{cout<<"Bloque IF"<<endl;}
	| REPEAT expr '[' bloque ']'		{cout<<"Bloque REPEAT"<<endl;}
	;
comp:	  expr '<' expr	{cout<<"Menor que"<<endl;}
	| expr LE expr	{cout<<"Menor o igual que"<<endl;}
	| expr '>' expr	{cout<<"Mayor que"<<endl;}
	| expr GE expr	{cout<<"Mayor o igual que"<<endl;}
	| expr EQ expr	{cout<<"Igual que"<<endl;}
	| expr NE expr	{cout<<"Distinto que"<<endl;}
	| comp AND comp	{cout<<"Comparaciones múltiples con AND"<<endl;}
	| comp OR comp	{cout<<"Comparaciones múltiples con OR"<<endl;}
	| NOT comp	{cout<<"Comparaciones con un NOT delante"<<endl;}
	| '(' comp ')'	{cout<<"Paréntesis"<<endl;}
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
