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
int elseflag = 0;
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
%type<intval>     if_expr
%token<declptr>   TYPE
%token            STRUCT SYM_NULL RETURN IF ELSE WHILE FOR BREAK CONTINUE 
%token            LOGICAL_OR LOGICAL_AND INCOP DECOP STRUCTOP
%token<idptr>     ID
%token<charval>   CHAR_CONST
%token<stringval> STRING
%token<intval>    INTEGER_CONST RELOP EQUOP

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
  : STRUCT ID '{' { 
    push_scope(); 
  } def_list '}' { 
    $$ = make_str(pop_scope(0));
    declare_glob($2, $$);
    local_offset = 0;
  }
  | STRUCT ID { $$ = lookup($2); }
  ;

func_decl
  : type_specifier ID '(' {
    gen_label($2->name, LABEL_PLAIN);
    curfunc = $2;
    $<declptr>$ = make_func($1, $2);
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
    $<declptr>$ = make_func($1, $2);
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
    declare($2, make_var($1)); 
    local_offset += $1->size;
    param_offset += $1->size;
  }
  | type_specifier ID '[' INTEGER_CONST ']' { 
    declare($2, make_const(make_arr($4, $1)));
    local_offset += $4 * $1->size;
    param_offset += $4 * $1->size;
  }
  ;

def_list
  : def_list def  {}
  | %empty        {}
  ;

def
  : type_specifier ID ';' { 
    declare($2, make_var($1));
    local_offset += $1->size;
  }
  | type_specifier ID '[' INTEGER_CONST ']' ';' { 
    declare($2, make_const(make_arr($4, $1))); 
    local_offset += $4 * $1->size;
  }
  ;

compound_stmt
  : '{' { push_scope(); } def_list stmt_list '}' { pop_scope(0); }
  ;

