%{

#include <iostream>
#include <fstream>
#include <cmath>
#include "tabla.h"
#include "tablaSens.h"
#include "tablaInst.h"
#include <string.h>

using namespace std;

bool entero=false, real=false, cad=false;
bool error=false, errSem=false, ifblock=false, cmp=false;
int bucle=0, indice=0;
int reps [20];
char cade [50];
Tabla *tablaVar = (Tabla*)malloc(sizeof(Tabla));
TablaSens *tablaSens = (TablaSens*)malloc(sizeof(TablaSens));
TablaInst *tablaInst = (TablaInst*)malloc(sizeof(TablaInst));
tipo_datoTS *datoVar = (tipo_datoTS*)malloc(sizeof(tipo_datoTS));
tipo_datoTSens *datoSens = (tipo_datoTSens*)malloc(sizeof(tipo_datoTSens));
tipo_datoTInst *datoInst = (tipo_datoTInst*)malloc(sizeof(tipo_datoTInst));
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
%token <c_entero> 	REPEAT
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
%type <c_bool> comp

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
declaracion: INT ID		{strcpy(datoVar->nombre,$2);datoVar->tipo=0;datoVar->inicializado=false;tablaVar->insertar(datoVar);}
	   | FLOAT ID		{strcpy(datoVar->nombre,$2);datoVar->tipo=1;datoVar->inicializado=false;tablaVar->insertar(datoVar);}
	   | STRING ID		{strcpy(datoVar->nombre,$2);datoVar->tipo=3;datoVar->inicializado=false;tablaVar->insertar(datoVar);}
	   | declaracion ',' ID	{strcpy(datoVar->nombre,$3);datoVar->inicializado=false;tablaVar->insertar(datoVar);}
	   | POSITION ID	{}//No se hace nada, porque se hace en la regla "posicion", pero se pone para evitar error sintáctico
	   | ALARM ID		{strcpy(datoSens->nombre, $2);datoSens->tipo=7;datoSens->inicializado=false;tablaSens->insertar(datoSens);}
	   | MESSAGE ID		{strcpy(datoSens->nombre, $2);datoSens->tipo=9;datoSens->inicializado=false;tablaSens->insertar(datoSens);}
	   ;
asignacion:  ID '=' expr	{tablaVar->buscar($1,datoVar);if(strcmp(datoVar->nombre,$1)==0){
					if(entero) datoVar->valor.valor_entero=$3;
					else if(real) datoVar->valor.valor_real=$3;
					else if(cad) strcpy(datoVar->texto, yylval.c_cadena);
					else datoVar->valor.valor_bool=$3;
					datoVar->inicializado=true;tablaVar->insertar(datoVar);
				}entero=false;real=false;cad=false;}
	   ;
expr:     ENTERO		{$$=$1;entero=true;datoVar->tipo=0;}
	| REAL			{$$=$1;real=true;datoVar->tipo=1;}
	| posicion		{}
	| BOOL			{$$=yylval.c_bool;}
	| ID			{if(tablaVar->buscar($1,datoVar)){
						if(datoVar->tipo==0){ $$=datoVar->valor.valor_entero; entero=true;}
						else if(datoVar->tipo==1){ $$=datoVar->valor.valor_real; real=true;}
						else{errSem=true; cout<<"Error semántico en la línea " << ++n_lineas << ". La variable " << $1 << " no ha sido definida o no es un tipo compatible con esa operación." << endl;}
					}else if(tablaSens->buscar($1, datoSens)){
						$$=datoSens->valor;
					}}
	| cadena		{cad=true; strcpy(cade, yylval.c_cadena);}
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
escena:	SCENE ID {datoInst->tipo=5;strcpy(datoInst->valor.valor_cadena, $2);tablaInst->insertar(datoInst);} '[' bloque ']'	
	;
bloque:   instr ';'		{ifblock=false;if(bucle!=0){bucle--;datoInst->tipo=7;datoInst->nBucle=bucle;tablaInst->insertar(datoInst);}} //se añade instrucción "ficticia" para diferenciar bucles consecutivos
	| instr ';' bloque	{}
	;
instr:	  START					{if((ifblock && cmp)||(ifblock==false)){ datoInst->tipo=4;datoInst->nBucle=bucle;tablaInst->insertar(datoInst);}}
	| PAUSE expr				{if((ifblock && cmp)||(ifblock==false)){ datoInst->tipo=6;datoInst->nBucle=bucle;datoInst->valor.valor_entero=$2;tablaInst->insertar(datoInst);}}
	| PAUSE					{if((ifblock && cmp)||(ifblock==false)){ datoInst->tipo=3;datoInst->nBucle=bucle;tablaInst->insertar(datoInst);}}
	| ID expr				{if((ifblock && cmp)||(ifblock==false)){ if(tablaSens->buscar($1, datoSens)){ if(datoSens->tipo!=7) datoInst->tipo=0;else datoInst->tipo=1; strcpy(datoInst->ref,$1);
							if(datoSens->tipo==4){ datoInst->valor.valor_real=$2;tablaSens->actualizarValor($1,$2);}
							else if(datoSens->tipo==5){ datoInst->valor.valor_entero=$2; tablaSens->actualizarValor($1,$2);}
							else if(datoSens->tipo==8 || datoSens->tipo==7 || datoSens->tipo==9) datoInst->valor.valor_bool=$2;
							else cout << "ERROR: Tipo de dato del sensor no conocido: " << datoSens->tipo << endl;
						datoInst->nBucle=bucle; tablaInst->insertar(datoInst);}else cout<<"Sensor o activador " << $1 << " no encontrado. No se le puede asignar un valor. Línea " << n_lineas << endl;}}
	| ID expr CADENA			{if((ifblock && cmp)||(ifblock==false)){ datoInst->nBucle=bucle;if(tablaSens->buscar($1, datoSens)){ datoInst->tipo=0;strcpy(datoInst->ref,$1);
							if(datoSens->tipo==9) strcpy(datoInst->valor.valor_cadena, yylval.c_cadena); tablaInst->insertar(datoInst);
						}else cout<<"Sensor o activador " << $1 << " no encontrado. No se le puede asignar un valor. Línea " << n_lineas << endl;}}
	| ID expr ID				{if((ifblock && cmp)||(ifblock==false)){ datoInst->nBucle=bucle; datoInst->tipo=0;strcpy(datoInst->valor.valor_cadena, cade);strcpy(datoInst->ref,$1);tablaInst->insertar(datoInst);}}
	| IF comp THEN {ifblock=true;datoInst->nBucle=bucle;} '[' bloque ']'
	| REPEAT expr {reps[indice]=$2;indice++;bucle++;} '[' bloque ']'
	;
comp:	  expr '<' expr	{if($1<$3) cmp=true; else cmp=false; $$=cmp;}
	| expr LE expr	{if($1<$3||$1==$3) cmp=true; else cmp=false; $$=cmp;}
	| expr '>' expr	{if($1>$3) cmp=true; else cmp=false; $$=cmp;}
	| expr GE expr	{if($1>$3||$1==$3) cmp=true; else cmp=false; $$=cmp;}
	| expr EQ expr	{if($1==$3) cmp=true; else cmp=false; $$=cmp;}
	| expr NE expr	{if($1!=$3) cmp=true; else cmp=false; $$=cmp;}
	| comp AND comp	{if($1==true && $3==true) cmp=true; else cmp=false; $$=cmp;}
	| comp OR comp	{if($1==true || $3==true) cmp=true; else cmp=false; $$=cmp;}
	| NOT comp	{if($2==true) cmp=false; else cmp=true; $$=cmp;cout<<$2<<endl;}
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

		extern int reps[20];
		for (int i=0;i<20;i++) reps[i]=0;
		yyin = fopen(argv[1],"rt");
		
		n_lineas=0;
		extern Tabla *tablaVar;
		extern TablaSens *tablaSens;
		extern TablaInst *tablaInst;
		extern bool errSem;
		yyparse();
		fclose(yyin);

		if(errSem) return 1; //Error semántico, por limpieza de código no hay un IF gigante

		ofstream sal (argv[2], std::ofstream::trunc);
		//Cabecera del fichero de salida
		sal << "//============================================================================\n";
		sal << "// Name		: " << argv[2] << "\n";
		sal << "// Author	: Eric Ávila" << "\n";
		sal << "// Version	: \n";
		sal << "// Copyright	: Your copyright notice\n";
		sal << "// Description	: Este proyecto ayuda a conocer el entorno gráfico del proyecto DSLP\n";
		sal << "//============================================================================\n\n";
		sal << "#include <iostream>\n#include \"entorno_dspl.h\"\n\nusing namespace std;\n";

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
				sal << "0,\"" << aux->elem.alias << "\");\n";
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
		inst *ins = tablaInst->getPrimero();
		tipo_datoTSens *datoSe = (tipo_datoTSens*)malloc(sizeof(tipo_datoTSens));
		int loop=0, idx=0;
		while(ins!=NULL){
			if(ins->elem.nBucle > loop){
				sal << "	for(int i"<<loop<<"=0; i"<<loop<<"<"<<reps[idx]<<"; i"<<loop<<"++){\n";
				loop++;
				idx++;
			}else if(ins->elem.nBucle < loop){
			//	sal << "	}\n";
				loop--;
			}
			switch(ins->elem.tipo){
				case 0:		//asignacion
					tablaSens->buscar(ins->elem.ref, datoSe);
					if(datoSe->tipo==TIPO_SWITCH && ins->elem.valor.valor_bool==true){
						sal << "	entornoPonerAct_Switch(" << datoSe->posY << "," << datoSe->posX << ",true," << "\"" << datoSe->alias << "\");\n";
					}else if(datoSe->tipo==TIPO_SWITCH && ins->elem.valor.valor_bool==false){
						sal << "	entornoPonerAct_Switch(" << datoSe->posY << "," << datoSe->posX << ",false," << "\"" << datoSe->alias << "\");\n";
					}else if(datoSe->tipo==TIPO_MESSAGE && strcmp(ins->elem.valor.valor_cadena,"")==0){
						sal << "	entornoBorrarMensaje();\n";
					}else if(datoSe->tipo==TIPO_MESSAGE){
						sal << "	entornoMostrarMensaje(\"" << ins->elem.valor.valor_cadena << "\");\n";
					}else {sal << "	entornoPonerSensor(" << datoSe->posY << "," << datoSe->posX << ",";
						if(datoSe->tipo==TIPO_TEMPERATURE) sal<<"S_temperature," << ins->elem.valor.valor_real;
						else if(datoSe->tipo==TIPO_SMOKE) sal<<"S_smoke," << ins->elem.valor.valor_entero;
						else if(datoSe->tipo==TIPO_LIGHT) sal<<"S_light," << ins->elem.valor.valor_real;
						else if(datoSe->tipo!=TIPO_ALARM) cout << "Error al actualizar el valor de un sensor. No es temp, smoke ni light. Es tipo " << datoSe->tipo << endl;
						sal << ",\"" << datoSe->alias << "\");\n";
					}
					break;
				case 1:		//Alarma ON
					sal << "	entornoAlarma();\n";
					break;
				case 2:		//OFF - no se utiliza, ya que los sensores OFF son tipo entornoPonerSensor (case 0)
					break;
				case 3:		//pause sin tiempo
					sal << "	entornoPulsarTecla();\n";
					break;
				case 4:		//start
					sal << "	inicio();\n";
					break;
				case 5:		//scene
					sal << "	entornoPonerEscenario(\"" << ins->elem.valor.valor_cadena << "\");\n";
					break;
				case 6:		//pause con tiempo
					sal << "	entornoPausa(" << ins->elem.valor.valor_entero << ");\n";
					break;
				case 7:		//instrucción ficticia para permitir bucles consecutivos
					sal << "	}\n";
					break;
				default:
					cout << "ERROR. Tipo de instrucción no reconocido." << endl;
			}
			ins=ins->sig;
		}
		sal << "	entornoTerminar();\n	}\n	return 0;\n}";


		//************************************************************Zona de debug************************************************************
		bool debug=true; //Poner a true para que se genere tablaSimbolos.txt, conteniendo información de las distintas tablas de símbolos.
		if(debug){
		ofstream tabla ("tablaSimbolos.txt", std::ofstream::trunc);
		//----TABLA DE VARIABLES----
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
		//----SENSORES SIN INICIALIZAR----
		tabla << "\n\nSensores sin inicializar\n******************************************" << endl;
		aux = tablaSens->getPrimero();
		while(aux!=NULL){
			if(aux->elem.inicializado=false)
				tabla << aux->elem.nombre << "\n";
			aux=aux->sig;
		}
		tabla << "******************************************" << endl;
		//----SENSORES INICIALIZADOS----
		tabla << "\n\nSensores \n******************************************" << endl;
		aux = tablaSens->getPrimero();
		while(aux!=NULL){
			if(aux->elem.inicializado=true)
				tabla << aux->elem.tipo << "	" << aux->elem.nombre  << "		" << aux->elem.valor << "\n";
			aux=aux->sig;
		}
		tabla << "******************************************" << endl;
		//----LISTA DE INSTRUCCIONES----
		tabla << "\n\nInstrucciones (tipos)\n******************************************" << endl;
		ins = tablaInst->getPrimero();
		while(ins!=NULL){
			tabla << ins->elem.tipo << endl;
			ins=ins->sig;
		}
		tabla << "******************************************" << endl;
		}//debug


	}else
		printf("Error en la llamada. Ejemplo: %s ficheroEntrada ficheroSalida\n", argv[0]);
	return 0;
}
