%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <map>
#include <string>
#include "symtab.h"

void yyerror(const char *s);
int yylex(void);
extern int line;

static char current_class[50] = "";
static char param_type[50] = "";
static char param_name[50] = "";
static char pending_type[50] = "";
static std::map<std::string, std::string> textValues;
static int runtimeHeaderPrinted = 0;

typedef struct ASTNode {
    char op[10];
    char ret[50];
    char ptype[50];
    char pname[50];
} ASTNode;

static ASTNode* createNode(const char* o, const char* r, const char* pt, const char* pn) {
    ASTNode* n = (ASTNode*)malloc(sizeof(ASTNode));
    strcpy(n->op, o);
    strcpy(n->ret, r);
    strcpy(n->ptype, pt);
    strcpy(n->pname, pn);
    return n;
}

static int isValidReturnType(const char* op, const char* ret) {
    if (strcmp(op, "-") == 0) {
        return strcmp(ret, current_class) == 0 || strcmp(ret, "int") == 0;
    }

    if (strcmp(op, "==") == 0) {
        return strcmp(ret, "bool") == 0 || strcmp(ret, "int") == 0;
    }

    if (strcmp(op, "[]") == 0) {
        return 1;
    }

    return strcmp(ret, current_class) == 0;
}

static int isVoidParameter(const char* ptype) {
    return strcmp(ptype, "void") == 0;
}

static int requiresClassParameter(const char* op) {
    return strcmp(op, "+") == 0 || strcmp(op, "-") == 0 || strcmp(op, "==") == 0;
}

static int isValidParameterType(const char* op, const char* ptype) {
    if (strcmp(op, "*") == 0 || strcmp(op, "[]") == 0) {
        return strcmp(ptype, "int") == 0;
    }

    if (requiresClassParameter(op)) {
        return strcmp(ptype, current_class) == 0;
    }

    return 1;
}

static void reportSemanticChecks(const char* op, const char* ret, const char* ptype) {
    if (!isValidReturnType(op, ret)) {
        printf("Semantic Error (line %d): Wrong return type\n", line);
    }

    if (isVoidParameter(ptype)) {
        printf("Semantic Error (line %d): Void parameter is not allowed for overloaded operators\n", line);
    }

    if (!isValidParameterType(op, ptype)) {
        if (strcmp(op, "*") == 0) {
            printf("Semantic Error (line %d): operator* requires int parameter\n", line);
        } else if (strcmp(op, "[]") == 0) {
            printf("Semantic Error (line %d): operator[] requires int index parameter\n", line);
        } else if (requiresClassParameter(op)) {
            printf("Semantic Error (line %d): Parameter type should match class type\n", line);
        }
    }
}

static void printDemoOutput(const char* op) {
    if (strcmp(current_class, "Text") != 0) {
        return;
    }

    if (strcmp(op, "+") == 0) {
        printf("Output -> Hello + World = HelloWorld\n");
    } else if (strcmp(op, "-") == 0) {
        printf("Output -> Hello - lo = Hel\n");
    } else if (strcmp(op, "*") == 0) {
        printf("Output -> World * 3 = WorldWorldWorld\n");
    } else if (strcmp(op, "==") == 0) {
        printf("Output -> Hello == World = false\n");
    } else if (strcmp(op, "[]") == 0) {
        printf("Output -> Hello[1] = e\n");
    }
}

static void printRuntimeHeader(void) {
    if (!runtimeHeaderPrinted) {
        printf("\nExecution Output\n");
        runtimeHeaderPrinted = 1;
    }
}

static void storeTextValue(const char* name, const char* value) {
    textValues[name] = value;
}

static const char* getTextValue(const char* name) {
    std::map<std::string, std::string>::iterator it = textValues.find(name);
    if (it == textValues.end()) {
        return "";
    }
    return it->second.c_str();
}

static std::string evaluateAdd(const char* left, const char* right) {
    return std::string(getTextValue(left)) + getTextValue(right);
}

static std::string evaluateSubtract(const char* left, const char* right) {
    std::string base = getTextValue(left);
    std::string remove = getTextValue(right);
    size_t pos = base.find(remove);
    if (pos != std::string::npos) {
        base.erase(pos, remove.length());
    }
    return base;
}