compound_func_stmt
  : '{' def_list {
    if (local_offset > param_offset) shift_sp(local_offset-param_offset);
    local_offset = 0;
    param_offset = 0;
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
  | RETURN { prepare_return(); } expr ';' { assign(); jump(curfunc->name, LABEL_FINAL, 0, -1); }
  | ';'                                             {}
  | if_expr stmt %prec '(' { make_label_offset($<intval>1); }
  | if_expr stmt ELSE { jump(NULL, LABEL_PLAIN, 0, $<intval>1+1); make_label_offset($<intval>1); } stmt { make_label_offset($<intval>1+1); }            
  | WHILE { 
    $<intval>$ = label_offset;
    push_labels(label_offset, label_offset+1);
    make_label(); 
  } '(' expr { 
    branch(FALSE, NULL, 0, label_offset++); 
  } ')' stmt { 
    jump(NULL, 0, 0, $<intval>2); 
    make_label_offset($<intval>2+1);
    pop_cont();
    pop_break();
  }
  | FOR '(' expr_e {
    $<intval>$ = label_offset;
    push_labels(label_offset+1, label_offset+3);
    make_label(); 
  } ';' expr_e {
    branch(FALSE, NULL, 0, $<intval>4 + 3); 
    jump(NULL, 0, 0, $<intval>4 + 2); 
    make_label(); 
  } ';' expr_e ')' { 
    jump(NULL, 0, 0, $<intval>4); 
    make_label(); 
    label_offset++;
  } stmt { 
    jump(NULL, 0, 0, $<intval>4+1); 
    make_label_offset($<intval>4+3);
    pop_cont();
    pop_break();
  }
  | BREAK ';' { jump(NULL, 0, 0, top_break()); pop_break(); pop_cont(); }
  | CONTINUE ';' { jump(NULL, 0, 0, top_cont()); }
  ;

if_expr
  : IF '(' expr ')' { branch(FALSE, NULL, 0, label_offset); $$ = label_offset; label_offset += 2; }

expr_e
  : expr    {}
  | %empty  {}
  ;

expr
  : unary '=' {
    if ($1->type->typeclass == TYPE_STRUCT){
      $<idptr>$ = cur_strid;
      str_assign_prologue($1->type);
    }
    else {
      push_reg("sp");
      fetch(NULL, 0);
    }
  } expr {
    if ($4 == int_tdecl) $$ = int_tdecl_const;
    else if ($4 == char_tdecl) $$ = char_tdecl_const;
    else $$ = $4; 
    if ($1->type->typeclass == TYPE_STRUCT){
      $<idptr>$ = cur_strid; 
      shift_sp(-1);
      str_assign(cur_strid);
    }
    else {
      assign();
      fetch(NULL, 0);
      shift_sp(-1);
    }
  }
  | binary { $$ = $1; }
  ;

binary
  : binary RELOP binary { $$ = int_tdecl_const; gen_relop($2); }
  | binary EQUOP binary { $$ = int_tdecl_const; gen_equop($2); }
  | binary '+' binary { $$ = int_tdecl_const; gen_add(); } 
  | binary '-' binary { $$ = int_tdecl_const; gen_sub(); } 
  | binary '*' binary { $$ = int_tdecl_const; gen_mul(); } 
  | binary '/' binary { $$ = int_tdecl_const; gen_div(); } 
  | binary '%' binary { $$ = int_tdecl_const; gen_mod(); } 
  | unary %prec '=' { $$ = $1->type; fetch($1, 1); }
  | binary LOGICAL_AND binary { $$ = int_tdecl_const; gen_and(); }
  | binary LOGICAL_OR binary { $$ = int_tdecl_const; gen_or(); }
  ;

unary
  : '(' expr ')'          { $$ = ($2->isconst)? make_const($2) : make_var($2); }
  | INTEGER_CONST         { $$ = make_const(int_tdecl_const); $$->intval = $1; push_const_int($1); }
  | CHAR_CONST            { $$ = make_const(char_tdecl_const); $$->charval = $1; push_const_int($1); }
  | STRING                { $$ = make_const(string_tdecl); $$->stringval = $1; gen_string($1); } 
  | ID                    { $$ = lookup($1); load_var($1); }
  | '-' unary %prec '!'   { $$ = make_const($2->type); fetch($2, 1); gen_negate(); }
  | '!' unary             { $$ = make_const($2->type); fetch($2, 1); gen_not(); }
  | unary INCOP %prec '.' { $$ = make_const($1->type); gen_incdec(INC_POST); }
  | unary DECOP %prec '.' { $$ = make_const($1->type); gen_incdec(DEC_POST); }
  | INCOP unary           { $$ = make_const($2->type); gen_incdec(INC_PRE); }
  | DECOP unary           { $$ = make_const($2->type); gen_incdec(DEC_PRE); }
  | '&' unary             { $$ = make_const(make_ptr($2->type)); }
  | '*' unary %prec '!'   { $$ = make_var($2->type->ptrto); fetch(NULL, 0); $$->deref = $2->deref; }
  | unary '[' expr ']'    { $$ = access_arr($1, $3); }
  | unary '.' ID          { $$ = access_struct($1, $3); }
  | unary STRUCTOP ID     { $$ = access_structp($1, $3); }
  | unary '(' { func_prologue($1); } args ')' { $$ = access_function($1, $4); func_call($1); num_args = 0; $$->deref = 1; } 
  | unary '(' { func_prologue($1); } ')' { $$ = access_function($1, NULL); func_call($1); $$->deref = 1; }
  | SYM_NULL              { $$ = make_const(make_ptr(null_tdecl)); push_const_int(0); }
  ;

args
  : expr          { $$ = make_var($1); num_args = 1; }
  | args ',' expr { $$ = make_arg($3, $1); num_args++; }
  ;

%%

/* Epilogue section */

int yyerror (char* s) {
  fprintf (stderr, "yyerror: %s at line %d, token '%s'\n", s, get_lineno(), yyget_text());
}

void reduce(char* s) {
  printf("%s\n", s);
}
