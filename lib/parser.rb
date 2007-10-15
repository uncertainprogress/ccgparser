require 'rubygems'
require 'active_record'
require 'yaml'

#CCGParser classes
require 'lib/argument'
require 'lib/category'
require 'lib/lexicon'
require 'lib/word'


module CCGParser
	SLASHTYPES = {:star => true, :diamond => true, :cross => true, :any => true}.freeze
	#star is argument application only
	#diamond adds order-preserving composition
	#cross adds cross-element composition
	#any is an unlimited combination
	
	class LexiconLoadException < Exception; end
	class CategoryShiftReduceException < Exception; end
	
		
	class Parser
		
		#load up the lexicon and morphology, lexicon comes from the lexicon file, morphology from the database, 
		#an ActiveRecord connection
		def initialize
			ActiveRecord::Base.establish_connection(YAML::load(File.open('config/database.yml'))['standard'])
			
			@lexicon = Lexicon.new('config/lexicon.yml')
		end
		
		def start(string)
			terminals = string.split.each{|word| word.strip.downcase}
			
		end
		
		def parse(words, startposition)
		
		end
	end
end