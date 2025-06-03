%{
#include "sql_yacc.tab.h"
#include <stdlib.h>
#include <string.h>

extern YYSTYPE yylval;
%}

%%

"SELECT"        { return SELECT; }
"FROM"          { return FROM; }
"WHERE"         { return WHERE; }
","             { return COMMA; }
";"             { return SEMICOLON; }
"="             { return EQ; }
"!="            { return NEQ; }
"<="            { return LE; }
">="            { return GE; }
"<"             { return LT; }
">"             { return GT; }
"*"             { return STAR; }

[0-9]+          { yylval.num = atoi(yytext); return NUMBER; }

\"[^\"]*\"      {
                    yylval.str = malloc(strlen(yytext) + 1);
                    strcpy(yylval.str, yytext);
                    return STRING;
                }

[a-zA-Z_][a-zA-Z0-9_]* {
                    yylval.str = malloc(strlen(yytext) + 1);
                    strcpy(yylval.str, yytext);
                    return IDENTIFIER;
                }

[ \t\r\n]+      { /* skip whitespace */ }

.               { return yytext[0]; }

%%

int yywrap() {
    return 1;
}
