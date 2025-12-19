#include "subc.h"
#include "subc.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MX 500
#define LABEL_MAXLEN 300
#define LABEL_STACK_CAP 1000
extern FILE *yyout;

int str_offset;
int label_offset;
int num_args;
int cont_label[LABEL_STACK_CAP];
int break_label[LABEL_STACK_CAP];
int cont_top;
int break_top;
int func_flag;

id *cur_strid;
// id *idstk[MX];
// int idstk_top;

void init_gen(void) {
  str_offset = 0;
  label_offset = 0;
  num_args = 0;
  cont_top = -1;
  break_top = -1;
  func_flag = 0;
  // idstk_top = -1;
  shift_sp(1);
  push_const_label("EXIT");
  push_reg("fp");
  push_reg("sp");
  pop_reg("fp");
  jump("main", LABEL_PLAIN, 0, -1);
  gen_label("EXIT", LABEL_PLAIN);
  gen_exit();
}

void str_ret(id *idptr) {
  decl_t *strdecl = lookup_funcscope(idptr);
  if (strdecl) {
    // local variable
    for (int i = 0; i < strdecl->size; i++) {
      push_reg("fp");
      push_const_int(-3 - i);
      gen_add();
      fetch(NULL, 0);
      push_reg("fp");
      push_const_int(1 + strdecl->offset + strdecl->size - 1 - i);
      gen_add();
      fetch(NULL, 0);
      assign();
    }
  } else {
    // global variable
    strdecl = find_decl(scope[SCOPE_GLOB], idptr);
    for (int i = 0; i < strdecl->size; i++) {
      push_reg("fp");
      push_const_int(-3 - i);
      gen_add();
      fetch(NULL, 0);
      push_const_label_offset("Lglob", strdecl->offset);
      push_const_int(strdecl->size - 1 - i);
      gen_add();
      fetch(NULL, 0);
      assign();
    }
  }
}

void str_passarg(id *idptr) {
  decl_t *strdecl = lookup(idptr)->type;
  for (int i = 0; i < strdecl->size; i++) {
    load_var(idptr);
    if (i > 0) {
      push_const_int(i);
      gen_add();
    }
    fetch(NULL, 0);
  }
}

void str_assign_prologue(decl_t *strdecl) {
  for (int i = 0; i < strdecl->size; i++) {
    push_reg("sp");
    fetch(NULL, 0);
    if (i > 0) {
      push_const_int(1);
      gen_add();
    }
  }
}

void str_assign(decl_t *strdecl) {
  for (int i = 0; i < strdecl->size; i++) {
    push_reg("sp");
    push_const_int(-1 - i);
    gen_add();
    fetch(NULL, 0);
    push_reg("sp");
    push_const_int(-1);
    gen_add();
    fetch(NULL, 0);
    if (i < strdecl->size - 1) {
      push_const_int(strdecl->size - 1 - i);
      gen_add();
    }
    fetch(NULL, 0);
    assign();
  }
}

// void push_idstk(id *idptr) { idstk[++idstk_top] = idptr; }

// id *op2_idstk(void) { return idstk[idstk_top]; }

// id *op1_idstk(void) { return idstk[idstk_top - 1]; }

// void pop_idstk(void) { idstk[idstk_top--] = NULL; }

void push_labels(int contlbl, int breaklbl) {
  cont_label[++cont_top] = contlbl;
  break_label[++break_top] = breaklbl;
}

int pop_cont(void) { return cont_label[cont_top--]; }

int pop_break(void) { return break_label[break_top--]; }

int top_cont(void) { return cont_label[cont_top]; }

int top_break(void) { return break_label[break_top]; }

void load_var(id *idptr) {
  decl_t *decl = lookup_funcscope(idptr);
  char buf[MX];

  if (!decl) {
    // global variable
    decl = find_decl(scope[SCOPE_GLOB], idptr);
    if (decl->declclass != DECL_VAR && decl->declclass != DECL_CONST)
      return;
    push_const_label_offset("Lglob", decl->offset);
    if (decl->type && decl->type->typeclass == TYPE_STRUCT)
      cur_strid = idptr;
    if (decl->type && decl->type->typeclass == TYPE_ARRAY &&
        decl->type->elementvar->type->typeclass == TYPE_STRUCT)
      cur_strid = idptr;
  } else {
    // local variable
    if (decl->declclass != DECL_VAR && decl->declclass != DECL_CONST)
      return;
    if (decl->type && decl->type->typeclass == TYPE_STRUCT)
      cur_strid = idptr;
    if (decl->type && decl->type->typeclass == TYPE_ARRAY &&
        decl->type->elementvar->type->typeclass == TYPE_STRUCT)
      cur_strid = idptr;
    push_reg("fp");
    push_const_int(decl->offset + 1);
    gen_add();
  }
}

