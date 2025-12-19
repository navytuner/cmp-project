struct str0 {
  int x;
  int y;
};

struct str {
  int x;
  int y;
  int z;
  int w[3];
  struct str0 u[2];
};

int main() {
  struct str a;
  struct str b;
  b.x = 1;
  b.y = 2;
  b.z = 3;
  b.w[0] = 4;
  b.w[1] = 5;
  b.w[2] = 6;
  b.u[0].x = 7;
  b.u[0].y = 8;
  b.u[1].x = 9;
  b.u[1].y = 10;
  a = b;
  write_int(a.x);
  write_int(a.y);
  write_int(a.z);
  write_int(a.w[0]);
  write_int(a.w[1]);
  write_int(a.w[2]);
  write_int(a.u[0].x);
  write_int(a.u[0].y);
  write_int(a.u[1].x);
  write_int(a.u[1].y);
  write_string("\n");
}