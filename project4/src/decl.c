#include "subc.h"
#include "subc.tab.h"
#include <stdlib.h>

ste_t **scope; // scope stack
int top;
int capacity;

// tdecl variables
decl_t *int_tdecl;
decl_t *int_tdecl_const;
decl_t *char_tdecl;
decl_t *char_tdecl_const;
decl_t *string_tdecl;
decl_t *pass_tdecl;
decl_t *null_tdecl;
id *intid;
id *charid;
id *returnid;
int errflag;

// global offset counter
int glob_offset;

decl_t *init_tdecl(int typeclass) {
  decl_t *tdecl = (decl_t *)calloc(1, sizeof(decl_t));
  tdecl->typeclass = typeclass;
}

id *init_id(int toktype, char *name) {
  return enter(toktype, name, strlen(name));
}

void init_scope(void) {
  /* reset error flag */
  errflag = 0;
  glob_offset = 0;

  /* init id */
  intid = init_id(TYPE, "int");
  charid = init_id(TYPE, "char");
  returnid = init_id(ID, "*return");

  /* init tdecl */
  int_tdecl = init_tdecl(TYPE_INT);
  int_tdecl_const = init_tdecl(TYPE_INT);
  char_tdecl = init_tdecl(TYPE_CHAR);
  char_tdecl_const = init_tdecl(TYPE_CHAR);
  null_tdecl = init_tdecl(TYPE_NULL);
  string_tdecl = init_tdecl(TYPE_STRING);
  pass_tdecl = init_tdecl(TYPE_PASS);
  int_tdecl_const->isconst = 1;
  char_tdecl_const->isconst = 1;

  /* init scope */
  top = 0;
  scope = (ste_t **)calloc(SCOPE_INITSZ, sizeof(ste_t *));
  scope[0] = NULL; // scope[0]: dummy node
  capacity = SCOPE_INITSZ;
  push_scope();
  declare(intid, int_tdecl);
  declare(charid, char_tdecl);
}

void push_scope(void) {
  if (top + 1 == capacity) {
    // double the capacity
    ste_t **new_scope = (ste_t **)calloc(2 * capacity, sizeof(ste_t *));
    memcpy(new_scope, scope, capacity * sizeof(ste_t *));
    capacity *= 2;
    free(scope);
    scope = new_scope;
  }
  top++;
  scope[top] = scope[top - 1];
}

ste_t *pop_scope(int isfree) {
  if (!scope[top])
    return NULL;

  if (top >= SCOPE_GLOB && scope[top] == scope[top - 1]) {
    scope[top--] = 0;
    return NULL;
  }

  ste_t *delptr = scope[top];
  ste_t *target = scope[top];
  while (delptr && delptr->prev != scope[top - 1]) {
    if (isfree)
      free(delptr);
    delptr = delptr->prev;
  }
  if (isfree)
    free(delptr);
  else
    delptr->prev = NULL;
  scope[top--] = 0;
  return target;
}

void finish_scope(void) { free(scope); }

void insert_ste(ste_t *steptr) {
  // push steptr to scope[top]
  steptr->prev = scope[top];
  scope[top] = steptr;
}

void insert_ste_list(ste_t *steptr) {
  if (!steptr)
    return;

  ste_t *last = steptr;
  while (last && last->prev) {
    last = last->prev;
  }
  last->prev = scope[top];
  scope[top] = steptr;
}

ste_t *declare(id *idptr, decl_t *declptr) {
  ste_t *newste = (ste_t *)calloc(1, sizeof(ste_t));
  newste->id = idptr;
  newste->decl = declptr;

  newste->prev = scope[top];
  scope[top] = newste;
  return newste;
}

ste_t *declare_glob(id *idptr, decl_t *declptr) {
  ste_t *newste = (ste_t *)calloc(1, sizeof(ste_t));
  newste->id = idptr;
  newste->decl = declptr;

  newste->prev = scope[SCOPE_GLOB];
  scope[SCOPE_GLOB] = newste;
  if (top <= SCOPE_GLOB)
    return newste;

  ste_t *cur = scope[SCOPE_GLOB + 1];
  while (cur && cur->prev != scope[SCOPE_GLOB]->prev) {
    cur = cur->prev;
  }
  cur->prev = scope[SCOPE_GLOB];
  return newste;
}

