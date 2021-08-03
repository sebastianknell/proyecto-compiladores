%{
#include "heading.h"
#include "tok.h"
extern "C" int yylex();
int yyerror(char *s);
%}

whitespace      [ \t]+
id              [A-Za-z]+
digit           [0-9]+

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

{id}        { return ID; }
{digit}     { return NUM; }

";"         { return EOS; }

.		    { std::cerr << "SCANNER "; yyerror(""); exit(1); }

%%
