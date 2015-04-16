
require_relative 'shared'
require_relative '../llvm_interpreter'

describe LLVM_Interpreter do
  it "can run a basic program via LLVM" do
    output = `ruby comp.rb samples/test.g`
    expect(output).to eq "10\n10\n"
  end

  it "can evaluate conditionals" do
    output = `ruby comp.rb samples/conditionals.g`
    expect(output).to eq "ok\n"
  end
end
