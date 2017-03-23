require 'llvm'
require 'llvm/core'

require 'pp'
require 'pry'

@module = LLVM::Module.new("rcc")
@printf = @module.functions.add("printf", [LLVM::Pointer(LLVM::Int8)], LLVM::Int, varargs: true)
@function = @module.functions.add("main", [], LLVM::Int)
@entry_block = @function.basic_blocks.append("entry")

@entry_builder = LLVM::Builder.new
@entry_builder.position_at_end(@entry_block)

@sum = @entry_builder.add(LLVM::Int.from_i(1), LLVM::Int.from_i(2))

@entry_builder.call(@printf, @entry_builder.global_string("%d\n"), @sum)
@entry_builder.ret(LLVM::Int.from_i(0))

@module.dump
