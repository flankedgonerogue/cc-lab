%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
int yylex(void);
%}

%token ID NUM
%token PLUS MINUS MULT DIV LPAREN RPAREN

%%
E
    : E PLUS T   { printf("Reduce: E -> E + T\n"); }
    | E MINUS T  { printf("Reduce: E -> E - T\n"); }
    | T          { printf("Reduce: E -> T\n"); }
    ;

T
    : T MULT F   { printf("Reduce: T -> T * F\n"); }
    | T DIV F    { printf("Reduce: T -> T / F\n"); }
    | F          { printf("Reduce: T -> F\n"); }
    ;

F
    : LPAREN E RPAREN { printf("Reduce: F -> (E)\n"); }
    | ID              { printf("Reduce: F -> id\n"); }
    | NUM             { printf("Reduce: F -> num\n"); }
    ;
%%

void yyerror(const char *s) {
    printf("Error: %s\n", s);
}

int main(void) {
    printf("Enter an expression: ");
    yyparse();
    printf("Parsing completed successfully.\n");
    return 0;
}
