class Interpreter
  def init_symbol_table
    @symbol_table = {
      puts: ->(s) { puts s }
    }
  end

  def update_symbol_table(input)
    @symbol_table[input.variable] = input.value
  end

  def exec_from_symbol_table(input)
    args = @symbol_table[input.argument]
    func = @symbol_table[input.function.to_sym]
    func.call(args)
  end

  def execute
    instruction = @syntax_tree.shift

    if instruction.is_a? ASSIGNMENT
      update_symbol_table(instruction)
    end

    if instruction.is_a? ASSIGNMENT_ADDITION
      current_value = @symbol_table[instruction.variable]
      instruction.value = instruction.value.to_i + current_value.to_i
      update_symbol_table(instruction)
    end

    if instruction.is_a? FUNCTION_CALL
      exec_from_symbol_table(instruction)
    end
  end

  def initialize(ast)
    @syntax_tree  = ast
    init_symbol_table

    while @syntax_tree.any?
      execute
    end
  end
end
