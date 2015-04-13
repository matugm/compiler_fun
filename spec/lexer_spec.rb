require_relative 'shared'

require_relative '../lexer'
require_relative '../token_declarations'

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
