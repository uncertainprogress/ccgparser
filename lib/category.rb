module CCGParser

	#This defines a lexical category in the CCG, such as (S\NP)/NP
	#Also defines the argument application/composition behaviors with itself, for shift-reduce parsing
	class Category
		
		
		def initialize(definition)
			@reference = definition[0] #this is the NP<num> from the lexicon file, for reference in debugging, etc
			@root = definition[1]['Root']
			
			#This category is a "start" category if it is one that starts the parse, etc
			@start = false
			@start = true if definition[1]['Start']
			
			@arguments = [] #ordered array of arguments
			#complexity to ensure that we get correctly ordered arguments
			definition[1].select{|k,v| k =~ /Arg*/}.sort{|a,b| a[0] <=> b[0]}.each do |arg|
				@arguments << Argument.new(arg[1]['term'], arg[1]['slash'], arg[1]['dir'])
			end
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

