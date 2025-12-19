struct Vec2 {
  int x;
  int y;
};

struct Meta {
  struct Vec2 base;
  int samples[3];
};

struct Vec2 make_vec(int x, int y) {
  struct Vec2 result;
  result.x = x;
  result.y = y;
  return result;
}

int sum_components(struct Vec2 v) { return v.x + v.y; }

struct Vec2 add_vec(struct Vec2 left, struct Vec2 right) {
  struct Vec2 combined;
  combined.x = left.x + right.x;
  combined.y = left.y + right.y;
  return combined;
}

int main() {
  struct Vec2 base;
  struct Vec2 copy;
  struct Vec2 offset;
  struct Vec2 combined;
  int total;
  struct Meta meta_original;
  struct Meta meta_copy;

  base = make_vec(2, 5);
  copy = base;             /* struct assignment */
  offset = make_vec(7, 4); /* struct-returning function */

  combined = add_vec(copy, offset); /* struct parameters + return */
  total = sum_components(combined); /* struct parameter usage */

  write_string("== Test: Base vector initialization ==\n");
  write_string("Result: ");
  write_int(base.x);
  write_string(", ");
  write_int(base.y);
  write_string("\n");
  write_string("Ground truth : 2, 5\n\n");

  write_string("== Test: Struct assignment copy ==\n");
  write_string("Result: ");
  write_int(copy.x);
  write_string(", ");
  write_int(copy.y);
  write_string("\n");
  write_string("Ground truth -> Copy via assignment: 2, 5\n\n");

  write_string("== Test: Struct-returning make_vec ==\n");
  write_string("Result: ");
  write_int(offset.x);
  write_string(", ");
  write_int(offset.y);
  write_string("\n");
  write_string("Ground truth -> Offset vector: 7, 4\n\n");

  write_string("== Test: add_vec parameter passing ==\n");
  write_string("Result: ");
  write_int(combined.x);
  write_string(", ");
  write_int(combined.y);
  write_string("\n");
  write_string("Ground truth -> Combined vector: 9, 9\n\n");

  write_string("== Test: sum_components parameter passing ==\n");
  write_string("Result: ");
  write_int(total);
  write_string("\n");
  write_string("Ground truth -> Total sum: 18\n\n");

  meta_original.base = base;
  meta_original.samples[0] = 10;
  meta_original.samples[1] = 20;
  meta_original.samples[2] = 30;
  meta_copy = meta_original;

  write_string("== Test: Nested struct assignment ==\n");
  write_string("Result: ");
  write_int(meta_copy.base.x);
  write_string(", ");
  write_int(meta_copy.base.y);
  write_string("\n");
  write_string("Ground truth -> Nested struct copy: 2, 5\n\n");

  write_string("== Test: Embedded array copy ==\n");
  write_string("Result: ");
  write_int(meta_copy.samples[0]);
  write_string(", ");
  write_int(meta_copy.samples[1]);
  write_string(", ");
  write_int(meta_copy.samples[2]);
  write_string("\n");
  write_string("Ground truth -> Array copy: 10, 20, 30\n");
  return 0;
}
