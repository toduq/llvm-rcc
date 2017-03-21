class RccParser
rule
  compound_statement        : statement
                                {result = {type: :compound_statement, list: [val[0]]}}
                            | compound_statement statement
                                {result[:list] << val[1]}
  statement                 : expression semicolon
                                {result = {type: :statement, value: val[0]}}
                            | declaration semicolon
                                {result = {type: :statement, value: val[0]}}

  expression                : additive_expression
  additive_expression       : additive_expression additive_operator multiplicative_expression
                                {result = {type: :operator, value: val[1], left: val[0], right: val[2]}}
                            | multiplicative_expression
  multiplicative_expression : multiplicative_expression multiplicative_operator primary_expression
                                {result = {type: :operator, value: val[1], left: val[0], right: val[2]}}
                            | primary_expression

  declaration               : type_name identifier
                                {result = {type: :declaration, type_name: val[0], name: val[1]}}
                            | type_name identifier assignment_operator expression
                                {result = {type: :declaration, type_name: val[0], name: val[1], value: val[3]}}

  type_name                 : identifier
  primary_expression        : integer_constant
                                {result = {type: :integer_constant, value: val[0].to_i}}
                            | identifier
                                {result = {type: :variable, name: val[0]}}

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
    s.scan(/[-+]/)             ? @q << [:additive_operator, s.matched] :
    s.scan(/[*\/]/)            ? @q << [:multiplicative_operator, s.matched] :
    s.scan(/[*\/]/)            ? @q << [:multiplicative_operator, s.matched] :
    s.scan(/=/)                ? @q << [:assignment_operator, s.matched] :
    s.scan(/\d+/)              ? @q << [:integer_constant, s.matched] :
    s.scan(/;/)                ? @q << [:semicolon, s.matched] :
    s.scan(/,/)                ? @q << [:comma, s.matched] :
    s.scan(/[A-z_][A-z0-9_]*/) ? @q << [:identifier, s.matched] :
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
  str = 'int a=3; 1+a+3*4;'
  parser = RccParser.new
  parser.yydebug = parser.verbose = true
  pp parser.parse(str)
end