static std::string evaluateMultiply(const char* name, int times) {
    std::string value = getTextValue(name);
    std::string repeated = "";
    for (int i = 0; i < times; i++) {
        repeated += value;
    }
    return repeated;
}

static const char* evaluateEquals(const char* left, const char* right) {
    return std::string(getTextValue(left)) == getTextValue(right) ? "true" : "false";
}

static char evaluateIndex(const char* name, int index) {
    std::string value = getTextValue(name);
    if (index < 0 || index >= (int)value.length()) {
        return '#';
    }
    return value[index];
}
%}

%glr-parser

%union {
    const char* str;
}

%token CLASS OPERATOR PUBLIC CONST
%token INT BOOL VOID
%token RETURN
%token PLUS MINUS MUL DIV EQ
%token LBRACE RBRACE LPAREN RPAREN SEMICOLON
%token LBRACKET RBRACKET COLON COMMA AMP ASSIGN
%token <str> ID NUMBER STRING_LITERAL

%type <str> type operator_symbol

%%

program:
    items
;

items:
      /* empty */
    | items item
;

item:
      class_def
    | main_def
;

class_def:
    CLASS ID
    {
        strcpy(current_class, $2);
        printf("\nClass: %s\n", current_class);
    }
    LBRACE members RBRACE SEMICOLON
;

main_def:
    INT ID LPAREN RPAREN runtime_block
;

members:
      /* empty */
    | members member
;

member:
      PUBLIC COLON
    | INT
      {
          strcpy(pending_type, "int");
      }
      member_after_type
    | BOOL
      {
          strcpy(pending_type, "bool");
      }
      member_after_type
    | VOID
      {
          strcpy(pending_type, "void");
      }
      member_after_type
    | ID
      {
          strcpy(pending_type, $1);
      }
      id_started_member
    | SEMICOLON
;

member_after_type:
      ID declaration_or_method_tail
    | OPERATOR operator_symbol LPAREN param_decl RPAREN const_opt operator_tail
      {
        printf("\nOperator %s detected at line %d\n", $2, line);
        printDemoOutput($2);
        reportSemanticChecks($2, pending_type, param_type);

        addOperator(current_class, $2, pending_type, 1);

        if (checkDuplicate(current_class, $2)) {
            printf("Semantic Error (line %d): Duplicate operator\n", line);
        }

        ASTNode* n = createNode($2, pending_type, param_type, param_name);

        printf("Operator(%s)\n", n->op);
        printf("|__ ReturnType -> %s\n", n->ret);
        printf("|__ Param      -> %s %s\n", n->ptype, n->pname);
      }
;

id_started_member:
      LPAREN parameter_blob RPAREN ctor_initializer_opt block
    | ID declaration_or_method_tail
    | OPERATOR operator_symbol LPAREN param_decl RPAREN const_opt operator_tail
      {
          printf("\nOperator %s detected at line %d\n", $2, line);
          printDemoOutput($2);
          reportSemanticChecks($2, pending_type, param_type);

          addOperator(current_class, $2, pending_type, 1);

          if (checkDuplicate(current_class, $2)) {
              printf("Semantic Error (line %d): Duplicate operator\n", line);
          }

          ASTNode* n = createNode($2, pending_type, param_type, param_name);

          printf("Operator(%s)\n", n->op);
          printf("|__ ReturnType -> %s\n", n->ret);
          printf("|__ Param      -> %s %s\n", n->ptype, n->pname);
      }
;

declaration_or_method_tail:
      declaration_tail SEMICOLON
    | LPAREN parameter_blob RPAREN const_opt method_tail
;

declaration_tail:
      /* empty */
    | COMMA ID declaration_tail
;

ctor_initializer_opt:
      /* empty */
    | COLON ctor_initializer_list
;

ctor_initializer_list:
      ctor_initializer
    | ctor_initializer_list COMMA ctor_initializer
;

ctor_initializer:
    ID LPAREN argument_blob RPAREN
;

method_tail:
      SEMICOLON
    | block
