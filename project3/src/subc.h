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
#include <strings.h>
#include <string.h>

/* DECL CLASS*/
#define DECL_VAR 0
#define DECL_CONST 1
#define DECL_FUNC 2
#define DECL_TYPE 3

/* TYPE CLASSS */
#define TYPE_INT 4 
#define TYPE_FLOAT 5 
#define TYPE_CHAR 6
#define TYPE_ARRAY 7
#define TYPE_POINTER 8
#define TYPE_STRUCT 9

extern ste_t** scope;
extern decl_t *int_tdecl;
extern decl_t *float_tdecl;
extern decl_t *char_tdecl;


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
  int declclass;            // VAR, CONST, FUNC, TYPE
  int typeclass;            // TYPE: type class(INT, array, ptr)
  struct decl *type;        // VAR, CONST

  int value;                // CONST: integer value
  float real_value;         // CONST: float value

  struct ste *formals;      // FUNC: formal argument list
  struct decl *returntype;  // FUNC: return TYPE decl

  struct decl *elementvar;  // TYPE(array): point to element VAR decl
  int len_arr;              // TYPE(array): # of elements
  struct ste *fields;       // TYPE(struct): point to field list
  struct decl *ptrto;       // TYPE(pointer): pointer type

  int size;                 // ALL: size in bytes
  struct ste **scope;       // VAR: scope when VAR declared
  struct decl *next;        // for list_of_variables declarations
} decl_t;

// Hash table interfaces
void init_hash(void);
unsigned hash(char *name);
id *enter(int tokenType, char *name, int length);

// decl.c
void init_scope(int cap=10);
void push_scope(void);
ste_t* pop_scope(int isfree=1);
void finish_scope(void);

void insert(ste_t *);
ste_t* declare(id*, decl_t*);

// make decl
decl_t* make_vardecl(decl_t *tdecl);
decl_t* make_constdecl(decl_t *tdecl);

decl_t* make_arrdecl(int, decl_t *tdecl);
decl_t* make_ptrdecl(decl_t *target);
decl_t* make_structdecl(ste_t *ste);

void init_type(void);

// Error message printing procedures
void error_preamble(void);
void error_undeclared(void);
void error_redeclaration(void);
void error_assignable(void);
void error_incompatible(void);
void error_null(void);
void error_binary(void);
void error_unary(void);
void error_comparable(void);
void error_indirection(void);
void error_addressof(void);
void error_struct(void);
void error_strurctp(void);
void error_member(void);
void error_array(void);
void error_subscript(void);
void error_incomplete(void);
void error_return(void);
void error_function(void);
void error_arguments(void);

#endif