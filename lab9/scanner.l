%{
#include "parser.tab.h"
#include <stdio.h>
%}

%%
[ \t\n]+                ;
"+"                    { return PLUS; }
"-"                    { return MINUS; }
"*"                    { return MULT; }
"/"                    { return DIV; }
"("                    { return LPAREN; }
")"                    { return RPAREN; }
[0-9]+                  { return NUM; }
[a-zA-Z_][a-zA-Z0-9_]*   { return ID; }
.                       { return yytext[0]; }
%%

int yywrap(void) {
    return 1;
}
