
require_relative 'token_declarations'
require_relative 'parser_declarations'

require_relative 'lexer'
require_relative 'parser'
require_relative 'llvm_interpreter'

require 'strscan'

####################
# Read input file
####################

lines = File.readlines(ARGV[0])
@buffer = StringScanner.new(lines.join.strip)

##########################################
# Scan source code for tokens
##########################################

@tokens = Lexer.new(@buffer).tokens
# puts "\n******** lexer output *********\n\n"
# p @tokens

##########################################
# Parser starts here (recursive-descent)
##########################################

@syntax_tree = Parser.new(@tokens).parse_all
# puts "\n******** parser output *********\n\n"
# p @syntax_tree

################################
# Interpreter starts here
################################

LLVM_Interpreter.new(@syntax_tree)
