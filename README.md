# Cautious

C AUtomated Testing In One Useful Script

A POSIX shell script for unit testing C programs.

## Tests

All tests must be functions with no parameters and `void` return type,
and they must be marked with the `ctest_` prefix.
For assertions the standard `assert.h` header should be used
(or anything that on success does nothing and on failure aborts execution and returns a non-zero exit code).

```c
#include <assert.h>

void ctest_numbers_still_work(void) {
  int x = 1;
  int y = 2;
  assert(x + y == 3);
}
```

## Usage

Compile all test functions into an object file then call `cautios.sh` on it:

```sh
cc my_tests.c -c -o my_tests.o && ./cautious.sh my_tests.o
```
