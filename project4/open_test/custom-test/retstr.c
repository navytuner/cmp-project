struct str {
  int x;
  int y;
  int z;
};

struct str func(int a, int b, int c) {
  struct str res;
  res.x = a;
  res.y = b;
  res.z = c;
  return res;
}

int main() {
  struct str a;
  a = func(1, 2, 3);
  write_int(a.x);
  write_int(a.y);
  write_int(a.z);
  write_string("\n");
}