#include "subc.h"
#include <stdlib.h>

struct ste **scope; // scope stack
int top;

void init_scope(void){
    top = -1;
    scope = (struct ste **)malloc(sizeof(struct ste *));
}
    
void push_scope(void){
    scope[++top] = (struct ste *)malloc(sizeof(struct ste)); 
    scope[top] = (top > 0)? scope[top-1] : NULL;
}

void pop_scope(void){
    free(scope[top--]);
}

void finish_scope(void){
    free(scope);
}

void insert(struct ste *steptr){
    // push steptr to scope[top] 
    steptr->prev = scope[top];
    scope[top] = steptr;
}

struct ste* declare(struct id *idptr, struct decl *declptr){

}