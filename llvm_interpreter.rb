require_relative 'llvm_engine'

class Interpreter

  def execute
    instruction = @syntax_tree.shift
    #puts "Current instruction: #{instruction}"

    if instruction.is_a? ASSIGNMENT
      @engine.define_variable(instruction)
    end

    if instruction.is_a? ASSIGNMENT_ADDITION
      @engine.variable_add(instruction)
    end

    if instruction.is_a? FUNCTION_CALL
      @engine.execute_method(instruction.function, instruction.argument)
    end

    if instruction.is_a? IF_STATEMENT
      @engine.evaluate_if(instruction)
      @syntax_tree.unshift(instruction.body)
      @depth = true and return
    end

    if instruction.is_a? WHILE_STATEMENT
      @engine.evaluate_while(instruction)
      @syntax_tree.unshift(instruction.body)
      @while = true and return
    end

    if @depth
      @engine.end_block
      @depth = false
    end

    if @while
      @engine.end_while
      @while = false
    end
  end

  def initialize(ast)
    @syntax_tree  = ast
    @engine = LLVM_Engine.new

    @depth = false

    while @syntax_tree.any?
      execute
    end
    @engine.run
  end
end
