require 'strscan'

require_relative 'lexer'
require_relative 'token_declarations'

require_relative 'parser'
require_relative 'parser_declarations'

def get_tokens(input)
  @buffer = StringScanner.new input
  Lexer.new(@buffer).tokens
end

def get_ast(input)
  tok = get_tokens(input)
  Parser.new(tok).parse_all
end

describe Lexer do
  it "can parse strings" do
    tok = get_tokens('"hello.....world"')
    expect(tok.first).to be_a STRING
    expect(tok.first.content).to eq 'hello.....world'
  end

  it "can parse numbers" do
    tok = get_tokens('12345')
    expect(tok.first).to be_a NUMBER
    expect(tok.first.content).to eq '12345'
  end

  it "can parse parens" do
    tok = get_tokens('(())')
    expect(tok.first).to be_a OPENING_PARAMS
    expect(tok.last).to  be_a CLOSING_PARAMS
  end
end

describe Parser do
  it "can parse an if statement" do
    syntax_tree = get_ast('if age == 100 { }')
    expect(syntax_tree.first).to be_a IF_STATEMENT
  end

  it "can parse variable assignment" do
    syntax_tree = get_ast('abc = 50')
    expect(syntax_tree.first).to be_a ASSIGNMENT
  end
end

@buffer = StringScanner.new(
  'test = 1
   abc  = 3
   if test == 1 {
     while testing {
       a = 3
     }
   puts (abc)
  }'
)

@buffer = StringScanner.new(
  'test = 2
   abc  = 10
   test = 500
   test += 10
   puts(test)
   if test == 1 {
    while testing {
      a = 3
    }
   }'
)
