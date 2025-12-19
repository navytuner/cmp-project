struct str {
  int x;
  int y;
};

int test(struct str a, struct str b) {
  write_int(a.x);
  write_int(a.y);
  write_int(b.x);
  write_int(b.y);
  write_string("\n");
}

int main() {
  struct str a;
  struct str b;
  b.x = 1;
  b.y = 2;
  a = b;
  test(a, b);
}
