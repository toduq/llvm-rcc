require './parse.rb'
require './compiler.rb'

code = File.pipe?(STDIN) ? STDIN.read : 'int a;123+4;'
parser = RccParser.new
ast = parser.parse(code)
ir = Compiler.new(ast).compile.ir
puts ir.join("\n")
