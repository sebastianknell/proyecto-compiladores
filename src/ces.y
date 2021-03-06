%{
#define YYDEBUG 1
#include "heading.h"
int yyerror(char *s);
int yyerror(string msg, string id, int line);
extern "C" int yylex();

struct var_atr {
  int type;
  int value;
  int decl_line;
};

struct func_atr {
  int rtype;
  int n_params;
  int decl_line;
};

map<string, var_atr> variables;
map<string, func_atr> functions;

bool find_var(string id);
bool find_func(string id);

%}

%union{
  string* str_val;
  int int_val;
}

%start programa

%token<int_val> entero sin_tipo
%token retorno mientras si sino
%token main
%token entrada salida

%token<str_val> ID 
%token<int_val> NUM 
%token EOS
%token RELOP_GT
%token RELOP_LT
%token RELOP_GEQ
%token RELOP_LEQ
%token RELOP_EQ
%token RELOP_NEQ

%left '+' '-'
%left '*' '/'

%type<int_val> tipo
%type<int_val> params lista_params param args lista_arg

%%

programa: lista_declaracion declaracion_main;
lista_declaracion: lista_declaracion declaracion | declaracion ;
declaracion: var_declaracion | fun_declaracion ;

declaracion_main: 
  tipo main '(' ')' sent_compuesta {
    if (find_func("main")) yyerror("Main function already declared");
    else{
      func_atr atr;
      atr.rtype = $1;
      atr.decl_line = @2.first_line;
      functions["main"] = atr;
    }
  } 
  ;

var_declaracion:
  tipo ID EOS {
    if (find_var(*$2)) yyerror("Variable already declared", *$2, @$.first_line);
    else if (find_func(*$2)) yyerror("A function exists with this name");
    else if ($1 != 0) yyerror("Variable must be of type entero");
    else {
      var_atr atr;
      atr.type = 0;
      atr.decl_line = @2.first_line;
      variables[*$2] = atr;
    }
  }
  | tipo ID '['NUM']' EOS {
    if (find_var(*$2)) yyerror("Variable already declared", *$2, @$.first_line);
    else if (find_func(*$2)) yyerror("A function exists with this name");
    else if ($1 != 0) yyerror("Variable must be of type entero");
    else {
      if ($4 < 0) yyerror("Array size must be non-negative");
    }
  }
  ;

tipo: 
  entero { $$ = $1; }
  | sin_tipo { $$ = $1; }
  ;

fun_declaracion: 
  tipo ID '(' params ')' sent_compuesta {
    if (find_func(*$2)) yyerror("Function already declared");
    else {
      func_atr atr;
      atr.rtype = $1;
      atr.n_params = $4;
      atr.decl_line = @2.first_line;
      functions[*$2] = atr; 
    }
  }
  ;

params: 
  lista_params { $$ = $1; }
  | /* empty */ { $$ = 0; }
  ;
lista_params: 
  lista_params ',' param { $$ = $1 + $3; }
  | param { $$ = $1; }
  ;
param: 
  tipo ID { $$ = 1; }
  | tipo ID '[' ']' { $$ = 1; }
  ;

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
    if (!find_var(*$1)) yyerror("Undeclared variable");
  }
  | ID '['expresion']' {
    if (!find_var(*$1)) yyerror("Undeclared variable");
  }
  ;

expresion_simple: expresion_aditiva relop expresion_aditiva | expresion_aditiva ;
relop: RELOP_LT | RELOP_LEQ | RELOP_GT | RELOP_GEQ | RELOP_EQ | RELOP_NEQ ;

expresion_aditiva: expresion_aditiva addop term | term ;
addop: '+' | '-' ;

term: 
  term mulop factor {

  }
  | factor
  ;

mulop: '*' | '/' ;
factor: '('expresion')' | var | call | NUM ;

call: 
  ID '('args')' {
    if (!find_func(*$1)) yyerror("Undeclared function");
    if (functions[*$1].n_params != $3) yyerror("Invalid number of arguments");
  }
  | entrada '('')'
  | salida '(' expresion ')'
  ;
args: 
  lista_arg { $$ = $1; }
  | /* empty */ { $$ = 0; }
  ;
lista_arg: 
  lista_arg ',' expresion { $$ = $1 + 1; }
  | expresion  { $$ = 1; }
  ;

%%

int yyerror(string s)
{
  extern int yylineno;	// defined and maintained in lex.c
  extern char *yytext;	// defined and maintained in lex.c

  cerr << "ERROR: " << s << " at symbol \"" << yytext;
  cerr << "\" on line " << yylineno << endl;
  exit(1);
}

int yyerror(string msg, string id, int line)
{
  cerr << "ERROR: " << msg << " at symbol \"" << id;
  cerr << "\" on line " << line << endl;
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
  return functions.find(id) != functions.end();
}