void func_prologue(decl_t *funcdecl) {
  id *idptr = funcdecl->funcid;
  if (idptr == write_int_id || idptr == write_char_id ||
      idptr == write_string_id)
    return;
  char label[LABEL_MAXLEN];
  sprintf(label, "label_%d", label_offset);
  shift_sp(1); // return value
  push_const_label(label);
  push_reg("fp");
}

void func_call(decl_t *funcdecl) {
  id *idptr = funcdecl->funcid;
  if (funcdecl->returntype->typeclass == TYPE_STRUCT)
    func_flag = 1;
  if (idptr == write_int_id || idptr == write_char_id ||
      idptr == write_string_id)
    return;
  push_reg("sp");
  push_const_int(-num_args);
  gen_add();
  pop_reg("fp");
  jump(funcdecl->funcid->name, LABEL_PLAIN, 0, -1);
  make_label();
}

void func_epilogue(char *func_name) {
  gen_label(func_name, LABEL_FINAL);

  // restore registers
  push_reg("fp");
  pop_reg("sp");
  pop_reg("fp");
  pop_reg("pc");

  gen_label(func_name, LABEL_END);
}

void prepare_return(void) {
  push_reg("fp");
  push_const_int(-1);
  gen_add();
  push_const_int(-1);
  gen_add();
}

void gen_label(char *label, int flag) {
  char buf[MX];
  strncpy(buf, label, MX);
  switch (flag) {
  case LABEL_PLAIN:
    strcat(buf, ":\n");
    break;
  case LABEL_START:
    strcat(buf, "_start:\n");
    break;
  case LABEL_FINAL:
    strcat(buf, "_final:\n");
    break;
  case LABEL_END:
    strcat(buf, "_end:\n");
    break;
  }
  fwrite(buf, 1, strlen(buf), yyout);
}

void make_label(void) {
  char label[LABEL_MAXLEN];
  sprintf(label, "label_%d:\n", label_offset);
  fwrite(label, 1, strlen(label), yyout);
  label_offset++;
}

void make_label_offset(int offset) {
  char label[LABEL_MAXLEN];
  sprintf(label, "label_%d:\n", offset);
  fwrite(label, 1, strlen(label), yyout);
}

void gen_string(char *str) {
  char buf[MX];
  char label[MX];
  sprintf(label, "str_%d", str_offset);
  sprintf(buf, "str_%d. string \"%s\"\n", str_offset++, str);
  fwrite(buf, 1, strlen(buf), yyout);
  push_const_label(label);
}

void gen_globlabel(void) {
  char buf[MX];
  sprintf(buf, "Lglob.  data %d\n", glob_offset);
  fwrite(buf, 1, strlen(buf), yyout);
}

void push_const_int(int n) {
  char buf[MX];
  sprintf(buf, "        push_const %d\n", n);
  fwrite(buf, 1, strlen(buf), yyout);
}

void push_const_label(char *label) {
  char buf[MX];
  sprintf(buf, "        push_const %s\n", label);
  fwrite(buf, 1, strlen(buf), yyout);
}

void push_const_label_offset(char *label, int offset) {
  char buf[MX];
  sprintf(buf, "        push_const %s+%d\n", label, offset);
  fwrite(buf, 1, strlen(buf), yyout);
}

void push_reg(char *reg) {
  char buf[MX];
  sprintf(buf, "        push_reg %s\n", reg);
  fwrite(buf, 1, strlen(buf), yyout);
}

void pop_reg(char *reg) {
  char buf[MX];
  sprintf(buf, "        pop_reg %s\n", reg);
  fwrite(buf, 1, strlen(buf), yyout);
}

