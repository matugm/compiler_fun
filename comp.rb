class NUMBER < Struct.new(:content)
end

class STRING < Struct.new(:content)
end

class IDENTIFIER < Struct.new(:content)
end

class KEYWORD < Struct.new(:content)
end

class OPENING_PARAMS < Struct.new(:content)
end

class CLOSING_PARAMS < Struct.new(:content)
end

class OPENING_BRACER < Struct.new(:content)
end

class CLOSING_BRACER < Struct.new(:content)
end

class SINGLE_EQUALS < Struct.new(:content)
end

class DOUBLE_EQUALS < Struct.new(:content)
end

class PLUS < Struct.new(:content)
end

class PLUS_EQUALS < Struct.new(:content)
end


#@tokens = [...objects...]

# symbolos > strings (peek == "") > numeros > letras (keyword / identifier)
# 1 clase por token

# recursive-descent parser
require 'strscan'
@buffer = StringScanner.new(
  '(100) "testing!123"
  if test == 1 {
    while testing {
      a = 3
    }
  }
  ()'
)

@buffer = StringScanner.new(
  'test = 1
   abc  = 3
   if test == 1 {
     while testing {
       a = 3
     }
   puts (abc)
  }'
)

@buffer = StringScanner.new(
  'test = 2
   abc  = 10
   test = 500
   test += 10
   puts(test)
   if test == 1 {
    while testing {
      a = 3
    }
   }'
)

@tokens = []

def start
  until @buffer.eos?
    @tokens << parse
  end

  @tokens
end

def skip_spaces
  @buffer.skip(/\s+/)
end

def find_number
  result = @buffer.scan(/\d+/)
end

def find_string
  @buffer.getch
  @buffer.scan_until(/"/).chop
end

KEYWORDS = %w(if unless while until def)
def find_keyword_or_identifier
  word = @buffer.scan(/\w+/)

  if KEYWORDS.include? word
    KEYWORD.new word
  else
    IDENTIFIER.new word
  end
end

def check_for_addition
  @buffer.getch
  @buffer.getch == " " ? PLUS.new('+') : PLUS_EQUALS.new('+=')
end

def check_for_double_equals
  @buffer.getch
  @buffer.getch == " " ? SINGLE_EQUALS.new('=') : DOUBLE_EQUALS.new('==')
end

def parse
  skip_spaces
  peek = @buffer.peek(1)

  case peek
  when '(' then OPENING_PARAMS.new(@buffer.getch)
  when ')' then CLOSING_PARAMS.new(@buffer.getch)
  when '{' then OPENING_BRACER.new(@buffer.getch)
  when '}' then CLOSING_BRACER.new(@buffer.getch)
  when '=' then check_for_double_equals
  when '+' then check_for_addition
  when '"' then STRING.new(find_string)
  when /[0-9]/    then NUMBER.new(find_number)
  when /[a-zA-Z]/ then find_keyword_or_identifier
  else abort "Invalid syntax at position #{@buffer.pos} '#{peek}'"
  end
end

@tokens = start
p @tokens

##########################################
# Parser starts here
###########################################

class IF_STATEMENT
  attr_accessor :body

  def initialize(condition)
    @condition = condition
  end
end

class WHILE_STATEMENT
  attr_accessor :body

  def initialize(condition)
    @condition = condition
  end
end

class ASSIGNMENT
  attr_reader :variable, :value
  def initialize(variable, value)
    @variable = variable
    @value    = value
  end
end

class ASSIGNMENT_ADDITION
  attr_reader :variable, :value
  attr_accessor :value
  def initialize(variable, value)
    @variable = variable
    @value    = value
  end
end

class FUNCTION_CALL
  attr_reader :function, :argument
  def initialize(function, argument)
    @function = function
    @argument = argument
  end
end

@debug = false

# term for class based tokens

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

# Se come los primeros aunque no formen una expresión
def tag2
  if look_ahead(IDENTIFIER) && look_ahead(SINGLE_EQUALS, 1) && look_ahead(NUMBER, 2)
    variable = term(IDENTIFIER)
    term(SINGLE_EQUALS)
    value = term(NUMBER)
    ASSIGNMENT.new(variable, value)
  end
end

@syntax_tree = parse_all
puts "\n******** output *********\n\n"
p @syntax_tree

##############################

@symbol_table = {
  puts: ->(s) { puts s }
}

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

while @syntax_tree.any?
  execute
end
