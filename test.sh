#!/bin/bash

LLI='lli'

function assertequal {
  if [ "$1" != "$2" ]; then
    echo "Test failed: $2 expected but got $1"
    exit
  fi
}

function assert_ret {
  echo "$1" | ruby main.rb | lli
  assertequal "$?" "$2"
}

function assert_stdin {
  result=$(echo "$1" | ruby main.rb | lli)
  assertequal $result "$2"
}

function compile_fail {
	echo "$1" | ruby main.rb 2>/dev/null
	assertequal "$?" "1"
}

assert_ret 'return 1+2;' '3'
assert_ret 'return 1+2*3;' '7'

assert_ret 'int a; a=3; return a;' '3'
assert_ret 'int a=1+2; int b=2; return a*b;' '6'
compile_fail 'return abc;'

assert_ret 'return add(1,2);' '3'
assert_stdin 'printf("abc"); return 0;' 'abc'

assert_ret "return 'A';" '65'
compile_fail "return 'ab';"

echo 'Test passed'
