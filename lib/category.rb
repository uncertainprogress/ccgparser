module CCGParser

	#This defines a lexical category in the CCG, such as (S\NP)/NP
	#Also defines the argument application/composition behaviors with itself, for shift-reduce parsing
	class Category
		
		attr_reader :reference, :root, :start, :typeraise
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
		end
    
    #return a new category composed of the two
    def compose_with(othercat)
      return nil unless self.has_arguments? && othercat && othercat.has_arguments?
      
      #determine the slash-type of both categories, 
      selfslash = self.slash_type
      otherslash = othercat.slash_type
      
      return nil if selfslash == 'star' || otherslash == 'star' #don't allow composition on categories that only allow application
      #all other slashes compose in various ways, based on slash hierarchy
      
      if selfslash == 'diamond' || otherslash == 'diamond' #order-preserved composition
        
      elsif selfslash == 'cross' || otherslash == 'cross' #any composition, includes the "any" slash
        
      end
      
      return nil #failure, no composition
    end
    
    #return a new category from this category applying from either the right or the left, depending
    def apply(prs, position) #array of categories, and position of this category
      
      if self.arguments.last.direction == "left"
        raise(IncorrectPOS, "From postion #{position} as #{prs[position].to_s} in the parse array") unless prs[position-1]
        
        if (!prs[position-1].has_arguments?) && (self.arguments.last.nonterminal == prs[position-1].root)
          self.remove_last_arg
          return self, :left
        end
      elsif self.arguments.last.direction == "right"
        raise(IncorrectPOS, "From postion #{position} as #{prs[position].to_s} in the parse array") unless prs[position+1]
        
        if (!prs[position+1].has_arguments?) && (self.arguments.last.nonterminal == prs[position-1].root)
          self.remove_last_arg
          return self, :right
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
        out << arg.nonterminal
      end
      out
    end
		
	end
	
	
	class HybridCategory < Category
		def initialize(root, arguments)
			@reference = "Combination"
			@root = root
			raise Exception("Not Implemented")
		end
	end

end

