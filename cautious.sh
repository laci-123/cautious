#!/usr/bin/sh

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

function print_usage() {
  echo "Usage:"
  echo "$0 [objfile]"  
}


if [ "$#" -lt 1 ]
then
  echo "No arguments provided"
  echo ""
  print_usage
  exit 1
fi

object_file="$1"
if ! nm "$object_file" > /dev/null 2>&1
then
  echo "$object_file is not an object file"
  echo ""
  print_usage
  exit 1
fi

tmp_dir=$(mktemp --directory)

declare -i pass_count=0
declare -i fail_count=0

for function in $(nm "$object_file" | grep -o "ctest_[a-zA-Z-]*")
do
  print_c_file "$tmp_dir/$function.c"
  cc "$tmp_dir/$function.c" "$object_file" -o "$tmp_dir/$function"
  if { "$tmp_dir/$function"; } > "$tmp_dir/$function.stdout.txt" 2> "$tmp_dir/$function.stderr.txt"
  then
    pass_count+=1
    echo -e "${BLUE}${BOLD}[${GREEN}${BOLD}PASS${BLUE}${BOLD}] $function${RESET}"
  else
    fail_count+=1
    echo -e "${BLUE}${BOLD}[${RED}${BOLD}FAIL${BLUE}${BOLD}] $function${RESET}"
    echo "  stdout:"
    cat "$tmp_dir/$function.stdout.txt" | sed 's/^/    /'
    echo "  stderr:"
    cat "$tmp_dir/$function.stderr.txt" | sed 's/^/    /' | sed 's|"\$tmp_dir/\$function"$||' | grep --color=always '^\|Assertion .* failed'
  fi
done

echo ""
echo ""
echo -e "${BLUE}${BOLD}passed: ${GREEN}${BOLD}$pass_count ${BLUE}${BOLD}failed: ${RED}${BOLD}$fail_count$RESET"

rm -rf "$tmp_dir"
