
require 'llvm/execution_engine'
require 'llvm/core'
include LLVM

INT = LLVM::Int
PCHAR = LLVM::Pointer(LLVM::Int8)

# Create module and add function
mod = LLVM::Module.new("app")
# function -> name, arguments, output type
main = mod.functions.add('main', [INT], INT)

puts_c = mod.functions.add("puts", [PCHAR], INT)

# Append block
block = main.basic_blocks.append('entry')

# Build the instructions inside the block
build = Builder.new
build.position_at_end(block)
adder = build.add(main.params[0], LLVM::Int(5))

# Local variables
var = build.alloca(INT)
build.store(LLVM::Int(10), var)
p build.load(var)

# Build string and call puts
str = build.global_string_pointer("testing")
build.call(puts_c, str)

# Return the results of adding 5 to the first parameter
build.ret(adder)

# Prepare JIT engine
LLVM.init_jit
ee = JITCompiler.new(mod)

# Run our main function
p ee.run_function(main, 10).to_i

puts "---------------------"

puts mod
