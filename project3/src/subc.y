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
char* get_filename();
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
%type<declptr>    type_specifier struct_specifier func_decl
%token<declptr>   TYPE
%token            STRUCT SYM_NULL RETURN IF ELSE WHILE FOR BREAK CONTINUE 
%token            LOGICAL_OR LOGICAL_AND RELOP EQUOP INCOP DECOP STRUCTOP
%token<idptr>     ID
%token<stringval> CHAR_CONST STRING
%token<intval>    INTEGER_CONST
%token<floatval>  FLOAT_CONST

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
  : ext_def_list {}
  ;

ext_def_list
  : ext_def_list ext_def  {}
  | %empty                {}
  ;

/* global variables, struct declaration, function declaration */
ext_def
  : type_specifier ID ';' {
    declare($2, make_vardecl($1));
  }
  | type_specifier ID '[' INTEGER_CONST ']' ';' {
    declare($2, make_constdecl(make_arrdecl($4, $1)));
  }
  | struct_specifier ';'     {}
  | func_decl {
    push_scope();
    insert_list($1->formals); 
  } compound_stmt { 
    pop_scope(1); 
  }
  ;

type_specifier
  : TYPE                  { $$ = $1; }
  | TYPE '*'              { $$ = make_ptrdecl(NULL); }
  | struct_specifier      { $$ = $1; }
  | struct_specifier '*'  { $$ = make_ptrdecl(NULL); }
  ;

struct_specifier
  : STRUCT ID '{' { push_scope(); } def_list { 
    $<declptr>$ = make_structdecl(pop_scope(0));
    declare($2, $<declptr>$); 
  } '}' { $$ = $<declptr>6; }
  | STRUCT ID { 
    $<declptr>$ = make_structdecl(NULL); 
    declare($2, $<declptr>$);   
  } { $$ = $<declptr>3; }
  ;

func_decl
  : type_specifier ID '(' ')' {
    $<declptr>$ = make_funcdecl(NULL, $1);
    declare($2, $<declptr>$);
  }
  | type_specifier ID '(' { push_scope(); } param_list ')' { 
    $<declptr>$ = make_funcdecl(pop_scope(0), $1);
    declare($2, $<declptr>$);
  }
  ;

param_list
  : param_decl                  {}
  | param_list ',' param_decl   {}
  ;

param_decl
  : type_specifier ID { declare($2, make_vardecl($1)); }
  | type_specifier ID '[' INTEGER_CONST ']' { 
    declare($2, make_constdecl(make_arrdecl($4, $1)));
  }
  ;

def_list
  : def_list def  {}
  | %empty        {}
  ;

def
  : type_specifier ID ';' { 
    declare($2, make_vardecl($1)); 
  }
  | type_specifier ID '[' INTEGER_CONST ']' ';' { 
    declare($2, make_constdecl(make_arrdecl($4, $1))); 
  }
  ;

compound_stmt
  : '{' def_list stmt_list '}' {}
  ;

stmt_list
  : stmt_list stmt  {}
  | %empty          {}
  ;

stmt
  : expr ';'                                        {}
  | compound_stmt                                   {}
  | RETURN expr ';'                                 {}
  | ';'                                             {}
  | IF '(' expr ')' stmt %prec '('                  {}
  | IF '(' expr ')' stmt ELSE stmt                  {}
  | WHILE '(' expr ')' stmt                         {}
  | FOR '(' expr_e ';' expr_e ';' expr_e ')' stmt   {}
  | BREAK ';'                                       {}
  | CONTINUE ';'                                    {}
  ;

expr_e
  : expr    {}
  | %empty  {}
  ;

expr
  : unary '=' expr  {}
  | binary          {}
  ;

binary
  : binary RELOP binary       {}
  | binary EQUOP binary       {}
  | binary '+' binary         {}
  | binary '-' binary         {}
  | binary '*' binary         {}
  | binary '/' binary         {}
  | binary '%' binary         {}
  | unary %prec '='           {}
  | binary LOGICAL_AND binary {}
  | binary LOGICAL_OR binary  {}
  ;

unary
  : '(' expr ')'          {}
  | INTEGER_CONST         {}
  | FLOAT_CONST           {}
  | CHAR_CONST            {}
  | STRING                {}
  | ID                    {}
  | '-' unary %prec '!'   {}
  | '!' unary             {}
  | unary INCOP %prec '.' {}
  | unary DECOP %prec '.' {}
  | INCOP unary           {}
  | DECOP unary           {}
  | '&' unary             {}
  | '*' unary %prec '!'   {}
  | unary '[' expr ']'    {}
  | unary '.' ID          {}
  | unary STRUCTOP ID     {}
  | unary '(' args ')'    {}
  | unary '(' ')'         {}
  | SYM_NULL              {}
  ;

args
  : expr          {}
  | args ',' expr {}
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
  printf("%s:%d: error: ", get_filename(), get_lineno());
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