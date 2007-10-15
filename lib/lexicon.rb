module CCGParser
		
	#Serves as the collection for the various lexical categories, internally, holds a collection of Category instances
	class Lexicon
	
		def initialize(filename)
			@entries = []  #internal store for all the categories
			lex = YAML::load_file(filename)
			lex.each do |entry|
				@entries << Category.new(entry)
			end
			
		end
		
		
		def find(part_of_speech)
			return @entries.select{|cat| cat.reference == part_of_speech}
		end
		
	end
end