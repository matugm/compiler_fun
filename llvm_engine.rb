require 'llvm/execution_engine'
require 'llvm/core'

class LLVM_Engine
  include LLVM

  INT   = LLVM::Int
  PCHAR = LLVM::Pointer(LLVM::Int8)

  def initialize
    # Create module
    @mod = LLVM::Module.new("app")
    # function -> name, arguments, output type
    @main    = @mod.functions.add('main', [INT], INT)
    @puts_c  = @mod.functions.add("puts", [PCHAR], INT)
    @builder = generate_builder(@main)
    @locals  = {}
  end

  def generate_builder(func)
    block = func.basic_blocks.append('entry')
    build = Builder.new
    build.position_at_end(block)
  end

  def define_variable(inst)
    value = inst.value

    if inst.is_a? NUMBER
      ptr = @builder.alloca(INT)
      @builder.store(LLVM::Int(value), ptr)
    else
      ptr = define_string(value)
    end

    @locals[inst.variable] = ptr
  end

  def define_string(str)
    @builder.global_string_pointer(str)
  end

  def execute_method(name, *args)
    func = @mod.functions.named(name)
    val  = @locals.fetch(args.first) { abort "Invalid local variable - #{args.first}" }
    @builder.call(func, val)
  end

  def get_value(val)
    if val.is_a? IDENTIFIER
      @locals.fetch(val.content) { abort "Invalid local variable - #{val}" }
    else
      ptr = @builder.alloca(INT)
      @builder.store(LLVM::Int(val.content.to_i), ptr)
      ptr
    end
  end

  def evaluate_if(input)
    #cmp = evaluate_condition(input)
  end

  # icmp(pred, lhs, rhs, name = "") ⇒ LLVM::Instruction
  # cond(cond, iftrue, iffalse) ⇒ LLVM::Instruction
  # condition / body
  def evaluate_condition(input)
    op = input.condition[1]
    left_hand  = get_value(input.condition[0])
    right_hand = get_value(input.condition[2])

    if op.class == DOUBLE_EQUALS
      return @builder.icmp(:eq, left_hand, right_hand)
    end

    if op.class == LESSER_THAN
      return @builder.icmp(:slt, left_hand, right_hand)
    end

    if op.class == GREATER_THAN
      return @builder.icmp(:sgt, left_hand, right_hand)
    end
  end

  def run
    @builder.ret(LLVM::Int(0))
    #p @mod.dump

    LLVM.init_jit
    ee = JITCompiler.new(@mod)

    # Run our main function
    ee.run_function(@main, 10)
  end
end
