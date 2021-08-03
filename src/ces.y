%{
#include "heading.h"
int yyerror(char *s);
extern "C" int yylex();

enum type_t{
  sin_tipo
  entero,
};

struct var_atr {
  int value;
  int decl_line;
};

struct func_atr {
  type_t rtype;
  int n_params;
  int decl_line;
};

map<string, var_atr> variables;
map<string, func_atr> functions;

bool find_var(string id);
bool find_func(string id);

%}

%union{
  string str_val;
  int int_val;
}

%start programa

%token entero
%token sin_tipo
%token retorno
%token mientras
%token si
%token sino
%token <str_val> ID
%token <int_val> NUM
%token EOS
%token main

%%

programa: lista_declaracion ;
lista_declaracion: lista_declaracion declaracion | declaracion ;
declaracion: var_declaracion | fun_declaracion ;

var_declaracion:
  entero ID EOS {
    if (find_var($2)) yyerror("Variable already declared");
    else if (find_func($2)) yyerror("A function exists with this name")
    else {
      var_atr atr;
      atr.decl_line = yylineno;
      variables[$2] = atr;
    }
  }
  | entero ID '['NUM']' EOS
  ;

tipo: entero | sin_tipo ;

fun_declaracion: 
  tipo ID '('params')' sent_compuesta {
    if (find_func($1)) yyerror("Function already declared")
  }
  ;
params: lista_params | sin_tipo ;
lista_params: lista_params ',' param | param ;
param: tipo ID | tipo ID "[]" ;

sent_compuesta: '{'declaracion_local lista_sentencias'}' ;
declaracion_local: declaracion_local var_declaracion | /* empty */ ;
lista_sentencias: lista_sentencias sentencia | /* empty */ ;
sentencia: sentencia_expresion 
  | sentencia_seleccion 
  | sentencia_iteracion 
  | sentencia_retorno
  ;
sentencia_expresion: expresion EOS | EOS ;
sentencia_seleccion: si '('expresion')' sentencia | si '('expresion')' sentencia sino sentencia ;
sentencia_iteracion: mientras '('expresion')' '{'lista_sentencias'}' ;
sentencia_retorno: retorno EOS | retorno expresion EOS ;

expresion: 
  var'='expresion
  | expresion_simple 
  ;
var: 
  ID {
    if (!find_var($1)) yyerror("Undeclared variable")
  }
  | ID '['expresion']' {
    if (!find_var($1)) yyerror("Undeclared variable")
  }
  ;

expresion_simple: expresion_aditiva relop expresion_aditiva | expresion_aditiva ;
relop: '<' | "<=" | '>' | ">=" | "==" | "!=" ;

expresion_aditiva: expresion_aditiva addop term | term ;
addop: "+" | "−" ;
term: term mulop factor | factor ;
mulop: "*" | "/" ;
factor: '('expresion')' | var | call | NUM ;
call: ID '('args')' {
  if (!find_func($1)) yyerror("Undeclared function")
}
;
args: lista_arg | /* empty */ ;
lista_arg: lista_arg ',' expresion | expresion ;

%%

int yyerror(string s)
{
  extern int yylineno;	// defined and maintained in lex.c
  extern char *yytext;	// defined and maintained in lex.c

  cerr << "ERROR: " << s << " at symbol \"" << yytext;
  cerr << "\" on line " << yylineno << endl;
  exit(1);
}

int yyerror(char *s)
{
  return yyerror(string(s));
}

bool find_var(string id) {
  return variables.find(id) != variables.end();
}

bool find_func(string id) {
  return functions.find(id) != variables.end();
}
