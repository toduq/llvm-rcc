require './parse.rb'
require './compiler.rb'
code = File.pipe?(STDIN) ? STDIN.read : '123+4'
parser = RccParser.new
ast = parser.parse(code)
# pp ast
ir = Compiler.new(ast).compile.ir
# pp ir
puts ir.join("\n")
