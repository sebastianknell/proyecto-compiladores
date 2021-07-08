%{
#include <iostream>
using namespace std;
int mylineno = 0;
%}

%option noyywrap c++

whitespace      [ \t]+
id              [A-Za-z]
digit           [0-9]

%%

{whitespace}    ;

"/*"    {
            int c; 
            while ((c = yyinput()) != 0) {
                if(c == '\n')
                    ++mylineno;
                else if (c == '*') {
                    if ((c = yyinput()) == '/')
                        break;
                    else
                        unput(c);
                }
            }
        }

\n          mylineno++;

{id}        cout << "<ID, " << YYText() << ">";

{digit}     cout << "<DIGIT, " << YYText() << ">";


%%
