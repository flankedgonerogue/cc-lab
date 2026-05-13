%{
#include "Lab08_Example.tab.h"
#include <string.h>
%}

%%
[0-9]+                  { yylval.str = strdup(yytext); return NUM; }
[a-zA-Z_][a-zA-Z0-9_]*   { yylval.str = strdup(yytext); return ID; }
"="                    { return ASSIGN; }
"+"                    { return PLUS; }
"*"                    { return MUL; }
";"                    { return SEMICOLON; }
"("                    { return LPAREN; }
")"                    { return RPAREN; }

[ \t\n]+               ;
.                       { return yytext[0]; }
%%

int yywrap(void) {
    return 1;
}
