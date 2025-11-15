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

void init_scope(int cap){
    top = 0;
    scope = (ste_t **)calloc(cap, sizeof(ste_t *));
    scope[0] = NULL; // scope[0]: dummy node
    capacity = cap;
}
    
void push_scope(void){
    if (top+1 == capacity){
        // double the capacity
        ste_t **new_scope = (ste_t **)calloc(2*capacity, sizeof(ste_t *));
        memcpy(new_scope, scope, capacity * sizeof(ste_t *));
        capacity *= 2;
        free(scope);
        scope = new_scope;
    }
    scope[++top] = scope[top-1];
}

ste_t* pop_scope(int isfree){
    ste_t *delptr = scope[top];
    ste_t *target = scope[top]; 
    while (delptr && delptr->prev != scope[top-1]){
        if (isfree) free(delptr);
        delptr = delptr->prev;
    }
    if (isfree) free(delptr);
    else delptr->prev = NULL;
    scope[top--] = 0;
    return target;
}

void finish_scope(void){
    free(scope);
}

void insert(ste_t *steptr){
    // push steptr to scope[top] 
    steptr->prev = scope[top];
    scope[top] = steptr;
}

ste_t* lookup(id *idptr){
    ste_t *cur = scope[top];
    while (cur){
        if (cur->id == idptr) return cur;
        cur = cur->prev;
    }
    return NULL;
}

ste_t* declare(id *idptr, decl_t *declptr){
    ste_t *newste = (ste_t *)calloc(1, sizeof(ste_t));
    newste->id = idptr;
    newste->decl = declptr;

    newste->prev = scope[top];
    scope[top] = newste;
    return newste;
}

decl_t* make_vardecl(decl_t *tdecl){
    decl_t *vardecl = (decl_t *)calloc(1, sizeof(decl_t));
    vardecl->declclass = DECL_VAR;
    vardecl->type = tdecl;
    return vardecl;
}

decl_t* make_constdecl(decl_t *tdecl){
    decl_t *constdecl = (decl_t *)calloc(1, sizeof(decl_t));
    constdecl->declclass = DECL_CONST;
    constdecl->type = tdecl;
    return constdecl;
}

decl_t* make_funcdecl(ste_t *arglist, decl_t *rettype){
    decl_t *funcdecl = (decl_t *)calloc(1, sizeof(decl_t));
    funcdecl->declclass = DECL_FUNC;
    funcdecl->formals = arglist;
    funcdecl->returntype = rettype;
    return funcdecl;
}

decl_t* make_arrdecl(int len, decl_t *tdecl){
    decl_t *arrdecl = (decl_t *)calloc(1, sizeof(decl_t));
    arrdecl->declclass = DECL_TYPE;
    arrdecl->typeclass = TYPE_ARRAY;
    arrdecl->len_arr = len;

    decl_t *vardecl;
    decl_t *nextdecl = NULL;
    for (int i = 0; i < len; i++){
        vardecl = make_vardecl(tdecl);
        vardecl->next = nextdecl;
        nextdecl = vardecl; 
    }
    arrdecl->elementvar = vardecl;
    return arrdecl;
}

decl_t* make_ptrdecl(decl_t *target){
    decl_t *ptrdecl = (decl_t *)calloc(1, sizeof(decl_t));
    ptrdecl->declclass = DECL_TYPE;
    ptrdecl->typeclass = TYPE_POINTER;
    ptrdecl->ptrto = target;
    return ptrdecl;
}

decl_t* make_structdecl(ste_t *fields){
    decl_t *structdecl = (decl_t *)calloc(1, sizeof(decl_t));
    structdecl->declclass = DECL_TYPE;
    structdecl->typeclass = TYPE_STRUCT;
    structdecl->fields = fields;
    return structdecl;
}


void init_type(void){
    char *types[] = {"int", "float", "char", NULL};
    int class[] = {TYPE_INT, TYPE_FLOAT, TYPE_CHAR, 0};
    push_scope();
    for (int i = 0; types[i] != NULL; i++){
        id *idptr = enter(TYPE, types[i], strlen(types[i]));
        decl_t *declptr = (decl_t *)calloc(1, sizeof(decl_t));
        declptr->declclass = DECL_TYPE;
        declptr->typeclass = class[i]; 

        // assign declptr to tdecl variables
        switch (class[i]){
            case TYPE_INT: 
                int_tdecl = declptr;
                break;
            case TYPE_FLOAT:
                float_tdecl = declptr;
                break;
            case TYPE_CHAR:
                char_tdecl = declptr;
                break;
        }
        insert(declare(idptr, declptr));
    }
}