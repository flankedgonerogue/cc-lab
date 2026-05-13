%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int temp_count = 0;

static char *new_temp(void) {
    char buf[32];
    snprintf(buf, sizeof(buf), "t%d", ++temp_count);
    return strdup(buf);
}

static char *emit_binary(const char *left, const char *op, const char *right) {
    char *t = new_temp();
    printf("%s = %s %s %s\n", t, left, op, right);
    return t;
}

static char *emit_unary(const char *op, const char *operand) {
    char *t = new_temp();
    printf("%s = %s%s\n", t, op, operand);
    return t;
}

static void emit_assign(const char *id, const char *src) {
    printf("%s = %s\n", id, src);
}

int yylex(void);
void yyerror(const char *s);
%}

%union {
    char *str;
}

%token <str> ID NUM
%type <str> expr

%left '+' '-'
%left '*' '/'
%right UMINUS

%%
program
    : program stmt
    | stmt
    ;

stmt
    : ID '=' expr ';' { emit_assign($1, $3); }
    ;

expr
    : expr '+' expr { $$ = emit_binary($1, "+", $3); }
    | expr '-' expr { $$ = emit_binary($1, "-", $3); }
    | expr '*' expr { $$ = emit_binary($1, "*", $3); }
    | expr '/' expr { $$ = emit_binary($1, "/", $3); }
    | '-' expr %prec UMINUS { $$ = emit_unary("-", $2); }
    | '(' expr ')' { $$ = $2; }
    | ID { $$ = $1; }
    | NUM { $$ = $1; }
    ;
%%

int main(void) {
    return yyparse();
}

void yyerror(const char *s) {
    fprintf(stderr, "Syntax error: %s\n", s);
}
