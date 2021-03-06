module CCGParser
	
	#This class defines arguments in a lexical category, which can have any number of arguments
	#This has 3 attributes.
	#1. The terminal which defines the argument
	#2. The slash direction in which this argument operates
	#3. The modality on the slash	
	class Argument
		
    attr_reader :nonterminal, :slash, :direction
    
		def initialize(nonterminal, slash, direction)
			@nonterminal = nonterminal
			@slash = slash
			@direction = direction
		end
		
		def ==(other)
      return self.nonterminal == other.nonterminal && self.slash == other.slash && self.direction == other.direction
    end
	end
end