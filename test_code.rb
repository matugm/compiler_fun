require 'strscan'

require_relative 'lexer'
require_relative 'token_declarations'

require_relative 'parser'
require_relative 'parser_declarations'

require_relative 'llvm_interpreter'

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

  it "can generate a correct syntax tree" do
    syntax_tree = get_ast(
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

    expect(syntax_tree.first).to be_a ASSIGNMENT
    expect(syntax_tree[1]).to be_a ASSIGNMENT
    expect(syntax_tree[2]).to be_a ASSIGNMENT
    expect(syntax_tree[3]).to be_a ASSIGNMENT_ADDITION
    expect(syntax_tree[4]).to be_a FUNCTION_CALL
    expect(syntax_tree[5]).to be_a IF_STATEMENT
    expect(syntax_tree[5].body).to be_a WHILE_STATEMENT
    expect(syntax_tree[5].body.body).to be_a ASSIGNMENT
  end
end

describe Interpreter do
  xit "can save variables and execute built-in methods" do
    syntax_tree = get_ast("
    abc  = 30
    puts(abc)")

    expect { Interpreter.new(syntax_tree) }.to output("30\n").to_stdout
  end

  xit "can evaluate an if expression" do
    syntax_tree = get_ast('
    abc = "AAA"
    if 100 > 15 { abc = "CCC" }
    puts(abc)')

    Interpreter.new(syntax_tree)
    expect { Interpreter.new(syntax_tree) }.to output("40\n").to_stdout
  end

  xit "can have a string as a variable value" do
    syntax_tree = get_ast('
    str = "testing"
    puts(str)')

    expect { Interpreter.new(syntax_tree) }.to output("testing\n").to_stdout
  end

  it "can run a while loop" do
    syntax_tree = get_ast('
    count = 120
    while count < 100 {
      puts(count)
    }')

    expect { Interpreter.new(syntax_tree) }.to output("100\n").to_stdout
  end
end
