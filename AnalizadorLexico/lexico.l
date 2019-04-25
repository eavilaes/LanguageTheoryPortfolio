%{
#include <iostream>
using namespace std;
%}

digito				[0-9]
caracter			[A-Za-z_]

%x COM1 COM2
%option noyywrap

%%

"//"				{BEGIN(COM1);fprintf(yyout,"%s","\n");}
<COM1>"\n"			BEGIN(0);
"/*"				BEGIN(COM2);
<COM2>"*/"			BEGIN(0);
<COM1,COM2>.			;

main				fprintf(yyout,"%s","MAIN");
int				fprintf(yyout,"%s","INT");
float				fprintf(yyout,"%s","FLOAT");
for				fprintf(yyout,"%s","FOR");
cout				fprintf(yyout,"%s","COUT");
endl				fprintf(yyout,"%s","ENDL");
return				fprintf(yyout,"%s","RETURN");

{caracter}+({caracter}|{digito})*	fprintf(yyout,"%s","ID");

{digito}+[.]{digito}*([e][+-]?{digito}+)?	|
{digito}*[.]{digito}+([e][+-]?{digito}+)?	fprintf(yyout,"%s","REAL");

{digito}+				fprintf(yyout,"%s","ENTERO");

["][^"]*["]			fprintf(yyout,"%s","TEXTO");

^\n				;

%%
int main(int argc, char *argv[]){
  if(argc>2){
    yyin = fopen(argv[1], "rt");
    yyout = fopen(argv[2], "wt");
    yylex();
    fclose(yyin);
    fclose(yyout);
  } else cout << "Pocos argumentos" << endl;
}
