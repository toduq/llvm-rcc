class RccParser
rule
  compound_statement        : statement
                                {result = {type: :compound_statement, list: [val[0]]}}
                            | compound_statement statement
                                {result[:list] << val[1]}
  statement                 : expression ';'
                                {result = {type: :statement, value: val[0]}}
                            | declaration ';'
                                {result = {type: :statement, value: val[0]}}
                            | return_statement ';'
                                {result = {type: :statement, value: val[0]}}

  return_statement          : 'return' expression
                                {result = {type: :return, value: val[1]}}

  expression                : additive_expression
                            | assignment_operator
                            | function_call

  assignment_operator       : var_name '=' expression
                                {result = {type: :operator, value: val[1], left: val[0], right: val[2]}}

  additive_expression       : additive_expression additive_operator multiplicative_expression
                                {result = {type: :operator, value: val[1], left: val[0], right: val[2]}}
                            | multiplicative_expression
  multiplicative_expression : multiplicative_expression multiplicative_operator primary_expression
                                {result = {type: :operator, value: val[1], left: val[0], right: val[2]}}
                            | primary_expression

  function_call             : func_name '(' ')'
                                {result = {type: :call, name: val[0], args: []}}
                            | func_name '(' function_call_args ')'
                                {result = {type: :call, name: val[0], args: val[2]}}
  function_call_args        : expression
                                {result = [val[0]]}
                            | function_call_args ',' expression
                                {result << val[2]}

  declaration               : type_name var_name
                                {result = {type: :declaration, type_name: val[0], name: val[1]}}
                            | type_name var_name '=' expression
                                {result = {type: :declaration, type_name: val[0], name: val[1], value: val[3]}}

  primary_expression        : integer_constant
                                {result = {type: :integer_constant, value: val[0].to_i}}
                            | single_quote
                                {result = {type: :char_constant, value: val[0]}}
                            | double_quote
                                {result = {type: :string_constant, value: val[0]}}
                            | var_name
                                {result = {type: :variable, name: val[0]}}

  func_name                 : identifier
  type_name                 : identifier
  var_name                  : identifier
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
    s.scan(/return|;|,|=|\(|\)/) ? @q << [s.matched, s.matched] :
    s.scan(/'([^']+)'/)          ? @q << [:single_quote, s.matched[1..-2]] :
    s.scan(/"([^"]+)"/)          ? @q << [:double_quote, s.matched[1..-2]] :
    s.scan(/[-+]/)               ? @q << [:additive_operator, s.matched] :
    s.scan(/[*\/]/)              ? @q << [:multiplicative_operator, s.matched] :
    s.scan(/[*\/]/)              ? @q << [:multiplicative_operator, s.matched] :
    s.scan(/\d+/)                ? @q << [:integer_constant, s.matched] :
    s.scan(/[A-z_][A-z0-9_]*/)   ? @q << [:identifier, s.matched] :
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
  str = %(int a=3; 1+a+3*'a'; return add(a,3);)
  parser = RccParser.new
  parser.yydebug = parser.verbose = true
  pp parser.parse(str)
end