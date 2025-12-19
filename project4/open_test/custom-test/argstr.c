struct str {
  int x;
  int y;
  int z;
};

int func(struct str x, struct str y) {
  write_int(x.x);
  write_int(x.y);
  write_int(x.z);
  write_int(y.x);
  write_int(y.y);
  write_int(y.z);
  write_string("\n");
}

int main() {
  struct str x;
  struct str y;
  x.x = 1;
  x.y = 2;
  x.z = 3;
  y.x = 4;
  y.y = 5;
  y.z = 6;
  func(x, y);
}