class Interpreter
  def init_symbol_table
    @symbol_table = {
      puts: ->(s) { puts s }
    }
  end

  def update_symbol_table(input)
    @symbol_table[input.variable] = input.value
  end

  def get_from_symbol_table(input)
    @symbol_table.fetch(input) {  }
  end

  def exec_from_symbol_table(input)
    args = get_from_symbol_table(input.argument)
    func = get_from_symbol_table(input.function.to_sym)
    func.call(args)
  end

  def evaluate_condition(input)
    op = input.condition[1]
    left_hand  = input.condition[0].content
    right_hand = input.condition[2].content

    if op.class == DOUBLE_EQUALS
      if left_hand == right_hand
        @syntax_tree.unshift(input.body)
      end
    end

    # if op.class == LESSER_THAN
    #   if left_hand < right_hand
    #     @syntax_tree.unshift input.body
    #   end
    # end
    #
    # if op.class == GREATER_THAN
    #   if left_hand > right_hand
    #     @syntax_tree.unshift input.body
    #   end
    # end
  end

  def execute
    instruction = @syntax_tree.shift
    #puts "Current instruction: #{instruction}"

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

    if instruction.is_a? IF_STATEMENT
      evaluate_condition(instruction)
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
