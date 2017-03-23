#!/bin/bash

LLI='lli'

function assertequal {
  if [ "$1" != "$2" ]; then
    echo "Test failed: $2 expected but got $1"
    exit
  fi
}

function assert {
  result=$(echo "$1" | ruby main.rb | lli)
  assertequal $result "$2"
}

assert 'return 1+2;' '3'
assert 'return 1+2*3;' '7'
assert 'int a; a=3; return a;'
assert 'int a=1; int b=2; return a*b;' '2'
assert 'int a=1+2; return a;' '3'

echo 'Test passed'
