%{
#include "parser.tab.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int line = 1;
%}

%%

[ \t\r]+                { }
\n                      { line++; }

"//".*                  { }
"#".*                   { }
"using"[ \t]+"namespace".* { }

"class"                 { return CLASS; }
"operator"              { return OPERATOR; }
"public"                { return PUBLIC; }
"const"                 { return CONST; }
"int"                   { return INT; }
"bool"                  { return BOOL; }
"void"                  { return VOID; }
"return"                { return RETURN; }

"=="                    { return EQ; }
"+"                     { return PLUS; }
"-"                     { return MINUS; }
"*"                     { return MUL; }
"/"                     { return DIV; }
"["                     { return LBRACKET; }
"]"                     { return RBRACKET; }
"{"                     { return LBRACE; }
"}"                     { return RBRACE; }
"("                     { return LPAREN; }
")"                     { return RPAREN; }
";"                     { return SEMICOLON; }
":"                     { return COLON; }
","                     { return COMMA; }
"&"                     { return AMP; }
"="                     { return ASSIGN; }

[0-9]+                  { yylval.str = strdup(yytext); return NUMBER; }
\"([^\\\n]|(\\.))*\"    { yylval.str = strdup(yytext); return STRING_LITERAL; }
[a-zA-Z_][a-zA-Z0-9_]*  { yylval.str = strdup(yytext); return ID; }

.                       { }

%%

int yywrap(void) {
    return 1;
}
