%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

int yylex(void);
int yyerror(char *msg);

char tempVar[10];
int tempCount = 1;

char lastExpr[50] = "";
char lastTemp[10] = "";

void gen(char* target, char* src1, char* op, char* src2) {
    printf("%s = %s %s %s\n", target, src1, op, src2);
}

void genAssign(char* id, char* val) {
    printf("%s = %s\n", id, val);
}
%}

%union {
    char* str;
}

%token <str> ID NUM
%token ASSIGN PLUS MUL SEMICOLON LPAREN RPAREN

%left PLUS
%left MUL

%type <str> expr term factor

%start program
%%
program
    : program stmt
    | stmt
    ;

stmt
    : ID ASSIGN expr SEMICOLON
      {
          genAssign($1, $3);
      }
    ;

expr
    : expr PLUS term
      {
          sprintf(tempVar, "t%d", tempCount++);
          gen(tempVar, $1, "+", $3);
          $$ = strdup(tempVar);
      }
    | term
      {
          $$ = $1;
      }
    ;

term
    : term MUL factor
      {
          if (isdigit($1[0]) && isdigit($3[0])) {
              int val = atoi($1) * atoi($3);
              char buf[10];
              sprintf(buf, "%d", val);
              $$ = strdup(buf);
          } else {
              char exprStr[50];
              sprintf(exprStr, "%s*%s", $1, $3);
              if (strcmp(exprStr, lastExpr) == 0) {
                  $$ = strdup(lastTemp);
              } else {
                  sprintf(tempVar, "t%d", tempCount++);
                  gen(tempVar, $1, "*", $3);
                  strcpy(lastExpr, exprStr);
                  strcpy(lastTemp, tempVar);
                  $$ = strdup(tempVar);
              }
          }
      }
    | factor
      {
          $$ = $1;
      }
    ;

factor
    : ID
      {
          $$ = $1;
      }
    | NUM
      {
          $$ = $1;
      }
    | LPAREN expr RPAREN
      {
          $$ = $2;
      }
    ;
%%

int main(void) {
    yyparse();
    return 0;
}

int yyerror(char* msg) {
    printf("Syntax Error: %s\n", msg);
    return 0;
}
