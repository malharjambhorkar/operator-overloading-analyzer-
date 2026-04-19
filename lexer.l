%{
#include "parser.tab.h"
#include <stdio.h>
#include <string.h>

int line = 1;
%}

%x COMMENT

%%

"//".*                 { }

"/*"                   { BEGIN(COMMENT); }
<COMMENT>"*/"          { BEGIN(INITIAL); }
<COMMENT>.             { }
<COMMENT>\n            { line++; }

"class"                { return CLASS; }
"operator"             { return OPERATOR; }
"int"                  { return INT; }
"public"               { return PUBLIC; }

"=="                   { return EQ; }
"["                    { return LBRACKET; }
"]"                    { return RBRACKET; }

"+"                    { return PLUS; }
"-"                    { return MINUS; }
"*"                    { return MUL; }
"/"                    { return DIV; }

":"                    { return COLON; }

"{"                    { return LBRACE; }
"}"                    { return RBRACE; }
"("                    { return LPAREN; }
")"                    { return RPAREN; }
";"                    { return SEMICOLON; }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return ID; }

\n                     { line++; }
[ \t]                  { }

.                      { }

%%

int yywrap() {
    return 1;
}