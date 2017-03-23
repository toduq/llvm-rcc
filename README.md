# llvm-rcc

C -> LLVM-IR compiler (llvm frontend of c) impelemented by ruby.  
This project's target is exactly the same as `clang`, although this is my hobby.

I'm developing this project for my research.

## How it works?

Tokenize : strscan  
Parse : racc `parse.y`  
Compile : `compiler.rb`  
Execute : LLVM `lli`
