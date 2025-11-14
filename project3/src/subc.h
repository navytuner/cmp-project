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

struct id {
  int tokenType;
  char *name;
  int count;
};

struct ste {
  struct id *id;
  struct decl *decl;
  struct ste *prev;
};

struct decl {
  int declclass;            // VAR, CONST, FUNC, TYPE
  struct decl *type;        // VAR, CONST
  int value;                // CONST: integer value
  float real_value;         // CONST: float value
  struct ste *formals;      // FUNC: formal argument list
  struct decl *returntype;  // FUNC: return TYPE decl
  int typeclass;            // TYPE: type class(INT, array, ptr)
  struct decl *elementvar;  // TYPE(array): point to element VAR decl
  int num_idx;              // TYPE(array): # of elements
  struct ste *fieldlist;    // TYPE(struct): point to field list
  struct decl *ptrto;       // TYPE(pointer): pointer type
  int size;                 // ALL: size in bytes
  struct ste **scope;       // VAR: scope when VAR declared
  struct decl *next;        // for list_of_variables declarations
};

// Hash table interfaces
unsigned hash(char *name);
struct id *enter(int tokenType, char *name, int length);

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