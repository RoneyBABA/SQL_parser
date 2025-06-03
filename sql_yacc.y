%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE *yyin;
void yyerror(const char *s);
int yylex(void);
%}

%union {
    char *str;
    int num;
}

%token SELECT FROM WHERE COMMA SEMICOLON STAR
%token <str> IDENTIFIER STRING
%token <num> NUMBER
%token EQ NEQ LT GT LE GE

%%

stmt:
    SELECT select_list FROM IDENTIFIER where_clause SEMICOLON
        { printf("✅ Valid SELECT statement\n"); }
    ;

select_list:
      STAR
    | IDENTIFIER
    | IDENTIFIER COMMA select_list
    ;

where_clause:
      /* optional */
    | WHERE condition
    ;

condition:
    IDENTIFIER comparator value
    ;

comparator:
      EQ | NEQ | LT | GT | LE | GE
    ;

value:
      NUMBER | STRING | IDENTIFIER
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "❌ Syntax Error: %s\n", s);
}

int main(int argc, char *argv[]) {
    if (argc > 1) {
        FILE *fp = fopen(argv[1], "r");
        if (!fp) {
            perror("Error opening file");
            return 1;
        }
        yyin = fp;
    } else {
        yyin = stdin;
        printf("Enter SQL (Ctrl+Z to finish):\n");
    }

    return yyparse();
}
