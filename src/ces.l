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

"entero"    { return entero; }
"retorno"   { return retorno; }
"sin_tipo"  { return sin_tipo; }
"mientras"  { return mientras; }
"si"        { return si; }
"sino"      { return sino; }
"main"      { return main; }

{id}        { yylval.str_val = new string(yytext); return ID; }
{num}       { yylval.int_val = stoi(yytext); return NUM; }

";"         { return EOS; }

">"         { return *yytext; }
"<"         { return *yytext; }
">="        { return *yytext; }
"<="        { return *yytext; }
"=="        { return *yytext; }
"!="        { return *yytext; }

[=,()\[\]{}+-/*] { return yytext[0]; }

.		    { std::cerr << "SCANNER "; yyerror("Invalid character"); exit(1); }

%%
