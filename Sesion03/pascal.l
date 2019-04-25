%option noyywrap

%x  COM1 COM2

%%
"//"                            BEGIN(COM1);
<COM1>\n                        BEGIN(0);
"/*"                            BEGIN(COM2);
<COM2>"*/"                      BEGIN(0);

<COM1,COM2>.                    ;

[pP][rR][oO][gG][rR][aA][mM]    {fprintf(yyout,"PROGRAM");}
[bB][eE][gG][iI][nN]            {fprintf(yyout,"BEGIN");}
[eE][nN][dD]                    {fprintf(yyout,"END");}
[vV][aA][rR]                    {fprintf(yyout,"VAR");}
[fF][oO][rR]                    {fprintf(yyout,"FOR");}
[wW][hH][iI][lL][eE]            {fprintf(yyout,"WHILE");}
[rR][eE][pP][eE][aA][tT]        {fprintf(yyout,"REPEAT");}
.                               {ECHO;}

%%
int main(){
	yylex();
	return 0;
}

