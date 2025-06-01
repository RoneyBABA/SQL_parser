%{
#include "sql_yacc.tab.h"  // Include Bison-generated token definitions
%}

%%

"SELECT"        { return SELECT; }
"FROM"          { return FROM; }
"WHERE"         { return WHERE; }
","             { return COMMA; }
";"             { return SEMICOLON; }

[a-zA-Z_][a-zA-Z0-9_]*    { return IDENTIFIER; }

[ \t\r\n]+      { /* skip whitespace */ }

.               { return yytext[0]; }  // catch-all for unknown characters

%%

int yywrap() {
    return 1;
}
