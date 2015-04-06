require 'llvm/execution_engine'
require 'llvm/core'

class LLVM_Engine
  include LLVM

  INT   = LLVM::Int
  CHAR  = LLVM::Int8
  PCHAR = LLVM::Pointer(LLVM::Int8)

  def initialize
    # Create module
    @mod = LLVM::Module.new('app')
    # function -> name, arguments, output type
    @main    = @mod.functions.add('main', [INT], INT)
    @puts_c  = @mod.functions.add('puts', [PCHAR], INT)
    @printf  = @mod.functions.add('sprintf', [PCHAR, PCHAR], INT, varargs: true)
    @builder = generate_builder(@main)
    @locals  = {}

    @type_map = {}
    @block_counter = 0
  end

  def generate_builder(func, name = 'entry')
    block = func.basic_blocks.append(name)
    build = Builder.new
    build.position_at_end(block)
  end

  def builder_from_block(block)
    build = Builder.new
    build.position_at_end(block)
  end

  def get_block(name)
    @block_counter += 1
    @main.basic_blocks.append("#{name}_#{@block_counter}")
  end

  def define_variable(inst)
    value = inst.value

    var = @locals.fetch(inst.variable) {
      @locals[inst.variable] = create_new_variable(inst, value)
      return
    }

    # If var already exist store the updated value
    # don't change @locals here
    if value.to_i > 0
      @builder.store(LLVM::Int(value.to_i), var)
    else
      ptr = define_string(value)
      @builder.store(@builder.gep(ptr, LLVM::Int(0)), var)
    end
  end

  def define_string(str)
    @builder.global_string_pointer(str)
  end

  def create_new_variable(inst, value)
    if value.to_i > 0
        ptr = @builder.alloca(INT)
        @builder.store(LLVM::Int(value.to_i), ptr)
        @type_map[inst.variable] = "int"
        ptr
      else
        alloc = @builder.alloca(PCHAR)
        ptr   = define_string(value)
        @builder.store(@builder.gep(ptr, LLVM::Int(0)), alloc)
        @type_map[inst.variable] = "string"
        alloc
    end
  end

  def variable_add(inst)
    ptr = @locals.fetch(inst.variable)
    val = @builder.load(ptr)
    new_val = @builder.add(val, LLVM::Int(inst.value.to_i))
    @builder.store(new_val, ptr)
  end

  def convert_to_string(val)
    alloca = @builder.alloca(PCHAR, "char_pointer")
    ptr    = @builder.load(alloca)

    func   = @mod.functions.named("sprintf")
    str_format = define_string("%d")

    val  = @builder.load(val)
    @builder.call(func, ptr, str_format, val)
    ptr
  end

  def prepare_for_puts(ptr, var_name)
    if @type_map[var_name] == "int"
      convert_to_string(ptr)
    else
       @builder.load(ptr)
    end
  end

  def fetch_local(name)
    @locals.fetch(name) { abort "Invalid local variable - #{name}" }
  end

  def execute_method(name, *args)
    func = @mod.functions.named(name)
    ptr  = fetch_local(args.first)

    if name == "puts"
      str = prepare_for_puts(ptr, args.first)
      @builder.call(func, str)
    else
      val  = @builder.load(ptr)
      @builder.call(func, val)
    end
  end

  # Dereferences pointer to value
  def get_value(val)
    if val.is_a? IDENTIFIER
      var = fetch_local(val.content)
      @builder.load(var)
    else
      ptr = @builder.alloca(INT)
      @builder.store(LLVM::Int(val.content.to_i), ptr)
      @builder.load(ptr)
    end
  end

  # Idea: new END_BLOCK token generated by the parser
  # write to true_block until that token is found (end_if method on engine)
  # then create a new block for the rest of the code.
  def evaluate_if(input)
    cmp = evaluate_condition(input)

    @true_block  = get_block('true_block')
    @after_block = get_block('after_block')

    @builder.cond(cmp, @true_block, @after_block)

    @builder = builder_from_block(@true_block)
  end

  def end_block
    builder_from_block(@true_block).br(@after_block)
    @builder = builder_from_block(@after_block)
  end

  def end_while
    builder_from_block(@true_block).br(@condition_block)
    @builder = builder_from_block(@after_block)
  end

  def evaluate_while(input)
    cmp = evaluate_condition(input)

    @true_block  = get_block('true_block')
    @after_block = get_block('after_block')

    @builder.cond(cmp, @true_block, @after_block)

    @builder = builder_from_block(@true_block)
  end

  # icmp(pred, lhs, rhs, name = "") ⇒ LLVM::Instruction
  # cond(cond, iftrue, iffalse) ⇒ LLVM::Instruction
  def evaluate_condition(input)
    @condition_block = get_block('condition_block')
    @builder.br(@condition_block)

    @builder = builder_from_block(@condition_block)

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

  def llvm_output
    puts
    puts @mod.dump
    puts
  end

  def run
    @builder.ret(LLVM::Int(0))
    #llvm_output

    LLVM.init_jit
    ee = JITCompiler.new(@mod)

    # Run our main function
    ee.run_function(@main, 10)
  end
end
