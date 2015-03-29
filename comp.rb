
require_relative 'token_declarations'
require_relative 'parser_declarations'
require_relative 'test_code'

require_relative 'lexer'
require_relative 'parser'
require_relative 'interpreter'

# @tokens = [...objects...]
# symbolos > strings (peek == "") > numeros > letras (keyword / identifier)
# 1 clase por token

##########################################
# Scan source code for tokens
###########################################

@tokens = Lexer.new(@buffer).tokens
p @tokens

##########################################
# Parser starts here (recursive-descent)
###########################################

@syntax_tree = Parser.new(@tokens).parse_all
puts "\n******** output *********\n\n"
p @syntax_tree

################################
# Interpreter starts here
################################

Interpreter.new(@syntax_tree)
