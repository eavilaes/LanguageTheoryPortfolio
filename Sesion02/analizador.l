%{

#include <iostream>
using namespace std;

%}

%option noyywrap

%%

main				cout<<"MAIN";
int				cout<<"INT";
float				cout<<"FLOAT";
for				cout<<"FOR";
cout				cout<<"COUT";
endl				cout<<"ENDL";

[A-Za-z_]+[A-Za-z0-9_]*		cout<<"ID";

[0-9]+[.][0-9]*			cout<<"REAL";
[0-9]*[.][0-9]+			cout<<"REAL";
[0-9]+[.][0-9]*[e][+][1-9]+	cout<<"REAL";
[0-9]*[.][0-9]+[e][+][1-9]+	cout<<"REAL";

[0-9]+				cout<<"ENTERO";

["][^"]*["]			cout<<"CAD";

.				ECHO;

%%
int main(){

	yylex();

	return 0;
}

