%{

#include <iostream>
#include <fstream>
#include <cmath>
#include "tabla.h"
#include "tablaSens.h"
#include <string.h>

using namespace std;

bool real=false;
bool error=false;
Tabla *tablaVar = (Tabla*)malloc(sizeof(Tabla));
TablaSens *tablaSens = (TablaSens*)malloc(sizeof(TablaSens));
tipo_datoTS *datoVar = (tipo_datoTS*)malloc(sizeof(tipo_datoTS));
tipo_datoTSens *datoSens = (tipo_datoTSens*)malloc(sizeof(tipo_datoTSens));
union tipo_valor valor;

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

%token SEPARADOR /* separa la primera y la segunda parte del fichero de entrada */
%token <c_cadena> TIPO	/* yylval.c_cadena incluye el tipo */
%token <c_cadena> ID
%token <c_entero> ENTERO
%token <c_real> REAL
%token <c_bool> BOOL
%token <c_cadena> STRING /* contenido de un string, sin las comillas */
%token SCENE
%token <c_cadena> START
%token <c_cadena> PAUSE
%token <c_bool> IF
%token <c_cadena> THEN
%token <c_entero> REPEAT
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
declaracion: TIPO ID		{cout<<"*************"<<yylval.c_cadena<<endl;if(strcmp(yylval.c_cadena,"temperature")==0)
								datoSens->tipo=4;
							else if(strcmp(yylval.c_cadena,"smoke")==0)
								datoSens->tipo=5;
							else if(strcmp(yylval.c_cadena,"light")==0)
								datoSens->tipo=6;
							else datoSens->tipo=-1;
							strcpy(datoSens->nombre,$2);
							datoSens->inicializado=true; //TODO
							tablaSens->insertar(datoSens);
							}
	   | declaracion ',' ID	{cout<<yylval.c_cadena;if(strcmp(yylval.c_cadena,"temperature")==0)
								datoSens->tipo=4;
							else if(strcmp(yylval.c_cadena,"smoke")==0)
								datoSens->tipo=5;
							else if(strcmp(yylval.c_cadena,"light")==0)
								datoSens->tipo=6;
							else datoSens->tipo=-1;
							strcpy(datoSens->nombre,$3);
							datoSens->inicializado=true; //TODO
							tablaSens->insertar(datoSens);
							}
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
		//Correspondencias con tipos de variables
		const int TIPO_INT = 0;
		const int TIPO_FLOAT = 1;
		const int TIPO_POSITION = 2;
		const int TIPO_STRING = 3;
		const int TIPO_TEMPERATURE = 4;
		const int TIPO_SMOKE = 5;
		const int TIPO_LIGHT = 6;
		const int TIPO_ALARM = 7;
		const int TIPO_SWITCH = 8;
		const int TIPO_MESSAGE = 9;


		yyin = fopen(argv[1],"rt");
		ofstream sal (argv[2], std::ofstream::trunc);
		n_lineas=0;
		extern Tabla *tablaVar;
		extern TablaSens *tablaSens;

		yyparse();

		//Cabecera del fichero de salida
		sal << "//============================================================================\n";
		sal << "//Name		: " << argv[2] << "\n";
		sal << "//Author	: Eric Ávila" << "\n";
		sal << "//Version	: \n";
		sal << "//Copyright	: Your copyright notice\n";
		sal << "//Description	: Este proyecto ayuda a conocer el entorno gráfico del proyecto DSLP. Se incluyen diferentes ficheros de configuración para hacer pruebas con facilidad\n";
		sal << "//============================================================================\n\n";
		sal << "#include <iostream>\n#include \"entorno_dspl.h\"\n\nusing namespace std;\n\n";

		//Cuerpo del fichero de salida

		//Inicio
		sal << "void inicio(){\n";
		sens *aux = tablaSens->getPrimero();
		while(aux!=NULL){
			if(aux->elem.inicializado==true){
				sal << "entornoPonerSensor(" << aux->elem.posY << "," << aux->elem.posX << ",";
				if(aux->elem.tipo==TIPO_TEMPERATURE) sal<<"S_temperature,";
				else if(aux->elem.tipo==TIPO_SMOKE) sal<<"S_smoke,";
				else if(aux->elem.tipo==TIPO_LIGHT) sal<<"S_light,";
				sal << "0," << aux->elem.alias << ");\n"; //TODO cambiar el 0 por el numero que sea
			}
			sal<<aux->elem.tipo<<"\n";
			aux=aux->sig;
		}
		sal <<"}\n\n";
		fclose(yyin);
	}else
		printf("Error en la llamada. Ejemplo: %s ficheroEntrada ficheroSalida\n", argv[0]);
	return 0;
}
