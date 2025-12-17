#include "subc.h"
#include "subc.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MX 500
extern FILE *yyout;

int strnum;

void init_gen(void) {
  strnum = 0;
  push_const_label("EXIT");
  push_reg("fp");
  push_reg("sp");
  pop_reg("fp");
  jump("main", 0);
  gen_label("EXIT", LABEL_PLAIN);
  gen_exit();
}

void load_var(id *idptr) {
  decl_t *decl = lookup_cur(idptr);
  char buf[MX];

  if (!decl) {
    decl = find_decl(scope[SCOPE_GLOB], idptr);
    if (decl->glob)
      push_const_label_offset("Lglob", decl->offset);
  } else {
    if (decl->declclass != DECL_VAR)
      return;
    push_reg("fp");
    push_const_int(decl->offset + 1);
    gen_add();
  }
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

void gen_string(char *str) {
  char buf[MX];
  sprintf(buf, "str_%d. string \"%s\"", strnum++, str);
  fwrite(buf, 1, strlen(buf), yyout);
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
  strncpy(buf, "        negate\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_not(void) {
  char buf[MX];
  strncpy(buf, "        not\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_abs(void) {
  char buf[MX];
  strncpy(buf, "        abs\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_add(void) {
  char buf[MX];
  strncpy(buf, "        add\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_sub(void) {
  char buf[MX];
  strncpy(buf, "        sub\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_mul(void) {
  char buf[MX];
  strncpy(buf, "        mul\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_div(void) {
  char buf[MX];
  strncpy(buf, "        div\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_mod(void) {
  char buf[MX];
  strncpy(buf, "        mod\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_and(void) {
  char buf[MX];
  strncpy(buf, "        and\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_or(void) {
  char buf[MX];
  strncpy(buf, "        or\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_equal(void) {
  char buf[MX];
  strncpy(buf, "        equal\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_not_equal(void) {
  char buf[MX];
  strncpy(buf, "        not_equal\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_greater(void) {
  char buf[MX];
  strncpy(buf, "        greater\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_greater_equal(void) {
  char buf[MX];
  strncpy(buf, "        greater_equal\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_less(void) {
  char buf[MX];
  strncpy(buf, "        less\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void gen_less_equal(void) {
  char buf[MX];
  strncpy(buf, "        less_equal\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void jump(char *label, int offset) {
  char buf[MX];
  if (label) {
    if (offset != 0) {
      sprintf(buf, "        jump %s %d\n", label, offset);
    } else {
      sprintf(buf, "        jump %s\n", label);
    }
  } else if (offset != 0) {
    sprintf(buf, "        jump %d\n", offset);
  }
  fwrite(buf, 1, strlen(buf), yyout);
}

void branch(int cond, char *label, int offset) {
  char buf[MX];
  if (cond == TRUE) {
    if (label) {
      if (offset != 0)
        sprintf(buf, "        branch_true %s %d\n", label, offset);
      else
        sprintf(buf, "        branch_true %s\n", label);
    } else if (offset != 0)
      sprintf(buf, "        branch_true %d\n", offset);
  } else {
    if (label) {
      if (offset != 0)
        sprintf(buf, "        branch_false %s %d\n", label, offset);
      else
        sprintf(buf, "        branch_false %s\n", label);
    } else if (offset != 0)
      sprintf(buf, "        branch_false %d\n", offset);
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
  if (cond && declptr->declclass != DECL_VAR)
    return;
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