decl_t *find_decl(ste_t *steptr, id *idptr) {
  ste_t *cur = steptr;
  while (cur) {
    if (cur->id == idptr)
      return cur->decl;
    cur = cur->prev;
  }
  return NULL;
}

decl_t *lookup(id *idptr) { return find_decl(scope[top], idptr); }

decl_t *lookup_cur(id *idptr) {
  ste_t *cur = scope[top];
  while (cur && cur != scope[top - 1]) {
    if (cur->id == idptr)
      return cur->decl;
    cur = cur->prev;
  }
  return NULL;
}

decl_t *make_var(decl_t *tdecl) {
  decl_t *vardecl = (decl_t *)calloc(1, sizeof(decl_t));
  vardecl->declclass = DECL_VAR;
  vardecl->type = tdecl;
  vardecl->offset = glob_offset++;
  vardecl->size = 1;
  return vardecl;
}

decl_t *make_const(decl_t *tdecl) {
  if (tdecl == int_tdecl)
    tdecl = int_tdecl_const;
  else if (tdecl == char_tdecl)
    tdecl = char_tdecl_const;

  decl_t *constdecl = (decl_t *)calloc(1, sizeof(decl_t));
  constdecl->declclass = DECL_CONST;
  constdecl->type = tdecl;
  tdecl->isconst = 1;
  return constdecl;
}

decl_t *make_func(decl_t *rettype) {
  decl_t *funcdecl = (decl_t *)calloc(1, sizeof(decl_t));
  funcdecl->declclass = DECL_FUNC;
  if (rettype == int_tdecl)
    funcdecl->returntype = int_tdecl_const;
  else if (rettype == char_tdecl)
    funcdecl->returntype = char_tdecl_const;
  else
    funcdecl->returntype = rettype;
  return funcdecl;
}

decl_t *make_arr(int len, decl_t *tdecl) {
  decl_t *arrdecl = (decl_t *)calloc(1, sizeof(decl_t));
  arrdecl->declclass = DECL_TYPE;
  arrdecl->typeclass = TYPE_ARRAY;
  arrdecl->len_arr = len;
  arrdecl->elementvar = make_var(tdecl);
  return arrdecl;
}

decl_t *make_ptr(decl_t *target) {
  decl_t *ptrdecl = (decl_t *)calloc(1, sizeof(decl_t));
  ptrdecl->declclass = DECL_TYPE;
  ptrdecl->typeclass = TYPE_PTR;
  ptrdecl->ptrto = target;
  return ptrdecl;
}

decl_t *make_str(ste_t *fields) {
  decl_t *structdecl = (decl_t *)calloc(1, sizeof(decl_t));
  structdecl->declclass = DECL_TYPE;
  structdecl->typeclass = TYPE_STRUCT;
  structdecl->fields = fields;
  return structdecl;
}

decl_t *make_arg(decl_t *tdecl, decl_t *nextarg) {
  decl_t *newarg = make_var(tdecl);
  newarg->next = nextarg;
  return newarg;
}

decl_t *access_arr(decl_t *arrdecl, decl_t *idxdecl) {
  decl_t *tdecl = arrdecl->type;
  if (check_array(arrdecl) || check_subscript(idxdecl))
    return make_const(pass_tdecl);
  return tdecl->elementvar;
}

decl_t *access_struct(decl_t *strvar, id *fieldid) {
  decl_t *strdecl = strvar->type;
  if (check_struct(strdecl) || check_member(strdecl, fieldid))
    return make_const(pass_tdecl);
  return find_decl(strdecl->fields, fieldid);
}

decl_t *access_structp(decl_t *strpvar, id *fieldid) {
  decl_t *strp = strpvar->type;
  if (check_structp(strp) || check_member(strp->ptrto, fieldid))
    return make_const(pass_tdecl);
  return find_decl(strp->ptrto->fields, fieldid);
}

decl_t *access_function(decl_t *func, decl_t *args) {
  if (check_function(func) || check_arguments(func, args))
    return make_const(pass_tdecl);
  return make_const(func->returntype);
}