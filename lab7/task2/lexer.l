%{
#include "parser.tab.h"
#include <string.h>
%}

%%
[ \t\r\n]+              ;
"if"                   { return IF; }
"else"                 { return ELSE; }
"<="                   { yylval.str = strdup(yytext); return RELOP; }
">="                   { yylval.str = strdup(yytext); return RELOP; }
"=="                   { yylval.str = strdup(yytext); return RELOP; }
"!="                   { yylval.str = strdup(yytext); return RELOP; }
"<"                    { yylval.str = strdup(yytext); return RELOP; }
">"                    { yylval.str = strdup(yytext); return RELOP; }
[a-zA-Z_][a-zA-Z0-9_]*   { yylval.str = strdup(yytext); return ID; }
[0-9]+(\.[0-9]+)?        { yylval.str = strdup(yytext); return NUM; }
"="                    { return '='; }
";"                    { return ';'; }
"+"                    { return '+'; }
"-"                    { return '-'; }
"*"                    { return '*'; }
"/"                    { return '/'; }
"("                    { return '('; }
")"                    { return ')'; }
.                      { return yytext[0]; }
%%

int yywrap(void) {
    return 1;
}