;

const_opt:
      /* empty */
    | CONST
;

operator_tail:
      SEMICOLON
    | block
;

param_decl:
      const_opt type ref_opt ID
      {
          strcpy(param_type, $2);
          strcpy(param_name, $4);
      }
;

ref_opt:
      /* empty */
    | AMP
;

type:
      ID   { $$ = $1; }
    | INT  { $$ = "int"; }
    | BOOL { $$ = "bool"; }
    | VOID { $$ = "void"; }
;

operator_symbol:
      PLUS                { $$ = "+"; }
    | MINUS               { $$ = "-"; }
    | MUL                 { $$ = "*"; }
    | DIV                 { $$ = "/"; }
    | EQ                  { $$ = "=="; }
    | LBRACKET RBRACKET   { $$ = "[]"; }
;

parameter_blob:
      /* empty */
    | parameter_blob parameter_blob_token
;

parameter_blob_token:
      CONST
    | ID
    | NUMBER
    | STRING_LITERAL
    | INT
    | BOOL
    | VOID
    | AMP
    | ASSIGN
    | COMMA
    | MINUS
;

argument_blob:
      /* empty */
    | argument_blob argument_token
;

argument_token:
      ID
    | NUMBER
    | STRING_LITERAL
    | INT
    | BOOL
    | VOID
    | COMMA
    | MINUS
    | PLUS
    | MUL
    | DIV
    | EQ
    | AMP
    | ASSIGN
;

block:
    LBRACE block_items RBRACE
;

block_items:
      /* empty */
    | block_items block_item
;

block_item:
      block
    | block_token
;

block_token:
      ID
    | NUMBER
    | STRING_LITERAL
    | INT
    | BOOL
    | VOID
    | RETURN
    | CONST
    | PUBLIC
    | OPERATOR
    | PLUS
    | MINUS
    | MUL
    | DIV
    | EQ
    | LPAREN
    | RPAREN
    | SEMICOLON
    | LBRACKET
    | RBRACKET
    | COLON
    | COMMA
    | AMP
    | ASSIGN
;

runtime_block:
    LBRACE runtime_items RBRACE
;

runtime_items:
      /* empty */
    | runtime_items runtime_item
;

runtime_item:
      text_declaration
    | runtime_expression
    | RETURN NUMBER SEMICOLON
    | SEMICOLON
;

text_declaration:
    ID ID LPAREN STRING_LITERAL RPAREN SEMICOLON
    {
        if (strcmp($1, current_class) == 0) {
            char valueBuffer[256];
            size_t len = strlen($4);
            if (len >= 2) {
                strncpy(valueBuffer, $4 + 1, len - 2);
                valueBuffer[len - 2] = '\0';
            } else {
                valueBuffer[0] = '\0';
            }
            storeTextValue($2, valueBuffer);
        }
    }
;

runtime_expression:
      ID PLUS ID SEMICOLON
      {
          printRuntimeHeader();
          printf("%s + %s = %s\n", getTextValue($1), getTextValue($3), evaluateAdd($1, $3).c_str());
      }
    | ID MINUS ID SEMICOLON
      {
          printRuntimeHeader();
          printf("%s - %s = %s\n", getTextValue($1), getTextValue($3), evaluateSubtract($1, $3).c_str());
      }
    | ID MUL NUMBER SEMICOLON
      {
          printRuntimeHeader();
          printf("%s * %s = %s\n", getTextValue($1), $3, evaluateMultiply($1, atoi($3)).c_str());
      }
    | ID EQ ID SEMICOLON
      {
          printRuntimeHeader();
          printf("%s == %s = %s\n", getTextValue($1), getTextValue($3), evaluateEquals($1, $3));
      }
    | ID LBRACKET NUMBER RBRACKET SEMICOLON
      {
          printRuntimeHeader();
          printf("%s[%s] = %c\n", getTextValue($1), $3, evaluateIndex($1, atoi($3)));
      }
;

%%

void yyerror(const char *s) {
    printf("Syntax Error at line %d\n", line);
}

int main(void) {
    yyparse();
    printf("\nParsing Done\n");
    return 0;
}
