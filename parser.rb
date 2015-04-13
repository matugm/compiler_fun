class Parser
  def initialize(tokens)
    @tokens = tokens
    @debug  = false

    TokenSequence.parser = self
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
      expression = tag
      abort "Parsing error, no valid expression found.\n AST: #{ast} \n\n Remaining tokens: #{@tokens}" unless expression
      ast << expression
    end
    print_tree(ast) if @debug
    ast
  end

  def tag
    find_if || find_assignment || find_function_call ||
    find_while || find_assignment_addition ||
    find_assignment_substraction || tag99
  end

  # limitations: only 1 expression inside the if block
  # easily solved using 'until CLOSING_BRACER'
  def find_if
    if term("if")
      t = IF_STATEMENT.new(find_condition)

      t.body = tag

      term(CLOSING_BRACER)
      return t
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

  def find_function_call
    if (tokens = TokenSequence.find(IDENTIFIER, OPENING_PARAMS, IDENTIFIER, CLOSING_PARAMS))
      FUNCTION_CALL.new(tokens[0], tokens[2])
    end
  end

  def find_assignment
    if (tokens = TokenSequence.find(IDENTIFIER, SINGLE_EQUALS, NUMBER))
      return ASSIGNMENT.new(tokens[0], tokens[2])
    end

    if (tokens = TokenSequence.find(IDENTIFIER, SINGLE_EQUALS, STRING))
      return ASSIGNMENT.new(tokens[0], tokens[2])
    end
  end

  def find_assignment_addition
    if (tokens = TokenSequence.find(IDENTIFIER, PLUS_EQUALS, NUMBER))
      ASSIGNMENT_ADDITION.new(tokens[0], tokens[2])
    end
  end

  def find_assignment_substraction
    if (tokens = TokenSequence.find(IDENTIFIER, MINUS_EQUALS, NUMBER))
      ASSIGNMENT_SUBSTRACTION.new(tokens[0], tokens[2])
    end
  end

  def tag99
    term(IDENTIFIER)
  end

end

class TokenSequence
  def self.parser=(parser)
    @parser = parser
  end

  def self.find(*tokens)
    abort "Parser not set" unless @parser

    found =
    tokens.each_with_index.all? do |t, idx|
      @parser.look_ahead(t, idx)
    end

    tokens.map { |t| @parser.term(t) } if found
  end
end
