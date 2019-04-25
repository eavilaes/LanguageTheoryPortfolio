%{
#include <iostream>

using namespace std;
unsigned parejas[128][128];   //matriz de contadores
%}

letra [a-zA-Z]
%option noyywrap

%%
{letra}{letra}               ++parejas[yytext[0]][yytext[1]]; yyless(1);
\n                             ;
.                              ;
%%
int main(){
	
		        
		yylex();
		int i, j; //mostramos el contenido de la matriz de contadores
		for (i = 'A'; i <= 'z'; ++i) 
			if (isalpha(i)) 
				for (j = 'A'; j <= 'z'; ++j) 
					if (isalpha(j) && parejas[i][j] != 0)
						cout <<char(i) <<char(j)<<"  "<< parejas[i][j]<<endl;

	
		return 0;
}
