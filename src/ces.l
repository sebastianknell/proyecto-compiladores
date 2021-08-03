%{
#include "heading.h"
#include "tok.h"
extern "C" int yylex();
int yyerror(char *s);
%}

whitespace      [ \t]+
id              [A-Za-z]+
num           [0-9]+

%x IN_COMMENT

%%

{whitespace}    ;

"/*"        { BEGIN(IN_COMMENT); }
"*/"        { BEGIN(INITIAL); }

\n          {yylineno++;}

"entero"    { return entero; }
"retorno"   { return retorno; }
"sin_tipo"  { return sin_tipo; }
"mientras"  { return mientras; }
"si"        { return si; }
"sino"      { return sino; }
"main"      { return main; }

{id}        { yylval.id_val = string(yytext); return ID; }
{num}       { yylval.id_val = stoi(yytext); return NUM; }

";"         { return EOS; }

.		    { std::cerr << "SCANNER "; yyerror("Invalid character"); exit(1); }

%%
