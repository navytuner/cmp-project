#include "subc.h"
#include "subc.tab.h"

int ispass(decl_t *tdecl) { return (tdecl == pass_tdecl); }

int issametype(decl_t *tdecl1, decl_t *tdecl2) {
  if (!tdecl1 || !tdecl2)
    return 0;

  int type1 = tdecl1->typeclass;
  int type2 = tdecl2->typeclass;
  if (type1 != type2)
    return 0;
  switch (type1) {
  case TYPE_INT:
  case TYPE_CHAR:
    return 1;
  case TYPE_ARRAY:
    decl_t *arr_tdecl1 = tdecl1->elementvar->type;
    decl_t *arr_tdecl2 = tdecl2->elementvar->type;
    return issametype(arr_tdecl1, arr_tdecl2);
  case TYPE_PTR:
    return issametype(tdecl1->ptrto, tdecl2->ptrto);
  case TYPE_STRUCT:
    return (tdecl1 == tdecl2);
  }
  return 0;
}

int check_undeclared(id *idptr) {
  if (!lookup(idptr)) {
    error_undeclared();
    errflag = 1;
    return 1;
  }
  return 0;
}

int check_redeclaration(id *idptr, int isglob) {
  if (isglob) {
    if (lookup(idptr)) {
      error_redeclaration();
      errflag = 1;
      return 1;
    }
    return 0;
  } else {
    if (lookup_cur(idptr)) {
      error_redeclaration();
      errflag = 1;
      return 1;
    }
    return 0;
  }
}

int check_assignable(decl_t *decl) {
  if (ispass(decl))
    return 1;
  if (decl && decl->declclass == DECL_VAR)
    return 0;
  error_assignable();
  errflag = 1;
  return 1;
}

int check_incompatible(decl_t *lhs, decl_t *rhs) {
  if (ispass(lhs->type) || ispass(rhs))
    return 1;
  if (!lhs || !lhs->type || !rhs) {
    error_incompatible();
    errflag = 1;
    return 1;
  }
  if (rhs->ptrto == null_tdecl && lhs->type->typeclass == TYPE_PTR)
    return 0;
  if (!issametype(lhs->type, rhs)) {
    error_incompatible();
    errflag = 1;
    return 1;
  }
  return 0;
}

int check_null(decl_t *lhs, decl_t *rhs) {
  if (ispass(lhs->type) || ispass(rhs))
    return 1;
  if (rhs->ptrto == null_tdecl && lhs->type->typeclass != TYPE_PTR) {
    error_null();
    errflag = 1;
    return 1;
  }
  return 0;
}

int check_binary(decl_t *op1, decl_t *op2, int tflag) {
  if (ispass(op1) || ispass(op2))
    return 1;

  int tcl1 = op1->typeclass;
  int tcl2 = op2->typeclass;
  if (tcl1 != tcl2) {
    error_binary();
    errflag = 1;
    return 1;
  }

  switch (tflag) {
  case TYPE_INT:
    if (tcl1 != TYPE_INT) {
      error_binary();
      errflag = 1;
      return 1;
    }
    break;
  case TYPE_CHAR:
    if (tcl1 != TYPE_CHAR) {
      error_binary();
      errflag = 1;
      return 1;
    }
    break;
  }
  return 0;
}

int check_unary(decl_t *decl, int tflag) {
  if (ispass(decl->type))
    return 1;

  decl_t *tdecl = decl->type;
  switch (tflag) {
  case (TYPE_INT | TYPE_CHAR):
    if (tdecl->typeclass != TYPE_INT && tdecl->typeclass != TYPE_CHAR) {
      error_unary();
      errflag = 1;
      return 1;
    }
    break;
  case TYPE_INT:
    if (tdecl->typeclass != TYPE_INT) {
      error_unary();
      errflag = 1;
      return 1;
    }
    break;
  case TYPE_CHAR:
    if (tdecl->typeclass != TYPE_CHAR) {
      error_unary();
      errflag = 1;
      return 1;
    }
    break;
  }
  return 0;
}

int check_comparable(decl_t *op1, decl_t *op2, int tflag) {
  if (ispass(op1) || ispass(op2))
    return 1;

  int tclass1 = op1->typeclass;
  int tclass2 = op2->typeclass;
  if (tflag == (TYPE_INT | TYPE_CHAR)) {
    if (tclass1 == tclass2 && (tclass1 == TYPE_INT || tclass1 == TYPE_CHAR))
      return 0;
    error_comparable();
    errflag = 1;
    return 1;
  }
  if (tflag == (TYPE_INT | TYPE_CHAR | TYPE_PTR)) {
    if (tclass1 == TYPE_PTR && tclass2 == TYPE_PTR &&
        (issametype(op1, op2) ||
         (op1->ptrto == null_tdecl || op2->ptrto == null_tdecl)))
      return 0;
    if (tclass1 == tclass2 && (tclass1 == TYPE_INT || tclass1 == TYPE_CHAR))
      return 0;
    error_comparable();
    errflag = 1;
    return 1;
  }
  return 0;
}

int check_indirection(decl_t *op) {
  if (ispass(op->type))
    return 1;

  if (op->type->typeclass != TYPE_PTR) {
    error_indirection();
    errflag = 1;
    return 1;
  }
  return 0;
}

