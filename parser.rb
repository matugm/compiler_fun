class Parser
  def initialize(tokens)
    @tokens = tokens
    @debug  = false
  end

  def print_tree(ast)
    puts
    p ast
  end

  def term(tok)
    current = @tokens.shift
    abort "Parser: nil token found" unless current
    puts "Token: #{tok}" if @debug

    if current.class == tok || current.content == tok
      puts "Current: #{current} - Value: #{current.content}" if @debug
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

    puts "Condition: #{condition}" if @debug
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
    print_tree(ast) if @debug
    ast
  end

  def tag
    find_if || find_assignment || find_function_call || find_while || find_assignment_addition || tag99
  end

  def find_if
    if term("if")
      t = IF_STATEMENT.new(find_condition)

      t.body = tag

      term(CLOSING_BRACER)
      return t
    end
  end

  def find_function_call
    if look_ahead(IDENTIFIER) && look_ahead(OPENING_PARAMS, 1) && look_ahead(IDENTIFIER, 2) && look_ahead(CLOSING_PARAMS, 3)
      func = term(IDENTIFIER)
      term(OPENING_PARAMS)
      args = term(IDENTIFIER)
      term(CLOSING_PARAMS)
      FUNCTION_CALL.new(func, args)
    end
  end

  def find_while
    if term("while")
      t = WHILE_STATEMENT.new(find_condition)

      t.body = tag

      term(CLOSING_BRACER)
      return t
    end
  end
  # TokenSequence class
  def find_assignment_addition
    if (tokens = TokenSequence.find(self, IDENTIFIER, PLUS_EQUALS, NUMBER))
      ASSIGNMENT_ADDITION.new(tokens[0], tokens[2])
    end
  end

  def tag99
    term(IDENTIFIER)
  end

  def find_assignment
    if look_ahead(IDENTIFIER) && look_ahead(SINGLE_EQUALS, 1) && look_ahead(NUMBER, 2)
      variable = term(IDENTIFIER)
      term(SINGLE_EQUALS)
      value = term(NUMBER)
      ASSIGNMENT.new(variable, value)
    end
  end
end

class TokenSequence
  def self.find(parser, *tokens)
    indx = -1

    found =
    tokens.all? do |t|
      indx += 1
      parser.look_ahead(t, indx)
    end

    tokens.each { |t| parser.term(t) } if found
  end
end
