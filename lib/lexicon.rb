module CCGParser
		
	#Serves as the collection for the various lexical categories, internally, holds a collection of Category instances
	class Lexicon
    
		def self.load(filename)
			@@entries = []  #internal store for all the categories
			lex = YAML::load_file(filename)
			lex.each do |entry|
				@@entries << Category.new(entry)
			end
			
		end
		
		#return all categories that match this part of speech or non terminal, return a list sorted from longest to shortest
		def self.find(part_of_speech)
			return @@entries.select{|cat| cat.reference == part_of_speech}.sort{|a,b| b.num_arguments <=> a.num_arguments}
		end
		
	end
end