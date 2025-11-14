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

int   yylex();
int   yyerror(char* s);
int   get_lineno();
char* yyget_text();
void  reduce(char* s);
%}

/* Bison declarations section */

/* yylval types */
%union {
  int         intval;
  double      floatval;
  char        *stringval;
  struct id   *idptr;
  struct decl *declptr;
  struct ste  *steptr;
}

/* Tokens and Types */
%token            TYPE STRUCT SYM_NULL RETURN IF ELSE WHILE FOR BREAK CONTINUE 
%token            LOGICAL_OR LOGICAL_AND RELOP EQUOP INCOP DECOP STRUCTOP
%token<stringval> ID CHAR_CONST STRING
%token<intval>    INTEGER_CONST
/* %token<floatval>  FLOAT_CONST */

/* Precedences and Associativities */
%left ','
%right '='
%left LOGICAL_OR
%left LOGICAL_AND
%left EQUOP
%left RELOP
%left '+' '-'
%left '*' '/' '%'
%right INCOP DECOP '!' '&'
%left '(' ')' '.' STRUCTOP '[' ']'

/* precedence rule for dangling else problem */
%precedence ELSE

%%

/* Grammar rules section*/
program
  : ext_def_list { reduce("program->ext_def_list"); }
  ;

ext_def_list
  : ext_def_list ext_def  { reduce("ext_def_list->ext_def_list ext_def"); }
  | %empty                { reduce("ext_def_list->epsilon"); }
  ;

ext_def
  : type_specifier pointers ID ';'                        { reduce("ext_def->type_specifier pointers ID \';\'"); } /* global variable */
  | type_specifier pointers ID '[' INTEGER_CONST ']' ';'  { reduce("ext_def->type_specifier pointers ID \'[\' INTEGER_CONST \']\' \';\'"); }
  | struct_specifier ';'                                  { reduce("ext_def->struct_specifier \';\'"); }
  | func_decl compound_stmt                               { reduce("ext_def->func_decl compound_stmt"); }
  ;

type_specifier
  : TYPE              { reduce("type_specifier->TYPE"); }
  | struct_specifier  { reduce("type_specifier->struct_specifier"); }
  ;

struct_specifier
  : STRUCT ID '{' def_list '}'  { reduce("struct_specifier->STRUCT ID \'{\' def_list \'}\'"); }
  | STRUCT ID                   { reduce("struct_specifier->STRUCT ID"); }
  ;

func_decl
  : type_specifier pointers ID '(' ')'            { reduce("func_decl->type_specifier pointers ID \'(\' \')\'"); }
  | type_specifier pointers ID '(' param_list ')' { reduce("func_decl->type_specifier pointers ID \'(\' param_list \')\'"); }
  ;

pointers
  : '*'     { reduce("pointers->\'*\'"); }
  | %empty  { reduce("pointers->epsilon"); }
  ;

param_list
  : param_decl                  { reduce("param_list->param_decl"); }
  | param_list ',' param_decl   { reduce("param_list->param_list \',\' param_decl"); }
  ;

param_decl
  : type_specifier pointers ID                        { reduce("param_decl->type_specifier pointers ID"); }
  | type_specifier pointers ID '[' INTEGER_CONST ']'  { reduce("param_decl->type_specifier pointers ID \'[\' INTEGER_CONST \']\'"); }
  ;

def_list
  : def_list def  { reduce("def_list->def_list def"); }
  | %empty        { reduce("def_list->epsilon"); }
  ;

def
  : type_specifier pointers ID ';'                        { reduce("def->type_specifier pointers ID \';\'"); }
  | type_specifier pointers ID '[' INTEGER_CONST ']' ';'  { reduce("def->type_specifier pointers ID \'[\' INTEGER_CONST \']\' \';\'"); }
  ;

compound_stmt
  : '{' def_list stmt_list '}' { reduce("compound_stmt->\'{\' def_list stmt_list \'}\'"); }
  ;

stmt_list
  : stmt_list stmt  { reduce("stmt_list->stmt_list stmt"); }
  | %empty          { reduce("stmt_list->epsilon"); }
  ;

stmt
  : expr ';'                                        { reduce("stmt->expr \';\'"); }
  | compound_stmt                                   { reduce("stmt->compound_stmt"); }
  | RETURN expr ';'                                 { reduce("stmt->RETURN expr \';\'"); }
  | ';'                                             { reduce("stmt->\';\'"); }
  | IF '(' expr ')' stmt %prec '('                  { reduce("stmt->IF \'(\' expr \')\' stmt"); }
  | IF '(' expr ')' stmt ELSE stmt                  { reduce("stmt->IF \'(\' expr \')\' stmt ELSE stmt"); }
  | WHILE '(' expr ')' stmt                         { reduce("stmt->WHILE \'(\' expr \')\' stmt"); }
  | FOR '(' expr_e ';' expr_e ';' expr_e ')' stmt   { reduce("stmt->FOR \'(\' expr_e \';\' expr_e \';\' expr_e \')\' stmt"); }
  | BREAK ';'                                       { reduce("stmt->BREAK \';\'"); }
  | CONTINUE ';'                                    { reduce("stmt->CONTINUE \';\'"); }
  ;

