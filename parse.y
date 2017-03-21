class RccParser
rule
  statement                 : additive_expression
                                {result = {type: :statement, value: val[0]}}
  additive_expression       : additive_expression additive_operator multiplicative_expression
                                {result = {type: :operator, value: val[1], left: val[0], right: val[2]}}
                            | multiplicative_expression

  multiplicative_expression : multiplicative_expression multiplicative_operator primary_expression
                                {result = {type: :operator, value: val[1], left: val[0], right: val[2]}}
                            | primary_expression

  primary_expression        : integer_constant
                                {result = {type: :integer_constant, value: val[0].to_i}}
end

---- header
require 'pp'
require 'strscan'

---- inner
attr_accessor :yydebug
attr_accessor :verbose

def parse(str)
  s = StringScanner.new(str)
  @q = []
  until s.eos?
    s.scan(/[-+]/)  ? @q << [:additive_operator, s.matched] :
    s.scan(/[*\/]/) ? @q << [:multiplicative_operator, s.matched] :
    s.scan(/\d+/)   ? @q << [:integer_constant, s.matched] :
    s.scan(/[ \n\r\t]/) ? nil :
        (raise "scanner error")
  end
  pp @q if verbose
  do_parse
end

def next_token
  @q.shift
end

---- footer
if __FILE__ == $0
  str = '1+2+3*4'
  parser = RccParser.new
  parser.yydebug = false
  parser.verbose = false
  pp parser.parse(str)
end