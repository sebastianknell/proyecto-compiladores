%{
#define YYDEBUG 1
#include "heading.h"
int yyerror(char *s);
int yyerror(string msg, string id, int line);
extern "C" int yylex();

enum type_t{
  sin_tipo_t,
  entero_t
};

struct var_atr {
  type_t type;
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
  string* str_val;
  int int_val;
}

%start programa

%token entero sin_tipo
%token retorno mientras si sino
%token main

%token ID NUM EOS
%token RELOP_GT
%token RELOP_LT
%token RELOP_GEQ
%token RELOP_LEQ
%token RELOP_EQ
%token RELOP_NEQ

%left '+' '-'
%left '*' '/'

%type<str_val> ID
%type<int_val> NUM
//%type<str_val> tipo

%%

programa: lista_declaracion declaracion_main;
lista_declaracion: lista_declaracion declaracion | declaracion ;
declaracion: var_declaracion | fun_declaracion | lista_sentencias  /* TODO: REMOVE. TEST ONLY */;

declaracion_main: sin_tipo main '(' ')' sent_compuesta {
    if (find_func("main")) yyerror("Main function already declared");
    else{
      func_atr atr;
      atr.rtype = sin_tipo_t;
      atr.decl_line = @2.first_line;
      functions["main"] = atr;
    }
  } | entero main '(' ')' sent_compuesta{
     if (find_func("main")) yyerror("Main function already declared");
     else{
      func_atr atr;
      atr.rtype = entero_t;
      atr.decl_line = @2.first_line;
      functions["main"] = atr;
    }
  }

var_declaracion:
  entero ID EOS {
    if (find_var(*$2)) yyerror("Variable already declared", *$2, @$.first_line);
    else if (find_func(*$2)) yyerror("A function exists with this name");
    else {
      var_atr atr;
      atr.type = entero_t;
      atr.decl_line = @2.first_line;
      variables[*$2] = atr;
    }
  }
  | entero ID '['NUM']' EOS {
    if (find_var(*$2)) yyerror("Variable already declared", *$2, @$.first_line);
    else if (find_func(*$2)) yyerror("A function exists with this name");
    else {
      if ($4 < 0) yyerror("Array size must be non-negative");
    }
  }
  ;

tipo: entero | sin_tipo ;

fun_declaracion: 
  tipo ID '(' params ')' sent_compuesta {
    if (find_func(*$2)) yyerror("Function already declared");
    else {
      func_atr atr;
      atr.rtype = entero_t;
      atr.decl_line = @2.first_line;
      functions[*$2] = atr; 
    }
  } 
  ;
params: lista_params | sin_tipo ;
lista_params: lista_params ',' param | param ;
param: tipo ID | tipo ID '[' ']' ;

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

expresion: var'='expresion 
| var'=' ID '(' ')' {
  if (!find_func(*$3))  yyerror("Undeclared function",*$3,@$.first_line);
} 
| expresion_simple | var ;

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
    printf("hola");
  }
  | factor
  ;

mulop: '*' | '/' ;
factor: '('expresion')' | var | call | NUM ;

call: ID '('args')' {
  if (!find_func(*$1)) yyerror("Undeclared function");
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
