%{

#include <iostream>
#include <fstream>
#include <cmath>
#include "tabla.h"
#include "tablaSens.h"
#include <string.h>

using namespace std;

bool entero=false, real=false;
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
%token INT FLOAT POSITION STRING ALARM MESSAGE TEMPERATURE SMOKE LIGHT SWITCH
%token <c_cadena> ID
%token <c_entero> ENTERO
%token <c_real> REAL
%token <c_bool> BOOL
%token <c_cadena> CADENA /* contenido de un string, sin las comillas */
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
	| sensor ';'		{}
	| actuador ';'		{}
	| declaracion ';' parte1	{}
	| asignacion ';' parte1		{}
	| sensor ';' parte1	{}
	| actuador ';' parte1 {}
	| error ';' {yyerrok;} parte1
	;
/*En la declaración se incluyen variables, sensores y actuadores*/
declaracion: INT ID		{strcpy(datoVar->nombre,$2);datoVar->tipo=0;datoVar->inicializado=false;tablaVar->insertar(datoVar);}//TODO verificar datoVar->tipo
	   | FLOAT ID		{strcpy(datoVar->nombre,$2);datoVar->tipo=1;datoVar->inicializado=false;tablaVar->insertar(datoVar);}
	   | STRING ID		{strcpy(datoVar->nombre,$2);datoVar->tipo=3;datoVar->inicializado=false;tablaVar->insertar(datoVar);cout<<"string\n";}
	   | declaracion ',' ID	{strcpy(datoVar->nombre,$3);datoVar->inicializado=false;tablaVar->insertar(datoVar);}//TODO(2)
	   ;
asignacion:  ID '=' expr	{tablaVar->buscar($1,datoVar);if(strcmp(datoVar->nombre,$1)==0){
					if(entero) datoVar->valor.valor_entero=$3;
					else if(real) datoVar->valor.valor_real=$3;
					else datoVar->valor.valor_bool=$3;
					datoVar->inicializado=true;tablaVar->insertar(datoVar);
				}entero=false;real=false;}
	   ;
expr:     ENTERO		{$$=$1;entero=true;datoVar->tipo=0;}
	| REAL			{$$=$1;real=true;datoVar->tipo=1;}
	| posicion		{}
	| BOOL			{$$=yylval.c_bool;}
	| ID			{if(tablaVar->buscar($1,datoVar)){
						if(datoVar->tipo==0){ $$=datoVar->valor.valor_entero; entero=true;}
						else if(datoVar->tipo==1){ $$=datoVar->valor.valor_real; real=true;}
						else cout<<"Error semántico en la línea " << ++n_lineas << ". La variable " << $1 << " no ha sido definida" << endl;
					}}
	| cadena		{}
	| expr '+' expr 	{$$=$1+$3;}
	| expr '-' expr 	{$$=$1-$3;}
	| expr '*' expr 	{$$=$1*$3;}
	| expr '/' expr 	{if(real){$$=$1/$3;real=false;}else{$$=(int)$1/(int)$3;};}
	| expr '%' expr		{if(!real){$$=(int)$1%(int)$3;}else error=true;}
	| expr '^' expr		{$$=pow($1,$3);}
	|'-' expr %prec menos	{$$= -$2;}
	|'(' expr ')'		{$$=$2;}
	;
posicion: '<' expr ',' expr '>'	{datoSens->posY=$2;datoSens->posX=$4;}
	;
cadena:	  CADENA		{strcpy(datoSens->alias,$1);}
	;

sensor:   TEMPERATURE ID posicion cadena {datoSens->tipo=4; strcpy(datoSens->nombre,$2); datoSens->inicializado=true; tablaSens->insertar(datoSens);}
	| SMOKE ID posicion cadena	{datoSens->tipo=5; strcpy(datoSens->nombre,$2); datoSens->inicializado=true; tablaSens->insertar(datoSens);}
	| LIGHT ID posicion cadena	{datoSens->tipo=6; strcpy(datoSens->nombre,$2); datoSens->inicializado=true; tablaSens->insertar(datoSens);}
	| TEMPERATURE ID ID cadena	{datoSens->tipo=4; strcpy(datoSens->nombre,$2); datoSens->inicializado=true; tablaSens->insertar(datoSens);}
	| SMOKE ID ID cadena		{datoSens->tipo=5; strcpy(datoSens->nombre,$2); datoSens->inicializado=true; tablaSens->insertar(datoSens);}
	| LIGHT ID ID cadena		{datoSens->tipo=6; strcpy(datoSens->nombre,$2); datoSens->inicializado=true; tablaSens->insertar(datoSens);}
	;
actuador: SWITCH ID posicion cadena {datoSens->tipo=8; strcpy(datoSens->nombre,$2); datoSens->inicializado=true;tablaSens->insertar(datoSens);}
	| SWITCH ID ID cadena

	;
parte2:	  escena ';'		{}
	| escena ';' parte2	{}
	| error ';' {yyerrok;} parte2
	;
escena:	SCENE ID '[' bloque ']'	{}
	;
bloque:   instr ';'		{}
	| instr ';' bloque	{}
	;
instr:	  START					{}
	| PAUSE expr				{}
	| PAUSE					{}
	| ID expr				{}
	| ID expr CADENA			{}
	| ID expr ID				{}
	| IF comp THEN '[' bloque ']'		{}
	| REPEAT expr '[' bloque ']'		{}
	;
comp:	  expr '<' expr	{}
	| expr LE expr	{}
	| expr '>' expr	{}
	| expr GE expr	{}
	| expr EQ expr	{}
	| expr NE expr	{}
	| comp AND comp	{}
	| comp OR comp	{}
	| NOT comp	{}
	| '(' comp ')'	{}
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
		fclose(yyin);
		//Cabecera del fichero de salida
		sal << "//============================================================================\n";
		sal << "// Name		: " << argv[2] << "\n";
		sal << "// Author	: Eric Ávila" << "\n";
		sal << "// Version	: \n";
		sal << "// Copyright	: Your copyright notice\n";
		sal << "// Description	: Este proyecto ayuda a conocer el entorno gráfico del proyecto DSLP. Se incluyen diferentes ficheros de configuración para hacer pruebas con facilidad\n";
		sal << "//============================================================================\n\n";
		sal << "#include <iostream>\n#include \"entorno_dspl.h\"\n\nusing namespace std;\n\n";

		//Cuerpo del fichero de salida
		sal << "/* Este procedimiento permite representar los dispositivos\n * en una situación inicial, es decir, los actuadores de tipo switch apagados\n * y los sensores sin ningún valor captado*/\n";

		//Inicio
		sal << "void inicio(){\n";
		sens *aux = tablaSens->getPrimero();
		while(aux!=NULL){
			if(aux->elem.inicializado==true && aux->elem.tipo==TIPO_TEMPERATURE || aux->elem.tipo==TIPO_SMOKE ||aux->elem.tipo==TIPO_LIGHT){
				sal << "	entornoPonerSensor(" << aux->elem.posY << "," << aux->elem.posX << ",";
				if(aux->elem.tipo==TIPO_TEMPERATURE) sal<<"S_temperature,";
				else if(aux->elem.tipo==TIPO_SMOKE) sal<<"S_smoke,";
				else if(aux->elem.tipo==TIPO_LIGHT) sal<<"S_light,";
				sal << "0,\"" << aux->elem.alias << "\");\n"; //TODO cambiar el 0 por el numero que sea
			}else if(aux->elem.inicializado==true && aux->elem.tipo==TIPO_SWITCH){
				sal << "	entornoPonerAct_Switch(" << aux->elem.posY << "," << aux->elem.posX << ",false," << "\"" << aux->elem.alias << "\");\n";
			}
			aux=aux->sig;
		}
		sal << "	entornoBorrarMensaje();\n";
		sal <<"}\n\n";

		//Main
		sal << "int main(){\n";
		sal << "	if(entornoIniciar()){\n";

		sal << "}";


		//******Zona de debug******
		bool debug=true;
		if(debug){
		ofstream tabla ("tablaSimbolos.txt", std::ofstream::trunc);
		nodo *n = tablaVar->getPrimero();
		tabla << "******************************************" << endl;
		tabla << "**  TIPO	NOMBRE		VALOR	**" << endl;
		tabla << "******************************************" << endl;
		while(n!=NULL){
			if(n->elem.tipo==0){
			tabla << "**  entero	"; tabla<< n->elem.nombre; tabla << "		"; tabla<<n->elem.valor.valor_entero; tabla<<"	**\n";
			}else if(n->elem.tipo==1){
			tabla << "**  real	"; tabla<< n->elem.nombre; tabla << "	"; tabla<<n->elem.valor.valor_real; tabla<<"	**\n";
			}else if(n->elem.tipo==2){
				if(n->elem.valor.valor_bool==false){
			tabla << "**  lógico	"; tabla<< n->elem.nombre; tabla << "		false	**\n";
				}else{
			tabla << "**  lógico	"; tabla<< n->elem.nombre; tabla << "		true	**\n";
			}
			}else if(n->elem.tipo==3){
			tabla << "**  string	"; tabla<< n->elem.nombre; tabla << "			**\n";
			}
			n=n->sig;
		}
			tabla << "******************************************" << endl;
		tabla << "\n\nSensores sin inicializar\n******************************************" << endl;
		aux = tablaSens->getPrimero();
		while(aux!=NULL){
			if(aux->elem.inicializado=false)
				tabla << aux->elem.nombre << "\n";
			aux=aux->sig;
		}
		tabla << "\n\nSensores \n******************************************" << endl;
		aux = tablaSens->getPrimero();
		while(aux!=NULL){
			if(aux->elem.inicializado=true)
				tabla << aux->elem.tipo << "	" << aux->elem.nombre  << "\n";
			aux=aux->sig;
		}
		}//debug


	}else
		printf("Error en la llamada. Ejemplo: %s ficheroEntrada ficheroSalida\n", argv[0]);
	return 0;
}
