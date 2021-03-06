%{
#include "heading.h"
#include "tok.h"
extern "C" int yylex();
int yyerror(char *s);
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;
%}

whitespace      [ \t]+
id              [A-Za-z_]+
num             [0-9]+

%x IN_COMMENT

%%

{whitespace}    ;

<INITIAL>{
    "/*"      BEGIN(IN_COMMENT);
}
<IN_COMMENT>{
    "*/"      BEGIN(INITIAL);
    [^*\n]+   // eat comment in chunks
    "*"       // eat the lone star
    \n        yylineno++;
}

\n          {yylineno++;}

"entero"    { yylval.int_val = 0; return entero; }
"sin_tipo"  { yylval.int_val = 1; return sin_tipo; }
"retorno"   { return retorno; }
"mientras"  { return mientras; }
"si"        { return si; }
"sino"      { return sino; }
"main"      { return main; }
"entrada"   { return entrada; }
"salida"    { return salida; }

{id}        { yylval.str_val = new string(yytext); return ID; }
{num}       { yylval.int_val = stoi(yytext); return NUM; }

";"         { return EOS; }

">"         { return RELOP_GT; }
"<"         { return RELOP_LT; }
">="        { return RELOP_GEQ; }
"<="        { return RELOP_LEQ; }
"=="        { return RELOP_EQ; }
"!="        { return RELOP_NEQ; }

[=,()\[\]{}+-/*] { return yytext[0]; }

.		    { std::cerr << "SCANNER "; yyerror("Invalid character"); exit(1); }

%%
