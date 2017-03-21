require './parse.rb'

code = File.pipe?(STDIN) ? STDIN.read : '123+4'
parser = RccParser.new
ast = parser.parse(code)
pp ast
