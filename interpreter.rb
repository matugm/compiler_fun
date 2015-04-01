class Interpreter
  def init_symbol_table
    @symbol_table = {
      puts: ->(s) { puts s }
    }
  end

  def update_symbol_table(input)
    if input.is_a? NUMBER
      @symbol_table[input.variable] = input.value.to_i
    else
      @symbol_table[input.variable] = input.value
    end
  end

  def get_from_symbol_table(input)
    @symbol_table.fetch(input) {  }
  end

  def exec_from_symbol_table(input)
    args = get_from_symbol_table(input.argument)
    func = get_from_symbol_table(input.function.to_sym)
    func.call(args)
  end

  def get_value(val)
    if val.is_a? IDENTIFIER
      get_from_symbol_table(val.content)
    else
      val.content
    end
  end

  def evaluate_condition(input)
    op = input.condition[1]
    left_hand  = get_value(input.condition[0]).to_i
    right_hand = get_value(input.condition[2]).to_i

    if op.class == DOUBLE_EQUALS
      return left_hand == right_hand
    end

    if op.class == LESSER_THAN
      return left_hand < right_hand
    end

    if op.class == GREATER_THAN
      return left_hand > right_hand
    end
  end

  def execute
    instruction = @syntax_tree.shift
    #puts "Current instruction: #{instruction}"

    if instruction.is_a? ASSIGNMENT
      update_symbol_table(instruction)
    end

    if instruction.is_a? ASSIGNMENT_ADDITION
      current_value = @symbol_table[instruction.variable]
      new_value = current_value.to_i + instruction.value.to_i
      @symbol_table[instruction.variable] = new_value
    end

    if instruction.is_a? FUNCTION_CALL
      exec_from_symbol_table(instruction)
    end

    if instruction.is_a? IF_STATEMENT
      bool = evaluate_condition(instruction)
      @syntax_tree.unshift(instruction.body) if bool
    end

    if instruction.is_a? WHILE_STATEMENT
      bool = evaluate_condition(instruction)
      if bool
        @syntax_tree.unshift(instruction)
        @syntax_tree.unshift(instruction.body)
      end
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
