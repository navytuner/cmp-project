#include "subc.h"
#include "subc.tab.h"
#include <stdlib.h>

ste_t **scope; // scope stack
int top;
int capacity;

// tdecl variables
decl_t *int_tdecl;
decl_t *float_tdecl;
decl_t *char_tdecl;
decl_t *string_tdecl;
decl_t *pass_tdecl;
id *returnid;

void init_scope(int cap) {
  top = 0;
  scope = (ste_t **)calloc(cap, sizeof(ste_t *));
  scope[0] = NULL; // scope[0]: dummy node
  capacity = cap;
}

void init_type(void) {
  char *types[] = {"int", "char", NULL};
  int class[] = {TYPE_INT, TYPE_CHAR, 0};
  push_scope();
  for (int i = 0; types[i] != NULL; i++) {
    id *idptr = enter(TYPE, types[i], strlen(types[i]));
    decl_t *declptr = (decl_t *)calloc(1, sizeof(decl_t));
    declptr->declclass = DECL_TYPE;
    declptr->typeclass = class[i];

    // assign declptr to tdecl variables
    switch (class[i]) {
    case TYPE_INT:
      int_tdecl = declptr;
      break;
    case TYPE_CHAR:
      char_tdecl = declptr;
      break;
    }
    declare(idptr, declptr);
  }

  /* TYPE_STRING, TYPE_PASS */
  string_tdecl = (decl_t *)calloc(1, sizeof(decl_t));
  string_tdecl->declclass = DECL_TYPE;
  string_tdecl->typeclass = TYPE_STRING;

  pass_tdecl = (decl_t *)calloc(1, sizeof(decl_t));
  pass_tdecl->declclass = DECL_TYPE;
  pass_tdecl->typeclass = TYPE_PASS;
  returnid = enter(ID, "*return", 7);
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

  newste->prev = scope[1];
  scope[1] = newste;
  if (top <= 1)
    return newste;

  ste_t *cur = scope[2];
  while (cur && cur->prev != scope[1]->prev) {
    cur = cur->prev;
  }
  cur->prev = scope[1];
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
  return vardecl;
}

decl_t *make_const(decl_t *tdecl) {
  decl_t *constdecl = (decl_t *)calloc(1, sizeof(decl_t));
  constdecl->declclass = DECL_CONST;
  constdecl->type = tdecl;
  return constdecl;
}

decl_t *make_func(decl_t *rettype) {
  decl_t *funcdecl = (decl_t *)calloc(1, sizeof(decl_t));
  funcdecl->declclass = DECL_FUNC;
  funcdecl->returntype = rettype;
  return funcdecl;
}

decl_t *make_arr(int len, decl_t *tdecl) {
  decl_t *arrdecl = (decl_t *)calloc(1, sizeof(decl_t));
  arrdecl->declclass = DECL_TYPE;
  arrdecl->typeclass = TYPE_ARRAY;
  arrdecl->len_arr = len;

  decl_t *vardecl;
  decl_t *nextdecl = NULL;
  for (int i = 0; i < len; i++) {
    vardecl = make_var(tdecl);
    vardecl->next = nextdecl;
    nextdecl = vardecl;
  }
  arrdecl->elementvar = vardecl;
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

decl_t *make_null(void) {
  decl_t *nulldecl = (decl_t *)calloc(1, sizeof(decl_t));
  nulldecl->declclass = DECL_NULL;
  return nulldecl;
}

decl_t *access_arr(decl_t *arrdecl, decl_t *idxdecl) {
  decl_t *tdecl = arrdecl->type;
  if (check_array(arrdecl) || check_subscript(idxdecl))
    return pass_tdecl;
  return tdecl->elementvar;
}

decl_t *access_struct(decl_t *stdecl, id *fieldid) {
  if (check_struct(stdecl) || check_member(stdecl, fieldid))
    return pass_tdecl;
  return find_decl(stdecl->fields, fieldid);
}

decl_t *access_structp(decl_t *ptr, id *fieldid) {
  if (check_structp(ptr) || check_member(ptr->type->ptrto, fieldid))
    return pass_tdecl;
  return find_decl(ptr->type->ptrto->fields, fieldid);
}

decl_t *access_function(decl_t *func, decl_t *args) {
  if (check_function(func) || check_arguments(func, args))
    return pass_tdecl;
  return func->returntype;
}