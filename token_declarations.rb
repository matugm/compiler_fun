
token_list = %w(
  NUMBER STRING IDENTIFIER KEYWORD
  OPENING_PARAMS CLOSING_PARAMS
  OPENING_BRACER CLOSING_BRACER
  SINGLE_EQUALS DOUBLE_EQUALS
  LESSER_THAN GREATER_THAN
  PLUS PLUS_EQUALS
)

token_list.each do |tok|
  klass = Object.const_set(tok, Class.new)
  klass.class_eval do
    attr_accessor :content
    define_method(:initialize) { |con| @content = con }
  end
end
