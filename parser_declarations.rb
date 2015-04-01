class IF_STATEMENT
  attr_accessor :body
  attr_reader   :condition

  def initialize(condition)
    @condition = condition
  end
end

class WHILE_STATEMENT
  attr_accessor :body
  attr_reader   :condition

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

class ASSIGNMENT_SUBSTRACTION
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