int check_addressof(decl_t *op) {
  if (ispass(op->type))
    return 1;

  if (op->declclass != DECL_VAR) {
    if (op->type && op->type->isconst == 0)
      return 0;
    error_addressof();
    errflag = 1;
    return 1;
  }
  return 0;
}

int check_struct(decl_t *strdecl) {
  if (ispass(strdecl))
    return 1;

  if (strdecl->typeclass != TYPE_STRUCT) {
    error_struct();
    errflag = 1;
    return 1;
  }
  return 0;
}

int check_structp(decl_t *strp) {
  if (ispass(strp))
    return 1;

  if (strp->typeclass == TYPE_PTR) {
    if (strp->ptrto && strp->ptrto->typeclass == TYPE_STRUCT)
      return 0;
  }
  error_structp();
  errflag = 1;
  return 1;
}

int check_member(decl_t *strdecl, id *idptr) {
  if (ispass(strdecl))
    return 1;

  if (!find_decl(strdecl->fields, idptr)) {
    error_member();
    errflag = 1;
    return 1;
  }
  return 0;
}

int check_array(decl_t *arrdecl) {
  if (ispass(arrdecl->type))
    return 1;

  if (arrdecl->type->typeclass != TYPE_ARRAY) {
    error_array();
    errflag = 1;
    return 1;
  }
  return 0;
}

int check_subscript(decl_t *idxdecl) {
  if (ispass(idxdecl))
    return 1;

  if (idxdecl->typeclass != TYPE_INT) {
    error_subscript();
    errflag = 1;
    return 1;
  }
  return 0;
}

int check_incomplete(id *strid) {
  if (!lookup(strid)) {
    error_incomplete();
    errflag = 1;
    return 1;
  }
  return 0;
}

int check_return(decl_t *tdecl) {
  if (ispass(tdecl))
    return 1;

  decl_t *ret = lookup(returnid);
  if (!issametype(ret->type, tdecl)) {
    error_return();
    errflag = 1;
    return 1;
  }
  return 0;
}

int check_function(decl_t *decl) {
  if (ispass(decl))
    return 1;

  if (decl->declclass != DECL_FUNC) {
    error_function();
    errflag = 1;
    return 1;
  }
  return 0;
}

int check_arguments(decl_t *func, decl_t *args) {
  if (ispass(func->type) || ispass(args))
    return 1;

  decl_t *arg = args;
  ste_t *param = func->formals;
  while (param->id != returnid && arg) {
    if (!issametype(param->decl->type, arg->type)) {
      error_arguments();
      errflag = 1;
      return 1;
    }
    param = param->prev;
    arg = arg->next;
  }

  if (param->id != returnid || arg) {
    error_arguments();
    errflag = 1;
    return 1;
  }
  return 0;
}

void error_preamble(void) {
  printf("%s:%d: error: ", get_filename(), get_lineno());
}

void error_undeclared(void) {
  if (errflag)
    return;
  error_preamble();
  printf("use of undeclared identifier\n");
}

void error_redeclaration(void) {
  if (errflag)
    return;
  error_preamble();
  printf("redeclaration\n");
}

void error_assignable(void) {
  if (errflag)
    return;
  error_preamble();
  printf("lvalue is not assignable\n");
}

void error_incompatible(void) {
  if (errflag)
    return;
  error_preamble();
  printf("incompatible types for assignment operation\n");
}

void error_null(void) {
  if (errflag)
    return;
  error_preamble();
  printf("cannot assign 'NULL' to non-pointer type\n");
}

void error_binary(void) {
  if (errflag)
    return;
  error_preamble();
  printf("invalid operands to binary expression\n");
}

void error_unary(void) {
  if (errflag)
    return;
  error_preamble();
  printf("invalid argument type to unary expression\n");
}

void error_comparable(void) {
  if (errflag)
    return;
  error_preamble();
  printf("types are not comparable in binary expression\n");
}

void error_indirection(void) {
  if (errflag)
    return;
  error_preamble();
  printf("indirection requires pointer operand\n");
}

void error_addressof(void) {
  if (errflag)
    return;
  error_preamble();
  printf("cannot take the address of an rvalue\n");
}

void error_struct(void) {
  if (errflag)
    return;
  error_preamble();
  printf("member reference base type is not a struct\n");
}

void error_structp(void) {
  if (errflag)
    return;
  error_preamble();
  printf("member reference base type is not a struct pointer\n");
}

void error_member(void) {
  if (errflag)
    return;
  error_preamble();
  printf("no such member in struct\n");
}

void error_array(void) {
  if (errflag)
    return;
  error_preamble();
  printf("subscripted value is not an array\n");
}

void error_subscript(void) {
  if (errflag)
    return;
  error_preamble();
  printf("array subscript is not an integer\n");
}

void error_incomplete(void) {
  if (errflag)
    return;
  error_preamble();
  printf("incomplete type\n");
}

void error_return(void) {
  if (errflag)
    return;
  error_preamble();
  printf("incompatible return types\n");
}

void error_function(void) {
  if (errflag)
    return;
  error_preamble();
  printf("not a function\n");
}

void error_arguments(void) {
  if (errflag)
    return;
  error_preamble();
  printf("incompatible arguments in function call\n");
}