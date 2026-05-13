%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char *L1;
    char *L2;
} LabelPair;

static int temp_count = 0;
static int label_count = 0;
static LabelPair label_stack[128];
static int label_top = -1;

static char *new_temp(void) {
    char buf[32];
    snprintf(buf, sizeof(buf), "t%d", ++temp_count);
    return strdup(buf);
}

static char *new_label(void) {
    char buf[32];
    snprintf(buf, sizeof(buf), "L%d", ++label_count);
    return strdup(buf);
}

static void push_labels(char *L1, char *L2) {
    label_stack[++label_top].L1 = L1;
    label_stack[label_top].L2 = L2;
}

static LabelPair pop_labels(void) {
    return label_stack[label_top--];
}

static LabelPair peek_labels(void) {
    return label_stack[label_top];
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

static char *make_rel(const char *left, const char *op, const char *right) {
    char buf[128];
    snprintf(buf, sizeof(buf), "%s %s %s", left, op, right);
    return strdup(buf);
}

static void emit_if_false(const char *cond, const char *label) {
    printf("ifFalse %s goto %s\n", cond, label);
}

static void emit_goto(const char *label) {
    printf("goto %s\n", label);
}

static void emit_label(const char *label) {
    printf("%s:\n", label);
}

int yylex(void);
void yyerror(const char *s);
%}

%union {
    char *str;
}

%token IF ELSE
%token <str> ID NUM RELOP
%type <str> expr cond

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
    | IF '(' cond ')'
      {
          char *L1 = new_label();
          char *L2 = new_label();
          emit_if_false($3, L1);
          push_labels(L1, L2);
      }
      stmt
      ELSE
      {
          LabelPair lp = peek_labels();
          emit_goto(lp.L2);
          emit_label(lp.L1);
      }
      stmt
      {
          LabelPair lp = pop_labels();
          emit_label(lp.L2);
      }
    ;

cond
    : expr RELOP expr { $$ = make_rel($1, $2, $3); }
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
