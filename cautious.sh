#!/usr/bin/sh

object_file="$1"

BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

function print_c_file() {
  echo "#include <stdio.h>"                    >  "$1"
  echo "void $function(void);"                 >> "$1"
  echo "int main(void){"                       >> "$1"
  echo "    setvbuf(stdout, NULL, _IONBF, 0);" >> "$1"
  echo "    $function();"                      >> "$1"
  echo "    return 0;"                         >> "$1"
  echo "}"                                     >> "$1"
}

declare -i pass_count=0
declare -i fail_count=0

for function in $(nm "$object_file" | grep -o "ctest_[a-zA-Z-]*")
do
  print_c_file "$function.c"
  cc "$function.c" "$object_file" -o "$function"
  if { ./"$function"; } > "$function.stdout.txt" 2> "$function.stderr.txt"
  then
    pass_count+=1
    echo -e "${BLUE}${BOLD}[${GREEN}${BOLD}PASS${BLUE}${BOLD}] $function${RESET}"
  else
    fail_count+=1
    echo -e "${BLUE}${BOLD}[${RED}${BOLD}FAIL${BLUE}${BOLD}] $function${RESET}"
    echo "  stdout:"
    cat "$function.stdout.txt" | sed 's/^/    /'
    echo "  stderr:"
    cat "$function.stderr.txt" | sed 's/^/    /' | sed 's|./"\$function"$||' | grep --color=always '^\|Assertion .* failed'
  fi
done

echo ""
echo ""
echo -e "${BLUE}${BOLD}passed: ${GREEN}${BOLD}$pass_count ${BLUE}${BOLD}failed: ${RED}${BOLD}$fail_count$RESET"
