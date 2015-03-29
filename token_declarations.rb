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
