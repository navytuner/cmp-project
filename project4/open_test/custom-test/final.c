struct str {
  int x;
  int y;
};

int main() {
  struct str a;
  struct str b;
  struct str c;
  c.x = 1;
  c.y = 2;
  b = c;
  write_int(b.x);
  write_int(b.y);
  write_int(c.x);
  write_int(c.y);
  write_string("\n");
}