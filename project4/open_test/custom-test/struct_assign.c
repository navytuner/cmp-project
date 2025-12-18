struct str {
  int x;
  int y;
  int z;
};

int main() {
  struct str a;
  struct str b;
  b.x = 1;
  b.y = 2;
  b.z = 3;
  a = b;
  write_int(a.x);
  write_int(a.y);
  write_int(a.z);
}