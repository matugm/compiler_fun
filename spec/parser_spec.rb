require_relative 'shared'

require_relative '../parser'
require_relative '../parser_declarations'

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
    expect(syntax_tree[5].body[0]).to be_a WHILE_STATEMENT
    expect(syntax_tree[5].body[0].body[0]).to be_a ASSIGNMENT
  end
end

require_relative '../token_declarations'
require_relative '../lexer'

describe TokenSequence do
  before do
    tokens = get_tokens("a = 1")
    parser = Parser.new(tokens)
    TokenSequence.parser = parser
  end

  it "can find a sequence of tokens" do
    tokens = TokenSequence.find(IDENTIFIER, SINGLE_EQUALS).last(NUMBER)
    expect(tokens.size).to eq 3
  end

  it "can work with optional tokens" do
    tokens = TokenSequence.find(IDENTIFIER, SINGLE_EQUALS).multi([NUMBER, STRING])
    expect(tokens.size).to eq 3
  end
end
