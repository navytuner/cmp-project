#include "subc.h"
#include "subc.tab.h"

void check_preamble(void);
void check_undeclared(id *idptr){
    if (!lookup(idptr)) error_undeclared();
}

void check_redeclaration(id *idptr){
    if (lookup_cur(idptr)) error_redeclaration();
}

void check_assignable(decl_t *decl){
    if (decl->declclass != DECL_VAR) error_assignable();
}

void check_incompatible(decl_t *decl_1, decl_t *decl_2){
    if (decl_1->type->typeclass != decl_2->type->typeclass) error_incompatible();
}

void check_null(decl_t *lhs, decl_t *rhs){
    if (rhs->declclass == DECL_NULL && 
        lhs->type->typeclass != TYPE_PTR) error_null();
}

void check_binary(decl_t *op1, decl_t *op2){
    if (op1->type->typeclass != TYPE_INT ||
        op2->type->typeclass != TYPE_INT) error_binary();
}

void check_unary(decl_t *decl, int tflag){
    // type should be TYPE_INT or TYPE_CHAR
    int type = decl->type->typeclass;
    switch (tflag){
        case TYPE_INT | TYPE_CHAR:
            if (type != TYPE_INT && type != TYPE_CHAR)
                error_unary();
            break;
        case TYPE_INT:
            if (type != TYPE_INT)
                error_unary();
            break;
        case TYPE_CHAR:
            if (type != TYPE_CHAR)
                error_unary();
            break;
    }
}

void check_comparable(decl_t *op1, decl_t *op2){
    int type1 = op1->type->typeclass;
    int type2 = op2->type->typeclass;
    if (type1 == TYPE_INT && type2 == TYPE_INT) return;
    if (type1 == TYPE_CHAR && type2 == TYPE_CHAR) return;
    error_comparable();
}

void check_indirection(decl_t *op){
    if (op->type->typeclass != TYPE_PTR) error_indirection();
}

void check_addressof(decl_t *op){
    if (op->declclass != DECL_VAR) error_addressof();
}

void check_struct(decl_t *stdecl){
    if (stdecl->type->typeclass != TYPE_STRUCT) error_struct();
}

void check_strurctp(decl_t *strptr){
    if (strptr->type->typeclass != TYPE_STRPTR) error_strurctp();
}

void check_member(decl_t *stdecl, id *idptr){
    if (!find_decl(stdecl->fields, idptr)) error_member();
}

void check_array(decl_t *arrdecl){
    if (arrdecl->type->typeclass != TYPE_ARRAY) error_array();
}

void check_subscript(decl_t *idxdecl){
    if (idxdecl->type != int_tdecl) error_subscript();
}

void check_incomplete(id *strid){
	if (!lookup(strid)) error_incomplete();
}

void check_return(decl_t *tdecl){
    decl_t *func = lookup_cur(returnid);
    if (func->returntype != tdecl) error_return();
}

void check_function(decl_t *decl){
    if (decl->declclass != DECL_FUNC) error_function();
}

void check_arguments(ste_t *args, decl_t *tdecl){
    decl_t *cur = tdecl;
    ste_t *arglist = args;
    while (cur || arglist){
        if (!cur || !arglist){
            error_arguments();
            return;
        }
        if (cur->typeclass != arglist->decl->type->typeclass) {
            error_arguments();
            return;
        }
        cur = cur->next;
        arglist = arglist->prev;
    }
}

// Print the preamble of error message.
void error_preamble(void) {
  // TODO
  // Implement this function using get_lineno() function.
  printf("%s:%d: error: ", get_filename(), get_lineno());
}

void error_undeclared(void) {
  error_preamble();
  printf("use of undeclared identifier\n");
}

void error_redeclaration(void) {
  error_preamble();
  printf("redeclaration\n");
}

void error_assignable(void) {
  error_preamble();
  printf("lvalue is not assignable\n");
}

void error_incompatible(void) {
  error_preamble();
  printf("incompatible types for assignment operation\n");
}

void error_null(void) {
  error_preamble();
  printf("cannot assign 'NULL' to non-pointer type\n");
}

void error_binary(void) {
  error_preamble();
  printf("invalid operands to binary expression\n");
}

void error_unary(void) {
  error_preamble();
  printf("invalid argument type to unary expression\n");
}

void error_comparable(void) {
  error_preamble();
  printf("types are not comparable in binary expression\n");
}

void error_indirection(void) {
  error_preamble();
  printf("indirection requires pointer operand\n");
}

void error_addressof(void) {
  error_preamble();
  printf("cannot take the address of an rvalue\n");
}

void error_struct(void) {
  error_preamble();
  printf("member reference base type is not a struct\n");
}

void error_strurctp(void){
  error_preamble();
  printf("member reference base type is not a struct pointer\n");
}

void error_member(void) {
  error_preamble();
  printf("no such member in struct\n");
}

void error_array(void) {
  error_preamble();
  printf("subscripted value is not an array\n");
}

void error_subscript(void) {
  error_preamble();
  printf("array subscript is not an integer\n");
}

void error_incomplete(void) {
  error_preamble();
  printf("incomplete type\n");
}

void error_return(void) {
  error_preamble();
  printf("incompatible return types\n");
}

void error_function(void) {
  error_preamble();
  printf("not a function\n");
}

void error_arguments(void) {
  error_preamble();
  printf("incompatible arguments in function call\n");
}