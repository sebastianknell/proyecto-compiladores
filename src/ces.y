%{
#include "heading.h"
int yyerror(char *s);
extern "C" int yylex();
%}

%%

programa: lista_declaracion ;
lista_declaracion: lista_declaracion declaracion | declaracion ;
declaracion: var_declaracion | fun_declaracion ;

var_declaracion:
  | entero ID;
  | entero ID [NUM];
  ;

tipo: entero | sin_tipo ;

fun_declaracion: tipo ID (params) sent_compuesta ;
params: lista_params | sin_tipo ;
lista_params: lista_params , param | param ;
param: tipo ID | tipo ID [] ;

sent_compuesta: {declaracion_local lista_sentencias} ;
declaracion_local: declaracion_local var_declaracion | vacio ;
lista_sentencias: lista_sentencias sentencia | vacio ;
sentencia: sentencia_expresion 
  | sentencia_seleccion 
  | sen- tencia_iteracion 
  | sentencia_retorno
  ;
sentencia_expresion: expresion ; | ; ;
sentencia_seleccion: si (expresion) sentencia | si (expresion) sentencia sino sentencia ;
sentencia_iteracion: mientras (expresion) {lista_sentencias} ;
sentencia_retorno: retorno ; | retorno expresion ; ;

expresion: var=expresion | expresion_simple ;
var: ID | ID [expresion] ;

expresion_simple: expresion_aditiva relop expresion_aditiva | expresión_aditiva ;
relop: < | <= | > | >= | == | != ;

expresion_aditiva: expresion_aditiva addop term | term ;
addop: + | − ;
term: term mulop factor | factor ;
mulop: ∗ | / ;
factor: (expresion) | var | call | NUM ;
call: ID (args) ;
args: lista_arg | vacio ;
lista_arg: lista_arg , expresion | expresion ;