void shift_sp(int n) {
  char buf[MX];
  sprintf(buf, "        shift_sp %d\n", n);
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_negate(void) {
  char buf[MX];
  strcpy(buf, "        negate\n");
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_not(void) {
  char buf[MX];
  strcpy(buf, "        not\n");
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_abs(void) {
  char buf[MX];
  strcpy(buf, "        abs\n");
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_add(void) {
  char buf[MX];
  strcpy(buf, "        add\n");
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_sub(void) {
  char buf[MX];
  strcpy(buf, "        sub\n");
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_mul(void) {
  char buf[MX];
  strcpy(buf, "        mul\n");
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_div(void) {
  char buf[MX];
  strcpy(buf, "        div\n");
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_mod(void) {
  char buf[MX];
  strcpy(buf, "        mod\n");
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_and(void) {
  char buf[MX];
  strcpy(buf, "        and\n");
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_or(void) {
  char buf[MX];
  strcpy(buf, "        or\n");
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_equop(int op) {
  char buf[MX];
  if (op == OP_EQUAL)
    sprintf(buf, "        equal\n");
  else
    sprintf(buf, "        not_equal\n");
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_relop(int op) {
  char buf[MX];
  switch (op) {
  case OP_GREATER:
    strcpy(buf, "        greater\n");
    break;
  case OP_GREATER_EQUAL:
    strcpy(buf, "        greater_equal\n");
    break;
  case OP_LESS:
    strcpy(buf, "        less\n");
    break;
  case OP_LESS_EQUAL:
    strcpy(buf, "        less_equal\n");
    break;
  }
  fwrite(buf, 1, strlen(buf), yyout);
}

void jump(char *label, int label_flag, int offset, int label_num) {
  char buf[2 * MX];

  if (!label) {
    if (label_num >= 0) {
      sprintf(buf, "        jump label_%d\n", label_num);
    } else {
      sprintf(buf, "        jump %d\n", offset);
    }
    fwrite(buf, 1, strlen(buf), yyout);
    return;
  }

  // make label according to label_flag
  char label_buf[MX];
  strncpy(label_buf, label, MX);
  switch (label_flag) {
  case LABEL_START:
    strcat(label_buf, "_start");
    break;
  case LABEL_FINAL:
    strcat(label_buf, "_final");
    break;
  case LABEL_END:
    strcat(label_buf, "_end");
    break;
  }
  if (offset != 0) {
    sprintf(buf, "        jump %s %d\n", label_buf, offset);
  } else {
    sprintf(buf, "        jump %s\n", label_buf);
  }
  fwrite(buf, 1, strlen(buf), yyout);
}

void branch(int cond, char *label, int offset, int label_num) {
  char buf[MX];
  if (cond == TRUE) {
    if (label) {
      if (offset != 0)
        sprintf(buf, "        branch_true %s %d\n", label, offset);
      else
        sprintf(buf, "        branch_true %s\n", label);
    } else if (label_num >= 0) {
      sprintf(buf, "        branch_true label_%d\n", label_num);
    } else {
      sprintf(buf, "        branch_true %d\n", offset);
    }
  } else {
    if (label) {
      if (offset != 0)
        sprintf(buf, "        branch_false %s %d\n", label, offset);
      else
        sprintf(buf, "        branch_false %s\n", label);
    } else if (label_num >= 0) {
      sprintf(buf, "        branch_false label_%d\n", label_num);
    } else {
      sprintf(buf, "        branch_false %d\n", offset);
    }
  }
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_exit(void) {
  char buf[MX] = "        exit\n";
  fwrite(buf, 1, strlen(buf), yyout);
}

void assign(void) {
  char buf[MX] = "        assign\n";
  fwrite(buf, 1, strlen(buf), yyout);
}

void fetch(decl_t *declptr, int cond) {
  if (cond) {
    if (declptr->declclass != DECL_VAR || declptr->deref)
      return;
    if (declptr->type && declptr->type->typeclass == TYPE_STRUCT)
      return;
  }
  char buf[MX] = "        fetch\n";
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_incdec(int mode) {
  push_reg("sp");
  fetch(NULL, 0);
  push_reg("sp");
  fetch(NULL, 0);
  fetch(NULL, 0);
  if (mode == INC_PRE || mode == INC_POST)
    push_const_int(1);
  else
    push_const_int(-1);
  gen_add();
  assign();
  fetch(NULL, 0);
  if (mode == INC_POST) {
    push_const_int(1);
    gen_sub();
  } else if (mode == DEC_POST) {
    push_const_int(1);
    gen_add();
  }
}

void write_int(void) {
  char buf[MX] = "        write_int\n";
  fwrite(buf, 1, strlen(buf), yyout);
}

void write_char(void) {
  char buf[MX] = "        write_char\n";
  fwrite(buf, 1, strlen(buf), yyout);
}

void write_string(void) {
  char buf[MX] = "        write_string\n";
  fwrite(buf, 1, strlen(buf), yyout);
}
