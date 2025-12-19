/*
 * File Name    : subc.h
 * Description  : A header file for the subc program.
 *
 * Course       : Introduction to Compilers
 * Dept. of Electrical and Computer Engineering, Seoul National University
 */

#ifndef __SUBC_H__
#define __SUBC_H__

#include <stdio.h>
#include <string.h>
#include <strings.h>

/* TRUE, FALSE */
#define TRUE 1
#define FALSE 0

/* SCOPE */
#define SCOPE_INITSZ 256
#define SCOPE_GLOB 1
#define SCOPE_FUNC 2

/* DECL CLASS*/
#define DECL_VAR 0
#define DECL_CONST 1
#define DECL_FUNC 2
#define DECL_TYPE 3
#define DECL_NULL 4

/* TYPE CLASSS */
#define TYPE_INT 1
#define TYPE_CHAR 2
#define TYPE_STRING 3
#define TYPE_PTR 4
#define TYPE_ARRAY 5
#define TYPE_STRUCT 6
#define TYPE_PASS 7
#define TYPE_NULL 8

/* RELOP, EQUOP specifier */
#define OP_EQUAL 0
#define OP_NOT_EQUAL 1
#define OP_GREATER 2
#define OP_GREATER_EQUAL 3
#define OP_LESS 4
#define OP_LESS_EQUAL 5

/* label mode */
#define LABEL_PLAIN 0
#define LABEL_START 1
#define LABEL_FINAL 2
#define LABEL_END 3

/* inc/dec mode */
#define INC_PRE 0
#define INC_POST 1
#define DEC_PRE 2
#define DEC_POST 3

typedef struct id {
  int tokenType;
  char *name;
  int count;
} id;

typedef struct ste {
  struct id *id;
  struct decl *decl;
  struct ste *prev;
} ste_t;

typedef struct decl {
  int declclass;     // VAR, CONST, FUNC, TYPE
  struct decl *type; // VAR, CONST

  int intval;      // CONST: integer value
  char charval;    // CONST: char value
  char *stringval; // CONST: string value

  id *funcid;              // FUNC: built-in function id
  struct ste *formals;     // FUNC: formal argument list
  struct decl *returntype; // FUNC: return TYPE decl
  int num_args;

  int typeclass;           // TYPE: type class(INT, array, ptr)
  int isconst;             // TYPE: 1(came from CONST), 0(came from var/func)
  struct decl *elementvar; // TYPE(array): point to element VAR decl
  int len_arr;             // TYPE(array): # of elements
  struct ste *fields;      // TYPE(struct): point to field list
  struct decl *ptrto;      // TYPE(pointer): pointer type

  int size;           // ALL: size in bytes
  int offset;         // VAR: offset from its base pointer
  int deref;          // VAR: dereferenced variable (*a)
  struct ste **scope; // VAR: scope when VAR declared
  int glob;           // isglob
  struct decl *next;  // for list_of_variables declarations
} decl_t;

extern ste_t **scope;
extern int top;
extern decl_t *int_tdecl;
extern decl_t *int_tdecl_const;
extern decl_t *char_tdecl;
extern decl_t *char_tdecl_const;
extern decl_t *string_tdecl;
extern decl_t *pass_tdecl;
extern decl_t *null_tdecl;
extern id *returnid;
extern id *curfunc;
extern id *write_int_id;
extern id *write_char_id;
extern id *write_string_id;
extern int errflag;
extern int glob_offset;
extern int local_offset;
extern int param_offset;
extern int str_offset;
extern int label_offset;
extern int num_args;
extern id *cur_strid;
extern int func_flag;

int get_lineno();
char *get_filename();

/* gen.c */
// generate codes
void init_gen(void);
void str_ret(id *idptr);
void str_passarg(id *idptr);
void str_assign_prologue(decl_t *strdecl);
void str_assign(decl_t *strdecl);
void push_idstk(id *idptr);
id *op2_idstk(void);
id *op1_idstk(void);
void pop_idstk(void);
void assign_struct(ste_t *tdecl1, ste_t *tdecl2);
void push_labels(int contlbl, int breaklbl);
int pop_cont(void);
int pop_break(void);
int top_cont(void);
int top_break(void);
void load_var(id *idptr);
void func_prologue(decl_t *funcdecl);
void func_call(decl_t *funcdecl);
void func_epilogue(char *func_name);
void prepare_return(void);
void gen_label(char *label, int flag);
void make_label(void);
void make_label_offset(int offset);
void gen_string(char *str);
void gen_globlabel(void);
void push_const_int(int n);
void push_const_label(char *label);
void push_const_label_offset(char *label, int offset);
void push_reg(char *reg);
void pop_reg(char *reg);
void shift_sp(int n);
void gen_negate(void);
void gen_not(void);
void gen_abs(void);
void gen_add(void);
void gen_sub(void);
void gen_mul(void);
void gen_div(void);
void gen_mod(void);
void gen_and(void);
void gen_or(void);
void gen_equop(int op);
void gen_relop(int op);
void jump(char *label, int label_flag, int offset, int label_num);
void branch(int cond, char *label, int offset, int label_num);
void gen_exit(void);
void assign(void);
void fetch(decl_t *declptr, int cond);
void gen_incdec(int mode);
void write_int(void);
void write_char(void);
void write_string(void);

/* hash.c */
void init_hash(void);
unsigned hash(char *name);
id *enter(int tokenType, char *name, int length);

/* decl.c */
// scope functions
decl_t *init_tdecl(int typeclass);
id *init_id(int toktype, char *name);
void init_scope(void);
void push_scope(void);
ste_t *pop_scope(int isfree);
void finish_scope(void);                         // free scope
void insert_ste(ste_t *);                        // insert ste
void insert_ste_list(ste_t *);                   // insert multiple stes
ste_t *declare(id *, decl_t *);                  // make ste & insert it
ste_t *declare_glob(id *idptr, decl_t *declptr); // declare as global
decl_t *find_decl(ste_t *steptr, id *idptr);     // find id at the steptr scope
decl_t *lookup(id *idptr);           // find idptr at the whole scope
decl_t *lookup_cur(id *idptr);       // find idptr at the current scope
decl_t *lookup_funcscope(id *idptr); // find idptr at the function scope

decl_t *make_var(decl_t *tdecl);
decl_t *make_const(decl_t *tdecl);
decl_t *make_func(decl_t *rettype, id *idptr);
decl_t *make_arr(int, decl_t *tdecl);
decl_t *make_ptr(decl_t *target);
decl_t *make_str(ste_t *ste);
decl_t *make_arg(decl_t *tdecl, decl_t *nextarg);

// access
decl_t *access_arr(decl_t *arrdecl, decl_t *idxdecl);
decl_t *access_struct(decl_t *strpvar, id *fieldid);
decl_t *access_structp(decl_t *strvar, id *fieldid);
decl_t *access_function(decl_t *func, decl_t *args);

#endif