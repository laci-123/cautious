#!/usr/bin/sh

object_file="$1"

function print_c_file() {
  echo "#include <stdio.h>"                    >  "$1"
  echo "void $function(void);"                 >> "$1"
  echo "int main(void){"                       >> "$1"
  echo "    setvbuf(stdout, NULL, _IONBF, 0);" >> "$1"
  echo "    $function();"                      >> "$1"
  echo "    return 0;"                         >> "$1"
  echo "}"                                     >> "$1"
}

for function in $(nm "$object_file" | grep -o "ctest_[a-zA-Z-]*")
do
  print_c_file "$function.c"
  cc "$function.c" main.o -o "$function"
  if { ./"$function"; } > "$function.stdout.txt" 2> "$function.stderr.txt"
  then
    echo "[PASS] $function"
  else
    echo "[FAIL] $function"
    echo "  stdout:"
    cat "$function.stdout.txt" | sed 's/^/    /'
    echo "  stderr:"
    cat "$function.stderr.txt" | sed 's/^/    /' | sed 's|./"\$function"$||'
  fi
done
