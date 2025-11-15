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
char* yyget_text();
void  reduce(char* s);
%}

/* Bison declarations section */

/* yylval types */
%union {
  int         intval;
  char        charval;
  char        *stringval;
  struct id   *idptr;
  struct decl *declptr;
  struct ste  *steptr;
}

/* Tokens and Types */
%type<declptr>    type_specifier struct_specifier func_decl binary unary expr
%token<declptr>   TYPE
%token            STRUCT SYM_NULL RETURN IF ELSE WHILE FOR BREAK CONTINUE 
%token            LOGICAL_OR LOGICAL_AND RELOP EQUOP INCOP DECOP STRUCTOP
%token<idptr>     ID
%token<charval>   CHAR_CONST
%token<stringval> STRING
%token<intval>    INTEGER_CONST

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
    declare($2, make_var($1));
  }
  | type_specifier ID '[' INTEGER_CONST ']' ';' {
    declare($2, make_const(make_arr($4, $1)));
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
  | TYPE '*'              { $$ = make_ptr(NULL); }
  | struct_specifier      { $$ = $1; }
  | struct_specifier '*'  { $$ = make_strptr($1, NULL); }
  ;

struct_specifier
  : STRUCT ID '{' { push_scope(); } def_list { 
    $<declptr>$ = make_str(pop_scope(0));
    declare($2, $<declptr>$); 
  } '}' { $$ = $<declptr>6; }
  | STRUCT ID { 
    $<declptr>$ = make_str(NULL); 
    declare($2, $<declptr>$);   
  } { $$ = $<declptr>3; }
  ;

func_decl
  : type_specifier ID '(' ')' {
    $<declptr>$ = make_func(NULL, $1);
    declare($2, $<declptr>$);
  }
  | type_specifier ID '(' { push_scope(); } param_list ')' { 
    $<declptr>$ = make_func(pop_scope(0), $1);
    declare($2, $<declptr>$);
  }
  ;

param_list
  : param_decl                  {}
  | param_list ',' param_decl   {}
  ;

param_decl
  : type_specifier ID { declare($2, make_var($1)); }
  | type_specifier ID '[' INTEGER_CONST ']' { 
    declare($2, make_const(make_arr($4, $1)));
  }
  ;

def_list
  : def_list def  {}
  | %empty        {}
  ;

def
  : type_specifier ID ';' { 
    declare($2, make_var($1)); 
  }
  | type_specifier ID '[' INTEGER_CONST ']' ';' { 
    declare($2, make_const(make_arr($4, $1))); 
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
  | unary %prec '='           { $$ = $1->type; }
  | binary LOGICAL_AND binary {}
  | binary LOGICAL_OR binary  {}
  ;

unary
  : '(' expr ')'          {}
  | INTEGER_CONST         { $$ = make_const(int_tdecl); $$->int_value = $1; }
  | CHAR_CONST            { $$ = make_const(char_tdecl); $$->char_value = $1; }
  | STRING                {} 
  | ID                    { $$ = lookup($1); }
  | '-' unary %prec '!'   {}
  | '!' unary             {}
  | unary INCOP %prec '.' {}
  | unary DECOP %prec '.' {}
  | INCOP unary           {}
  | DECOP unary           {}
  | '&' unary             {}
  | '*' unary %prec '!'   {}
  | unary '[' expr ']'    { $$ = accarr($1, $3); }
  | unary '.' ID          { $$ = accstruct($1, $3); }
  | unary STRUCTOP ID     {}
  | unary '(' args ')'    {}
  | unary '(' ')'         {}
  | SYM_NULL              { $$ = make_null(); }
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
