require_relative 'llvm_engine'

class LLVM_Interpreter

  def execute
    instruction = @syntax_tree.shift
    #puts "Current instruction: #{instruction}"

    if instruction.is_a? ASSIGNMENT
      @engine.define_variable(instruction)
    end

    if instruction.is_a? ASSIGNMENT_ADDITION
      @engine.variable_add(instruction)
    end

    if instruction.is_a? ASSIGNMENT_SUBSTRACTION
      @engine.variable_sub(instruction)
    end

    if instruction.is_a? FUNCTION_CALL
      @engine.execute_method(instruction.function, instruction.argument)
    end

    if instruction.is_a? IF_STATEMENT
      @engine.evaluate_if(instruction)
      instruction.body.reverse.each { |i| @syntax_tree.unshift(i) }
    end

    if instruction.is_a? WHILE_STATEMENT
      @engine.evaluate_while(instruction)
      instruction.body.reverse.each { |i| @syntax_tree.unshift(i) }
    end

    if instruction == :END_IF
      @engine.end_block
    end

    if instruction == :END_WHILE
      @engine.end_while
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
