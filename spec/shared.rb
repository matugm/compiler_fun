require 'strscan'

def get_tokens(input)
  @buffer = StringScanner.new input
  Lexer.new(@buffer).tokens
end

def get_ast(input)
  tok = get_tokens(input)
  Parser.new(tok).parse_all
end
