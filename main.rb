require './parse.rb'
require './compiler.rb'

code = File.pipe?(STDIN) ? STDIN.read : 'int a;123+4;'
parser = RccParser.new
ast = parser.parse(code)
puts Compiler.new(ast).compile.mod.to_s
