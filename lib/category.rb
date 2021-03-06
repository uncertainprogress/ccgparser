module CCGParser

  #This defines a lexical category in the CCG, such as (S\NP)/NP
  #Also defines the argument application/composition behaviors with itself, for shift-reduce parsing
  class Category
		
    attr_reader :reference, :root, :start, :conjunction
    attr_accessor :typeraise
    attr_accessor :arguments
		
    def initialize(definition)
      @reference = definition[0].gsub(/[\d]+$/, '') #this is the general category of the rule, NP, IV, PP, etc
      @root = definition[1]['Root']
			
      #This category is a "start" category if it is one that starts the parse, etc
      @start = false
      @start = true if definition[1]['Start']
			
      #Type raising flag
      @typeraise = false
      @typeraise = true if definition[1]['Raise']
      
      @arguments = [] #ordered array of arguments
      #complexity to ensure that we get correctly ordered arguments
      definition[1].select{|k,v| k =~ /Arg*/}.sort{|a,b| a[0] <=> b[0]}.each do |arg|
				@arguments << Argument.new(arg[1]['term'], arg[1]['slash'], arg[1]['dir'])
      end
			
			@conjunction = false
    end
    
    #return a new category composed of the two
    def compose_with(other)
      return nil unless self.has_arguments? && other && other.has_arguments?
      
      #determine the slash-type of both categories, 
      selfslash = self.slash_type
      otherslash = other.slash_type
      
      #don't allow composition on categories that only allow application
      #treat star slash application like a special case here, for conjunctions, etc, since it's going to be an application of the whole category,
      #instead of pieces of each
      if selfslash == 'star' || otherslash == 'star' 
        
      end
      
      if selfslash == 'diamond' || otherslash == 'diamond' #order-preserved composition
        
      elsif selfslash == 'cross' || otherslash == 'cross' #any composition, includes the "any" slash
        
      else #two "any" slashes composing
                      
      end
      
      return nil #failure, no composition
    end
    
    #type raising operation
    def raise_with(other)
			#self.arguments.each_with_index {|arg, i| puts arg.inspect}
			#other.arguments.each {|arg| puts arg.inspect}
      self.arguments.each_with_index do |selfarg, i|
        if selfarg.nonterminal == other.root #start the composition here
          other.arguments.each_with_index do |otherarg, j|
            if self.arguments[j+i+1] 
							(next if otherarg == self.arguments[j+i+1]) if other.arguments[j+1]
              return nil if otherarg != self.arguments[j+i+1] #fail, these categories won't compose
            end
            #otherwise, we've reached the end of self, and need to compose and return a new category
            self.arguments = []
						j += 1 if other.arguments.length == 1 #wacky case where S/S\NP needs to compose with a lone S\NP
            self.arguments += other.arguments[j..other.arguments.length-1]
            self.typeraise = false
            return self
          end
        end
      end
      return nil
    end
    
    
    #return a new category from this category applying from either the right or the left, depending
    def apply(prs, position) #array of categories, and position of this category
      
      if self.arguments.length > 0 && self.arguments.last.direction == "left" && position != 0 #can't be at the left end of the array
        raise(IncorrectPOS, "From position #{position} as #{prs[position].to_s} in the parse array") unless prs[position-1]
        
        if (prs[position-1].is_a? Category) && (!prs[position-1].has_arguments?) && (self.arguments.last.nonterminal == prs[position-1].root)
          newcat = self.clone
					newcat.remove_last_arg
          return newcat, :left
        end
      elsif self.arguments.length > 0 && self.arguments.last.direction == "right"
        raise(IncorrectPOS, "From position #{position} as #{prs[position].to_s} in the parse array") unless prs[position+1]
        
        if (prs[position+1].is_a? Category) && !prs[position+1].has_arguments? && (self.arguments.last.nonterminal == prs[position+1].root)
          newcat = self.clone
					newcat.remove_last_arg
          return newcat, :right
        end
      end
      
      return self, nil #return this category, and no direction on failure 
    end
        
    def num_arguments
      return arguments.length
    end
    
    def has_arguments?
      return self.num_arguments > 0
    end
		
    def slash_type
      raise NoSlashArgument unless self.has_arguments?
      return self.arguments.first.slash
    end
    
    def to_root
      cat = self.clone
      cat.arguments = []
      return cat
    end
    
    def argument_NT_list
      list = []
      @arguments.each{|arg| list << arg.nonterminal }
      list
    end
    
    def first_arg_left
      @arguments.each{|arg| return arg.nonterminal if arg.direction == 'left'}
      return nil
    end
    
    
    def first_arg_right
      @arguments.reverse.each{|arg| return arg.nonterminal if arg.direction == 'right'}
      return nil
    end
    
    def remove_last_arg
      @arguments.pop
    end
    
    
    def to_s
      out = "#{@root}"
      @arguments.each do |arg|
        if arg.direction == "left"
          out << '\\'
        else
          out << '/'
        end
        case(arg.slash)
        when 'star'
          out << "*"
        when 'diamond'
          out << "^"
        when 'cross'
          out << 'x'
        end
        out << arg.nonterminal if arg.nonterminal
      end
      out
    end
		
    def clone
      Marshal::load(Marshal.dump(self))
    end
		
		def ==(other)
			return true if self.to_s == other.to_s
    end
		
  end
	
  class HybridCategory < Category
    def initialize(root, arguments)
      @reference = "Combination"
      @root = root
      raise Exception("Not Implemented")
    end
  end
	
	class ConjunctionCategory < Category
		
		def initialize
			@reference = "CON"
			@root = "CON"
			
      @start = false
		  @typeraise = false
      @arguments = []
			@conjunction = true
    end
  end
	
	class SentenceCategory < Category
		def initialize
			@reference = "S"
			@root = "S"
			
      @start = false
		  @typeraise = false
      @arguments = []
			@conjunction = false
    end
	end

end

