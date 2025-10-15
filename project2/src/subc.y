/*
 * File Name    : subc.y
 * Description  : a skeleton bison input
 * 
 * Course       : Introduction to Compilers
 * Dept. of Electrical and Computer Engineering, Seoul National University
 */

%{
/* Prologue section */
#include "subc.h"
#define REDUCE reduce

int   yylex ();
int   yyerror (char* s);
int   get_lineno();
char* yyget_text();
void  reduce(char* s);
%}

/* Bison declarations section */

/* yylval types */
%union {
  int   intVal;
  char  *stringVal;
}

/* Tokens and Types */
%token TYPE STRUCT SYM_NULL RETURN
%token IF ELSE WHILE FOR BREAK CONTINUE     
%token VOID      
%token<stringVal> ID CHAR_CONST STRING
%token<stringVal> LOGICAL_OR LOGICAL_AND RELOP EQUOP
%token<stringVal> INCOP DECOP STRUCTOP
%token<intVal> INTEGER_CONST

/* Precedences and Associativities */
%left ','
%left STRUCTOP

%%

/* Grammar rules section*/
program
  : ext_def_list { REDUCE("program->ext_def_list"); } 
  ;

ext_def_list
  : ext_def_list ext_def { REDUCE("ext_def_list->ext_def_list ext_def"); } 
  | %empty  { REDUCE("ext_def_list->epsilon"); } 
  ;

ext_def
  : type_specifier pointers ID ';'
  | type_specifier pointers ID '[' INTEGER_CONST ']' ';'
  | struct_specifier ';'

type_specifier
  : TYPE
  | VOID
  | struct_specifier
  ;

struct_specifier
  : STRUCT ID '{' def_list '}'
  | STRUCT ID
  ;

func_decl
  : type_specifier pointers ID '(' ')'
  | type_specifier pointers ID '(' VOID ')'
  | type_specifier pointers ID '(' param_list ')'
  ; 

pointers
  : '*'
  | %empty
  ;

param_list
  : param_decl
  | param_list ',' param_decl
  ;

param_decl
  : type_specifier pointers ID
  | type_specifier pointers ID '[' INTEGER_CONST ']'
  ;

def_list
  : def_list def
  | %empty
  ;

def
  : type_specifier pointers ID ';'
  | type_specifier pointers ID '[' INTEGER_CONST ']' ';'
  ;

compound_stmt
  : '{' def_list stmt_list '}'
  ;

stmt_list
  : stmt_list stmt
  | %empty
  ;

stmt
  : expr ';'
  | compound_stmt 
  | RETURN ';'
  | RETURN expr ';'
  | ';'
  | IF '(' expr ')' stmt
  | IF '(' expr ')' stmt ELSE stmt
  | WHILE '(' expr ')' stmt
  | FOR '(' expr_e ';' expr_e ';' expr_e ')' stmt
  | BREAK ';'
  | CONTINUE ';'
  ;

expr_e
  : expr
  | %empty
  ;

expr
  : unary '=' expr
  | binary
  ;

binary
  : binary RELOP binary
  : binary EQUOP binary
  : binary '+' binary
  : binary '-' binary
  : binary '*' binary
  : binary '/' binary
  : binary '%' binary
  : unary %prec '='
  : binary LOGICAL_AND binary
  : binary LOGICAL_OR binary
  ;

unary
  : '(' expr ')'
  | INTEGER_CONST { REDUCE("unary->INTEGER_CONST"); }
  | CHAR_CONST { REDUCE("unary->CHAR_CONST"); }
  | STRING { REDUCE("unary->STRING"); }
  | ID { REDUCE("unary->ID"); }
  | '-' unary %prec '!'
  | '!' unary
  | unary INCOP
  | unary DECOP
  | INCOP unary
  | DECOP unary
  | '&' unary
  | '*' unary %prec '!'
  | unary '[' expr ']' 
  | unary '.' ID
  | unary STRUCTOP ID
  | unary '(' args ')'
  | unary '(' ')'
  | SYM_NULL
  ;

args
  : expr
  | args ',' expr
  ;

%%

/* Epilogue section */

int yyerror (char* s) {
  fprintf (stderr, "yyerror: %s at line %d, token '%s'\n", s, get_lineno(), yyget_text());
}

void reduce(char* s) {
  printf("%s\n", s);
}