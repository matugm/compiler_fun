
class Lexer
  attr_reader :tokens

  def initialize(input)
    @buffer = input
    @tokens = []
    start
  end

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
    @buffer.scan(/\d+/)
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

  def check_for_substraction
    @buffer.getch
    @buffer.getch == " " ? MINUS.new('-') : MINUS_EQUALS.new('-=')
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
    when '>' then GREATER_THAN.new(@buffer.getch)
    when '<' then LESSER_THAN.new(@buffer.getch)
    when '=' then check_for_double_equals
    when '+' then check_for_addition
    when '-' then check_for_substraction
    when '"' then STRING.new(find_string)
    when /[0-9]/    then NUMBER.new(find_number)
    when /[a-zA-Z]/ then find_keyword_or_identifier
    else abort "Lexer: Invalid syntax at position #{@buffer.pos} '#{@buffer.inspect}'"
    end
  end
end
