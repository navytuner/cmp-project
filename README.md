# C Compiler Front-End

A C compiler front-end built incrementally across four phases: lexical analysis, syntax analysis, semantic analysis, and stack-machine code generation. Developed as a series of compiler course assignments.

## Project Structure

```
project1/   Lexical Analysis (Flex)
project2/   Syntax Analysis (Flex + Bison)
project3/   Semantic Analysis (type checking, scope management)
project4/   Code Generation (stack-machine intermediate code + simulator)
```

Each phase builds on the previous one. The final result is a working compiler pipeline that takes a subset of C and produces executable stack-machine code.

## Supported C Subset

### Data Types
- `int`, `char`
- Pointers (`int*`, `char*`)
- Arrays (`int[N]`, `char[N]`)
- `struct` (including nested structs)
- `NULL` pointer literal

### Operators
- **Arithmetic**: `+`, `-`, `*`, `/`, `%`
- **Relational**: `<`, `<=`, `>`, `>=`, `==`, `!=`
- **Logical**: `&&`, `||`, `!`
- **Unary**: prefix/postfix `++`/`--`, unary `-`, address-of `&`, dereference `*`
- **Member access**: `.` (dot), `->` (arrow)
- **Array subscript**: `arr[i]`
- **Assignment**: `=`

### Control Flow
- `if` / `if-else`
- `while` with `break` and `continue`
- `for` loops
- `return`

### Functions
- Function declarations with parameters
- Return types: `int`, `char`, `struct`, pointers
- Built-in I/O: `write_int()`, `write_char()`, `write_string()`

## Build

Each project has its own Makefile. Requires `flex`, `bison`, and `gcc`.

```bash
# Build any phase
cd project4/src
make

# Run the compiler on a C source file
./subc < input.c

# For project4, run generated code with the stack machine simulator
cd ../simulator
make
./sim < ../result/output.s
```

## Compilation Phases

### Phase 1 — Lexical Analysis
Flex-based tokenizer that handles identifiers, keywords, number/string literals, operators, and nested `/* */` comments.

### Phase 2 — Syntax Analysis
Bison parser implementing the grammar for the C subset with proper operator precedence and associativity. Recognizes external definitions, function declarations, compound statements, and expressions.

### Phase 3 — Semantic Analysis
Adds type checking and scope management on top of the parser:
- Hierarchical symbol table with scope stack
- Type compatibility checking across assignments, operations, and function calls
- Error detection: undeclared/redeclared variables, type mismatches, invalid pointer/array/struct operations, argument count/type validation, return type checking

### Phase 4 — Code Generation
Generates stack-machine intermediate code from the type-checked AST:
- Stack-based instruction set (`push_const`, `fetch`, `assign`, `add`, `branch_false`, `jump`, etc.)
- Function call convention with frame pointer management
- Global data segment allocation
- Label-based control flow for loops and conditionals
- Struct assignment via byte-by-byte copy

Includes a stack machine simulator (`project4/simulator/`) that interprets the generated code.

## Stack Machine Architecture

```
Memory Layout:
  0–64KB       Stack area
  64KB–128KB   Code area
  128KB–192KB  Data area

Registers:
  fp   Frame pointer
  sp   Stack pointer
  pc   Program counter (implicit)
```

Example — compiling `int x; x = 3;` produces:
```asm
        push_const Lglob+0    # address of x
        push_reg sp
        fetch
        push_const 3
        assign                 # x = 3
```

## Tools Used

| Tool | Purpose |
|------|---------|
| Flex | Lexer generation |
| Bison | Parser generation |
| GCC | C compilation |

## Test Cases

- `project3/open_test/` — Semantic error detection tests (variable redeclaration, pointer ops, struct ops, function calls, expressions)
- `project4/open_test/` — Code generation tests (pointer dereference, variable assignment, increment, loops, strings)
- `project4/result/` — Generated stack-machine output for test cases
