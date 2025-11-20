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
    if (!check_redeclaration($2, TRUE)) {
      $<declptr>$ = make_str(NULL);
      declare_glob($2, $<declptr>$);
    }
    else $<declptr>$ = pass_tdecl;
  } '{' { 
    push_scope(); 
  } def_list '}' { 
    if ($<declptr>3 == pass_tdecl) pop_scope(0);
    else $<declptr>3->fields = pop_scope(0);
    $$ = $<declptr>3;
  }
  | STRUCT ID { $$ = (!check_incomplete($2))? lookup($2) : pass_tdecl; }
  ;

func_decl
  : type_specifier ID '(' {
    $<declptr>$ = make_func($1);
    if (!check_redeclaration($2, TRUE)) declare($2, $<declptr>$);
    push_scope();
    declare(returnid, make_const($1));
  } ')' {
    $<declptr>4->formals = pop_scope(0);
    $$ = $<declptr>4;
  }
  | type_specifier ID '(' { 
    $<declptr>$ = make_func($1);
    if (!check_redeclaration($2, TRUE)) declare($2, $<declptr>$);
    push_scope(); 
    declare(returnid, make_const($1));
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
    if (!check_redeclaration($2, FALSE)) declare($2, make_var($1)); }
  | type_specifier ID '[' INTEGER_CONST ']' { 
    if (!check_redeclaration($2, FALSE)) declare($2, make_const(make_arr($4, $1)));
  }
  ;

def_list
  : def_list def  {}
  | %empty        {}
  ;

def
  : type_specifier ID ';' { 
    if (!check_redeclaration($2, FALSE)) declare($2, make_var($1));
  }
  | type_specifier ID '[' INTEGER_CONST ']' ';' { 
    if (!check_redeclaration($2, FALSE)) declare($2, make_const(make_arr($4, $1))); 
  }
  ;

compound_stmt
  : '{' { push_scope(); } def_list stmt_list '}' { pop_scope(0); }
  ;

compound_func_stmt
  : '{' def_list stmt_list '}'
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
    if (check_assignable($1) || check_null($1, $3) || check_incompatible($1, $3)) $$ = pass_tdecl;
    else $$ = $3;
  }
  | binary { $$ = $1; }
  ;

binary
  : binary RELOP binary {
    if (check_comparable($1, $3, (TYPE_INT | TYPE_CHAR))) $$ = pass_tdecl;
    else $$ = int_tdecl;
  }
  | binary EQUOP binary {
    if (check_comparable($1, $3, (TYPE_INT | TYPE_CHAR | TYPE_PTR))) $$ = pass_tdecl;
    else $$ = int_tdecl;
  }
  | binary '+' binary { 
    if (check_binary($1, $3, TYPE_INT)) $$ = pass_tdecl;
    else $$ = $1;
  }
  | binary '-' binary { 
    if (check_binary($1, $3, TYPE_INT)) $$ = pass_tdecl;
    else $$ = $1;
  } 
  | binary '*' binary { 
    if (check_binary($1, $3, TYPE_INT)) $$ = pass_tdecl;
    else $$ = $1;
  } 
  | binary '/' binary { 
    if (check_binary($1, $3, TYPE_INT)) $$ = pass_tdecl;
    else $$ = $1;
  } 
  | binary '%' binary { 
    if (check_binary($1, $3, TYPE_INT)) $$ = pass_tdecl;
    else $$ = $1;
  } 
  | unary %prec '=' { $$ = $1->type; }
  | binary LOGICAL_AND binary { 
    if (check_binary($1, $3, TYPE_INT)) $$ = pass_tdecl;
    else $$ = $1;
  }
  | binary LOGICAL_OR binary { 
    if (check_binary($1, $3, TYPE_INT)) $$ = pass_tdecl;
    else $$ = $1;
  }
  ;

unary
  : '(' expr ')'          { $$ = make_const($2); }
  | INTEGER_CONST         { $$ = make_const(int_tdecl); $$->intval = $1; }
  | CHAR_CONST            { $$ = make_const(char_tdecl); $$->charval = $1; }
  | STRING                { $$ = make_const(string_tdecl); $$->stringval = $1; } 
  | ID                    { $$ = (!check_undeclared($1))? lookup($1) : make_const(pass_tdecl); }
  | '-' unary %prec '!'   { $$ = (!check_unary($2, TYPE_INT))? $2 : make_const(pass_tdecl); }
  | '!' unary             { $$ = (!check_unary($2, TYPE_INT))? $2 : make_const(pass_tdecl); }
  | unary INCOP %prec '.' { $$ = (!check_unary($1, TYPE_INT | TYPE_CHAR))? $1 : make_const(pass_tdecl); }
  | unary DECOP %prec '.' { $$ = (!check_unary($1, TYPE_INT | TYPE_CHAR))? $1 : make_const(pass_tdecl); }
  | INCOP unary           { $$ = (!check_unary($2, TYPE_INT | TYPE_CHAR))? $2 : make_const(pass_tdecl); }
  | DECOP unary           { $$ = (!check_unary($2, TYPE_INT | TYPE_CHAR))? $2 : make_const(pass_tdecl); }
  | '&' unary             { $$ = (!check_addressof($2))? make_const(make_ptr($2->type)) : make_const(pass_tdecl); }
  | '*' unary %prec '!'   { $$ = (!check_indirection($2))? make_var($2->type->ptrto) : make_var(pass_tdecl); }
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
