#include "subc.h"
#include "subc.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MX 500

FILE *yyout;

void push_const(int n) {
  char buf[MX];
  sprintf(buf, "        push_const %d\n", n);
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

void binary_negate(void) {
  char buf[MX];
  strncpy(buf, "        negate\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void binary_not(void) {
  char buf[MX];
  strncpy(buf, "        not\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void binary_abs(void) {
  char buf[MX];
  strncpy(buf, "        abs\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void binary_add(void) {
  char buf[MX];
  strncpy(buf, "        add\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void binary_sub(void) {
  char buf[MX];
  strncpy(buf, "        sub\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void binary_mul(void) {
  char buf[MX];
  strncpy(buf, "        mul\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void binary_div(void) {
  char buf[MX];
  strncpy(buf, "        div\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void binary_mod(void) {
  char buf[MX];
  strncpy(buf, "        mod\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void binary_and(void) {
  char buf[MX];
  strncpy(buf, "        and\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void binary_or(void) {
  char buf[MX];
  strncpy(buf, "        or\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void binary_equal(void) {
  char buf[MX];
  strncpy(buf, "        equal\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void binary_not_equal(void) {
  char buf[MX];
  strncpy(buf, "        not_equal\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void binary_greater(void) {
  char buf[MX];
  strncpy(buf, "        greater\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void binary_greater_equal(void) {
  char buf[MX];
  strncpy(buf, "        greater_equal\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void binary_less(void) {
  char buf[MX];
  strncpy(buf, "        less\n", MX);
  fwrite(buf, 1, strlen(buf), yyout);
}

void binary_less_equal(void) {
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

void fetch(void) {
  char buf[MX] = "        fetch\n";
  fwrite(buf, 1, strlen(buf), yyout);
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
