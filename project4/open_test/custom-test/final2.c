int main() {
  int i;
  int j;
  int sum;

  sum = 0;

  for (i = 0; i < 3; i++) {
    write_int(i);
    write_string("\n");
    for (j = 0; j < 5; j++) {
      if (j == 1) {
        break;
      }
      write_int(j);
      write_char(' ');
    }
    write_string("\n");
    if (i == 1) {
      continue;
    }
  }

  write_string("\n");
}