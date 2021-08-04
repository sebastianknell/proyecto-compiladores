%{
#include <stdio.h>
%}

whitespace      [ \t]+
id              [A-Za-z]+
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

\n          {/* yylineno++; */ printf("\n");}

"entero"    { /* return entero; */ printf("%s\n", yytext);}
"retorno"   { /* return retorno; */ printf("%s\n", yytext);}
"sin_tipo"  { /* return sin_tipo; */ printf("%s\n", yytext);}
"mientras"  { /* return mientras; */ printf("%s\n", yytext);}
"si"        { /* return si; */ printf("%s\n", yytext);}
"sino"      { /* return sino; */ printf("%s\n", yytext);}
"main"      { /* return main; */ printf("%s\n", yytext);}

{id}        { /* yylval.str_val = new string(yytext); return ID; */ printf("%s\n", yytext);}
{num}       { /* yylval.int_val = stoi(yytext); return NUM; */ printf("%s\n", yytext);}

";"         { /* return EOS; */ printf("%s\n", yytext);}

">"         { /* return *yytext; */ printf("%s\n", yytext);}
"<"         { /* return *yytext; */ printf("%s\n", yytext);}
">="        { /* return *yytext; */ printf("%s\n", yytext);}
"<="        { /* return *yytext; */ printf("%s\n", yytext);}
"=="        { /* return *yytext; */ printf("%s\n", yytext);}
"!="        { /* return *yytext; */ printf("%s\n", yytext);}

[=,()\[\]{}+-/*] { printf("%s\n", yytext); }

.		    { /* std::cerr << "SCANNER "; yyerror("Invalid character"); exit(1); */ printf("Error");}

%%
