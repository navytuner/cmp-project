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
%type<declptr>    type_specifier struct_specifier func_decl binary unary expr args
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
  : ext_def_list { gen_globlabel(); }
  ;

ext_def_list
  : ext_def_list ext_def  {}
  | %empty                {}
  ;

/* global variables, struct declaration, function declaration */
ext_def
  : type_specifier ID ';' {
    declare_glob($2, make_var($1));
  }
  | type_specifier ID '[' INTEGER_CONST ']' ';' {
    declare_glob($2, make_const(make_arr($4, $1)));
  }
  | struct_specifier ';'     {}
  | func_decl {
    push_scope();
    insert_ste_list($1->formals); 
  } compound_func_stmt { 
    pop_scope(0); 
  }
  ;

type_specifier
  : TYPE                  { $$ = $1; }
  | TYPE '*'              { $$ = make_ptr($1); }
  | struct_specifier      { $$ = $1; }
  | struct_specifier '*'  { $$ = make_ptr($1); }
  ;

struct_specifier
  : STRUCT ID {
    $<declptr>$ = make_str(NULL);
  } '{' { 
    push_scope(); 
  } def_list '}' { 
    $<declptr>3->fields = pop_scope(0);
    declare_glob($2, $<declptr>3);
    $$ = $<declptr>3;
  }
  | STRUCT ID { $$ = lookup($2); }
  ;

func_decl
  : type_specifier ID '(' {
    gen_label($2->name, LABEL_PLAIN);
    curfunc = $2;
    $<declptr>$ = make_func($1);
    declare($2, $<declptr>$);
    push_scope();
    declare(returnid, make_var($1));
  } ')' {
    $<declptr>4->formals = pop_scope(0);
    $$ = $<declptr>4;
  }
  | type_specifier ID '(' { 
    gen_label($2->name, LABEL_PLAIN);
    curfunc = $2;
    $<declptr>$ = make_func($1);
    declare($2, $<declptr>$);
    push_scope(); 
    declare(returnid, make_var($1));
  } param_list ')' { 
    $<declptr>4->formals = pop_scope(0);
    $$ = $<declptr>4;
  }
  ;

param_list
  : param_decl                  {}
  | param_list ',' param_decl   {}
  ;

param_decl
  : type_specifier ID { 
    declare($2, make_var($1)); }
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
  : '{' { push_scope(); } def_list stmt_list '}' { pop_scope(0); }
  ;

compound_func_stmt
  : '{' def_list {
    gen_label(curfunc->name, LABEL_START);
  } stmt_list '}' {
    func_epilogue(curfunc->name);
  }
  ;

stmt_list
  : stmt_list stmt  {}
  | %empty          {}
  ;

stmt
  : expr ';'                                        {}
  | compound_stmt                                   {}
  | RETURN expr ';'                                 { check_return($2); }
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
  : unary '=' expr {
    if ($3 == int_tdecl) $$ = int_tdecl_const;
    else if ($3 == char_tdecl) $$ = char_tdecl_const;
    else $$ = $3; 
  }
  | binary { $$ = $1; }
  ;

binary
  : binary RELOP binary { $$ = int_tdecl_const; }
  | binary EQUOP binary { $$ = int_tdecl_const; }
  | binary '+' binary { $$ = int_tdecl_const; } 
  | binary '-' binary { $$ = int_tdecl_const; } 
  | binary '*' binary { $$ = int_tdecl_const; } 
  | binary '/' binary { $$ = int_tdecl_const; } 
  | binary '%' binary { $$ = int_tdecl_const; } 
  | unary %prec '=' { $$ = $1->type; }
  | binary LOGICAL_AND binary { $$ = int_tdecl_const; }
  | binary LOGICAL_OR binary { $$ = int_tdecl_const; }
  ;

unary
  : '(' expr ')'          { $$ = ($2->isconst)? make_const($2) : make_var($2); }
  | INTEGER_CONST         { $$ = make_const(int_tdecl_const); $$->intval = $1; }
  | CHAR_CONST            { $$ = make_const(char_tdecl_const); $$->charval = $1; }
  | STRING                { $$ = make_const(string_tdecl); $$->stringval = $1; gen_string($1); } 
  | ID                    { $$ = lookup($1); }
  | '-' unary %prec '!'   { $$ = make_const($2->type); }
  | '!' unary             { $$ = make_const($2->type); }
  | unary INCOP %prec '.' { $$ = make_const($1->type); }
  | unary DECOP %prec '.' { $$ = make_const($1->type); }
  | INCOP unary           { $$ = make_const($2->type); }
  | DECOP unary           { $$ = make_const($2->type); }
  | '&' unary             { $$ = make_const(make_ptr($2->type)); }
  | '*' unary %prec '!'   { $$ = make_var($2->type->ptrto); }
  | unary '[' expr ']'    { $$ = access_arr($1, $3); }
  | unary '.' ID          { $$ = access_struct($1, $3); }
  | unary STRUCTOP ID     { $$ = access_structp($1, $3); }
  | unary '(' args ')'    { $$ = access_function($1, $3); } 
  | unary '(' ')'         { $$ = access_function($1, NULL); }
  | SYM_NULL              { $$ = make_const(make_ptr(null_tdecl)); }
  ;

args
  : expr          { $$ = make_var($1); }
  | args ',' expr { $$ = make_arg($3, $1); }
  ;

%%

/* Epilogue section */

int yyerror (char* s) {
  fprintf (stderr, "yyerror: %s at line %d, token '%s'\n", s, get_lineno(), yyget_text());
}

void reduce(char* s) {
  printf("%s\n", s);
}
