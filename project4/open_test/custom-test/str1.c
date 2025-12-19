int global_1;
int global_2;

struct _st2 {
  int z;
  int w[5];
};

struct _str1 {
  int x;
  int y[3];
  struct _st2 strstr;

} sample_str;

int main() {
  int i;
  int j;
  int k;
  int *l;
  struct _str1 teststr[10];
  struct _str1 teststr2;

  i = 7;

  teststr[i].y[1] = i - 10;
  teststr2 = teststr[i];
  j = teststr2.y[1];

  write_int(j);
  write_string("\n");
}