expr_e
  : expr    { reduce("expr_e->expr"); }
  | %empty  { reduce("expr_e->epsilon"); }
  ;

expr
  : unary '=' expr  { reduce("expr->unary \'=\' expr"); }
  | binary          { reduce("expr->binary"); }
  ;

binary
  : binary RELOP binary       { reduce("binary->binary RELOP binary"); }
  | binary EQUOP binary       { reduce("binary->binary EQUOP binary"); }
  | binary '+' binary         { reduce("binary->binary \'+\' binary"); }
  | binary '-' binary         { reduce("binary->binary \'-\' binary"); }
  | binary '*' binary         { reduce("binary->binary \'*\' binary"); }
  | binary '/' binary         { reduce("binary->binary \'/\' binary"); }
  | binary '%' binary         { reduce("binary->binary \'%\' binary"); }
  | unary %prec '='           { reduce("binary->unary"); }
  | binary LOGICAL_AND binary { reduce("binary->binary LOGICAL_AND binary"); }
  | binary LOGICAL_OR binary  { reduce("binary->binary LOGICAL_OR binary"); }
  ;

unary
  : '(' expr ')'          { reduce("unary->\'(\' expr \')\'"); }
  | INTEGER_CONST         { reduce("unary->INTEGER_CONST"); }
  | CHAR_CONST            { reduce("unary->CHAR_CONST"); }
  | STRING                { reduce("unary->STRING"); }
  | ID                    { reduce("unary->ID"); }
  | '-' unary %prec '!'   { reduce("unary->\'-\' unary"); }
  | '!' unary             { reduce("unary->\'!\' unary"); }
  | unary INCOP %prec '.' { reduce("unary->unary INCOP"); }
  | unary DECOP %prec '.' { reduce("unary->unary DECOP"); }
  | INCOP unary           { reduce("unary->INCOP unary"); }
  | DECOP unary           { reduce("unary->DECOP unary"); }
  | '&' unary             { reduce("unary->\'&\' unary"); }
  | '*' unary %prec '!'   { reduce("unary->\'*\' unary"); }
  | unary '[' expr ']'    { reduce("unary->unary \'[\' expr \']\'"); }
  | unary '.' ID          { reduce("unary->unary \'.\' ID"); }
  | unary STRUCTOP ID     { reduce("unary->unary STRUCTOP ID"); }
  | unary '(' args ')'    { reduce("unary->unary \'(\' args \')\'"); }
  | unary '(' ')'         { reduce("unary->unary \'(\' \')\'"); }
  | SYM_NULL              { reduce("unary->SYM_NULL"); }
  ;

args
  : expr          { reduce("args->expr"); }
  | args ',' expr { reduce("args->args \',\' expr"); }
  ;

%%

/* Epilogue section */

int yyerror (char* s) {
  fprintf (stderr, "yyerror: %s at line %d, token '%s'\n", s, get_lineno(), yyget_text());
}

void reduce(char* s) {
  printf("%s\n", s);
}

// Print the preamble of error message.
void error_preamble(void) {
  // TODO
  // Implement this function using get_lineno() function.
  printf("%s:%d: error: ", "filename", 1234);
}

void error_undeclared(void) {
  error_preamble();
  printf("use of undeclared identifier\n");
}

void error_redeclaration(void) {
  error_preamble();
  printf("redeclaration\n");
}

void error_assignable(void) {
  error_preamble();
  printf("lvalue is not assignable\n");
}

void error_incompatible(void) {
  error_preamble();
  printf("incompatible types for assignment operation\n");
}

void error_null(void) {
  error_preamble();
  printf("cannot assign 'NULL' to non-pointer type\n");
}

void error_binary(void) {
  error_preamble();
  printf("invalid operands to binary expression\n");
}

void error_unary(void) {
  error_preamble();
  printf("invalid argument type to unary expression\n");
}

void error_comparable(void) {
  error_preamble();
  printf("types are not comparable in binary expression\n");
}

void error_indirection(void) {
  error_preamble();
  printf("indirection requires pointer operand\n");
}

void error_addressof(void) {
  error_preamble();
  printf("cannot take the address of an rvalue\n");
}

void error_struct(void) {
  error_preamble();
  printf("member reference base type is not a struct\n");
}

void error_strurctp(void){
  error_preamble();
  printf("member reference base type is not a struct pointer\n");
}

void error_member(void) {
  error_preamble();
  printf("no such member in struct\n");
}

void error_array(void) {
  error_preamble();
  printf("subscripted value is not an array\n");
}

void error_subscript(void) {
  error_preamble();
  printf("array subscript is not an integer\n");
}

void error_incomplete(void) {
  error_preamble();
  printf("incomplete type\n");
}

void error_return(void) {
  error_preamble();
  printf("incompatible return types\n");
}

void error_function(void) {
  error_preamble();
  printf("not a function\n");
}

void error_arguments(void) {
  error_preamble();
  printf("incompatible arguments in function call\n");
}