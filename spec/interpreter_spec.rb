require_relative 'shared'
require_relative '../interpreter'

describe Interpreter do
  it "can save variables and execute built-in methods" do
    syntax_tree = get_ast("
    abc  = 30
    abc += 20
    puts(abc)")

    expect { Interpreter.new(syntax_tree) }.to output("50\n").to_stdout
  end

  it "can evaluate an if expression" do
    syntax_tree = get_ast('
    abc = "AAA"
    if 20 > 15 { abc = "CCC" }
    puts(abc)')

    #Interpreter.new(syntax_tree)
    expect { Interpreter.new(syntax_tree) }.to output("CCC\n").to_stdout
  end

  it "can have a string as a variable value" do
    syntax_tree = get_ast('
    str = "testing"
    puts(str)')

    expect { Interpreter.new(syntax_tree) }.to output("testing\n").to_stdout
  end

  it "can run a while loop" do
    syntax_tree = get_ast('
    count = 20
    while count < 100 {
      count += 20
    }
    puts(count)')

    expect { Interpreter.new(syntax_tree) }.to output("100\n").to_stdout
  end
end
