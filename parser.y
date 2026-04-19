%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"

void yyerror(const char *s);
int yylex();
extern int line;

char current_class[50];

// 🌳 AST Node
typedef struct ASTNode {
    char operatorName[10];
    char returnType[50];
    char paramType[50];
    char paramName[50];
} ASTNode;

// 🌳 Create Node
ASTNode* createNode(const char* op, const char* ret, const char* pType, const char* pName) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    strcpy(node->operatorName, op);
    strcpy(node->returnType, ret);
    strcpy(node->paramType, pType);
    strcpy(node->paramName, pName);
    return node;
}

// Store param temporarily
char param_type[50];
char param_name[50];

%}

%union {
    const char* str;
}

%token CLASS OPERATOR ID PUBLIC INT
%token PLUS MINUS MUL DIV EQ
%token LBRACE RBRACE LPAREN RPAREN SEMICOLON
%token LBRACKET RBRACKET COLON

%type <str> ID operator_symbol type

%%

// -------- PROGRAM --------
program:
    class_def
;

// -------- CLASS --------
class_def:
    CLASS ID {
        strcpy(current_class, $2);
        printf("Class: %s\n", current_class);
    }
    LBRACE members RBRACE SEMICOLON
;

// -------- MEMBERS --------
members:
    member_list
;

member_list:
      member_list member
    | member
;

// -------- MEMBER --------
member:
      operator_overload
    | declaration
    | PUBLIC COLON
;

// -------- VARIABLE --------
declaration:
    INT ID SEMICOLON
;

// -------- TYPE --------
type:
      ID  { $$ = $1; }
    | INT { $$ = "int"; }
;

// -------- PARAM --------
param:
      ID ID {
          strcpy(param_type, $1);
          strcpy(param_name, $2);
      }
    | INT ID {
          strcpy(param_type, "int");
          strcpy(param_name, $2);
      }
;

// -------- OPERATOR OVERLOAD --------
operator_overload:
    type OPERATOR operator_symbol LPAREN param RPAREN SEMICOLON
    {
        printf("Operator %s detected at line %d\n", $3, line);

        // ❌ Wrong return type
        if(strcmp($1, current_class) != 0) {
            printf("Semantic Error (line %d): Wrong return type\n", line);
        }

        // Store operator
        addOperator(current_class, $3, $1, 1);

        // ❌ Duplicate operator
        if(checkDuplicate(current_class, $3)) {
            printf("Semantic Error (line %d): Duplicate operator\n", line);
        }

        // 🌳 AST Creation
        ASTNode* node = createNode($3, $1, param_type, param_name);

        // 🌳 AST PRINT
        printf("\nOperator(%s)\n", node->operatorName);
        printf(" ├── ReturnType → %s\n", node->returnType);
        printf(" └── Param      → %s %s\n", node->paramType, node->paramName);
    }
;

// -------- OPERATORS --------
operator_symbol:
      PLUS   { $$ = "+"; }
    | MINUS  { $$ = "-"; }
    | MUL    { $$ = "*"; }
    | DIV    { $$ = "/"; }
    | EQ     { $$ = "=="; }
    | LBRACKET RBRACKET { $$ = "[]"; }
;

%%

// -------- ERROR --------
void yyerror(const char *s) {
    printf("Syntax Error at line %d: %s\n", line, s);
}

// -------- MAIN --------
int main() {
    yyparse();
    printf("\nParsing Done\n");
    return 0;
}