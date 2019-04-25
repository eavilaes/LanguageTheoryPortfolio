%{

#include <iostream>
#include <cmath>

using namespace std;

void prompt(){
  	cout << "LISTO> ";
}

bool real=false;
bool error=false;
bool cmp=false;

//elementos externos al analizador sintácticos por haber sido declarados en el analizador léxico      			
extern int n_lineas;
extern int yylex();


//definición de procedimientos auxiliares
void yyerror(const char* s){         /*    llamada por cada error sintactico de yacc */
	cout << "Error sintáctico en la línea "<< n_lineas+1<<endl;
	real=false;
	error=false;
	prompt();
} 

%}

%start entrada

%token <c_entero> ENTERO
%token <c_cadena> IDENTIFICADOR
%token <c_real> REAL
%token SALIR
%token <c_bool> BOOL
%token LE GE EQ NE	/* comparadores */
%token AND OR NOT	/* operadores lógicos */

%left "||"	/* asociativo por la izquierda, prioridad más baja */
%left "&&"
%right '!'
%left '<' "<=" '>' ">=" "==" "!="
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
entrada: 		{prompt();}
      |entrada linea
      ;
linea: 	 expr '\n'		{if(!error){ cout << "La instrucción " << n_lineas << " tiene como resultado: "; if(!cmp) cout << $1; else if(cmp && $1==0) cout << "false"; else cout << "true";}else{cout << "Error semántico en la línea " << n_lineas << ": El operador % no se puede usar con datos de tipo real"; error=false;}; cmp=false; real=false; cout<<endl; prompt();}
	|asignacion '\n'	{real=false; error=false; prompt();}
	|SALIR 	'\n'		{return(0);}
	|error '\n'		{yyerrok;}
	;
expr:    ENTERO 		{$$=$1;}
       | REAL			{real=true;$$=$1;}
       | BOOL			{cmp=true;$$=$1;}
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
asignacion:	IDENTIFICADOR '=' expr	{if(!error){cout << "La instrucción " << n_lineas << " hace que la variable " << $1 << ", de tipo ";if(cmp){cout << " lógico, tenga el valor ";if($3==0) cout << "false";else cout << "true";}else if(real) cout << " real, tenga el valor " << $3;else cout << " entero, tenga el valor " << $3;cout << endl;}else{cout << "Error semántico en la línea " << n_lineas << ": El operador % no se puede usar con datos de tipo real" << endl;;error=false;}cmp=false;real=false;}
	;
%%

int main(){
     
     n_lineas = 0;
     
     cout <<endl<<"******************************************************"<<endl;
     cout <<"*      Calculadora de expresiones aritméticas        *"<<endl;
     cout <<"*                                                    *"<<endl;
     cout <<"*      1)con el prompt LISTO>                        *"<<endl;
     cout <<"*        teclea una expresión, por ej. 1+2<ENTER>    *"<<endl;
     cout <<"*        Este programa indicará                      *"<<endl;
     cout <<"*        si es gramaticalmente correcto              *"<<endl;
     cout <<"*      2)para terminar el programa                   *"<<endl;
     cout <<"*        teclear SALIR<ENTER>                        *"<<endl;
     cout <<"*      3)si se comete algun error en la expresión    *"<<endl;
     cout <<"*        se mostrará un mensaje y la ejecución       *"<<endl;
     cout <<"*        del programa finaliza                       *"<<endl;
     cout <<"******************************************************"<<endl<<endl<<endl;
     yyparse();
     cout <<"****************************************************"<<endl;
     cout <<"*                                                  *"<<endl;
     cout <<"*                 ADIOS!!!!                        *"<<endl;
     cout <<"****************************************************"<<endl;
     return 0;
}
