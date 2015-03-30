class Parser
  def initialize(tokens)
    @tokens = tokens
    @debug = false
  end

  def term(tok)
    current = @tokens.shift
    abort "nil token" unless current
    puts "Token: #{tok}" if @debug

    if current.class == tok || current.content == tok
      p "Current: #{current}" if @debug
      current.content
    else
      @tokens.unshift current
      false
      #abort "Expected #{tok} but #{current} was found instead."
    end
  end

  def look_ahead(tok, idx = 0)
    current = @tokens[idx]
    abort "nil token" unless current

    current.class == tok || current.content == tok
  end

  def find_condition
    condition = []

    p "Condition: #{condition}" if @debug
    until term(OPENING_BRACER)
      condition << @tokens.shift
    end

    condition
  end

  def parse_all
    ast = []
    while @tokens.any?
      ast << tag
    end
    ast
  end

  def tag
    tag1 || tag2 || tag3 || tag4 || tag5 || tag99
  end

  def tag1
    if term("if")
      t = IF_STATEMENT.new(find_condition)

      t.body = tag

      term(CLOSING_BRACER)
      return t
    end
  end

  def tag3
    if look_ahead(IDENTIFIER) && look_ahead(OPENING_PARAMS, 1) && look_ahead(IDENTIFIER, 2) && look_ahead(CLOSING_PARAMS, 3)
      func = term(IDENTIFIER)
      term(OPENING_PARAMS)
      args = term(IDENTIFIER)
      term(CLOSING_PARAMS)
      FUNCTION_CALL.new(func, args)
    end
  end

  def tag4
    if term("while")
      t = WHILE_STATEMENT.new(find_condition)

      t.body = tag

      term(CLOSING_BRACER)
      return t
    end
  end

  def tag5
    if look_ahead(IDENTIFIER) && look_ahead(PLUS_EQUALS, 1) && look_ahead(NUMBER, 2)
      variable = term(IDENTIFIER)
      term(PLUS_EQUALS)
      value = term(NUMBER)
      ASSIGNMENT_ADDITION.new(variable, value)
    end
  end

  def tag99
    term(IDENTIFIER)
  end

  def tag2
    if look_ahead(IDENTIFIER) && look_ahead(SINGLE_EQUALS, 1) && look_ahead(NUMBER, 2)
      variable = term(IDENTIFIER)
      term(SINGLE_EQUALS)
      value = term(NUMBER)
      ASSIGNMENT.new(variable, value)
    end
  end
end