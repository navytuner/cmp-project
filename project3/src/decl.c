#include "subc.h"
#include "subc.tab.h"
#include <stdlib.h>

ste_t **scope; // scope stack
int top;

void init_scope(void){
    top = 0;
    scope = (ste_t **)malloc(sizeof(ste_t *));
    scope[0] = NULL; // scope[0]: dummy node
}
    
void push_scope(void){
    scope[++top] = (ste_t *)malloc(sizeof(ste_t)); 
    scope[top] = scope[top-1];
}

void pop_scope(void){
    ste_t *delptr = scope[top];
    while (delptr && delptr != scope[top-1]){
        free(delptr);
        delptr = delptr->prev;
    }
    top--;
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
    ste_t *newste = (ste_t *)malloc(sizeof(ste_t));
    newste->id = idptr;
    newste->decl = declptr;
    return newste;
}

void init_type(void){
    char *types[] = {"int", "char", "float", NULL};
    push_scope();
    for (int i = 0; types[i] != NULL; i++){
        id *idptr = enter(TYPE, types[i], strlen(types[i]));
        decl_t *declptr = (decl_t *)calloc(1, sizeof(decl_t));
        declptr->declclass = CLASS_TYPE;
        // declptr->typeclass = 
        insert(declare(idptr, declptr));
    }
}