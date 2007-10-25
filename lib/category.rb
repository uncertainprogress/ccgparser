module CCGParser

	#This defines a lexical category in the CCG, such as (S\NP)/NP
	#Also defines the argument application/composition behaviors with itself, for shift-reduce parsing
	class Category
		
		attr_reader :reference, :root, :start, :raise, :arguments
		
		def initialize(definition)
			@reference = definition[0].gsub(/[\d]+$/, '') #this is the general category of the rule, NP, IV, PP, etc
			@root = definition[1]['Root']
			
			#This category is a "start" category if it is one that starts the parse, etc
			@start = false
			@start = true if definition[1]['Start']
			
      #Type raising flag
      @raise = false
      @raise = true if definition[1]['Raise']
      
			@arguments = [] #ordered array of arguments
			#complexity to ensure that we get correctly ordered arguments
			definition[1].select{|k,v| k =~ /Arg*/}.sort{|a,b| a[0] <=> b[0]}.each do |arg|
				@arguments << Argument.new(arg[1]['term'], arg[1]['slash'], arg[1]['dir'])
			end
		end
    
    def num_arguments
      return arguments.length
    end
		
    def first_arg_left
      @arguments.each{|arg| return arg.nonterminal if arg.direction == 'left'}
      return nil
    end
    
    
    def first_arg_right
      @arguments.reverse.each{|arg| return arg.nonterminal if arg.direction == 'right'}
      return nil
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

