%{
#include <stdio.h>
#include <stdlib.h>

// Declare yyin so parser reads from a file
extern FILE *yyin;

void yyerror(const char *s);
int yylex(void);
%}

%token SELECT FROM WHERE IDENTIFIER COMMA SEMICOLON

%%

stmt:
      SELECT select_list FROM IDENTIFIER where_clause SEMICOLON
        { printf("✅ Valid SELECT statement\n"); }
    ;

select_list:
      IDENTIFIER
    | IDENTIFIER COMMA select_list
    ;

where_clause:
      /* optional */
      /* empty */
    | WHERE IDENTIFIER
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
        yyin = fp; // ✅ assign the file to yyin
    } else {
        yyin = stdin; // fallback to standard input
        printf("Enter SQL (Ctrl+Z to finish):\n");
    }

    return yyparse();
}
