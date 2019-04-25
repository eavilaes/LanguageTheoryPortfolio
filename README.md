# Language Theory Portfolio
This repository is a portfolio for the "Languages Theory" subject, where I had to do some exercises related with Lexical and
Syntactic analyzers.

The different sessions contain different topics to work on, and they may depend on the previous ones. They are used to practice
for the final activities and the project.

Each session is in a separated folder to keep all the contents organized.

There are also three 'final' activities and a final project, which are explained below:
## Lexical Analyzer
This was the first activity developed in the subject. It is written in Lex, and it is a simple lexical analyzer which function
is to 'translate' a C program from an input file (keep in mind that it is a very simple C program) to an output file
containing 'token' words.

## Syntactic Analyzer
This was the second activity developed in the subject. It is written both in Lex and Yacc, and it is a calculator which can do
both arithmetic and logic operations (sums, multiplications, boolean comparisons...). It has to be run in the console, and it
has a simple interface.

## Calculator
This was the third activity developed in the subject. It is writen in Lex and Yacc, including a custom C library (data structure),
and it is a different type of calculator of the previous one. It takes an input file with a set of assignments (e.g. A = 2*B),
and it produces an output file with the final result of all the variables. It shows up the errors (if any) in the console.

## Project
This is the final project for the subject. It is the developement of a new language 'DSPL', which stands for 'Demo Smart Place
Language'. It is a language for creating demos of smart places (such as a home). It manages sensors and activators, and all of
the components are shown in a graphical interface written in C (with the Allegro library).
