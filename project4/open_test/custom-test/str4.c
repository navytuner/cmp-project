struct str {
  int x;
  int y;
};

int test(struct str a) {
  write_int(a.x);
  write_int(a.y);
  write_string("\n");
}

struct str test2(int x, int y) {
  struct str res;
  res.x = x;
  res.y = y;
  return res;
}

int main() {
  struct str a;
  struct str b;
}