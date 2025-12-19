int main() {
  int i;
  int j;

  for (i = 0; i < 3; i++) {
    for (j = 0; j < 3; j++) {
      if (j == 1) {
        continue;
      }
      write_int(i);
      write_char(' ');
      write_int(j);
      write_string("\n");
    }
    write_string("\n");
  }
}