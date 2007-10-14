require 'rubygems'
require 'active_record'
require 'yaml'

#CCGParser classes
require 'lib/argument'
require 'lib/category'
require 'lib/word'


module CCGParser
	SLASHTYPES = {:star => true, :diamond => true, :cross => true}.freeze
	
		
	class Parser
		
		#load up the lexicon and morphology, lexicon comes from the lexicon file, morphology from the database, 
		#an ActiveRecord connection
		def initialize
			ActiveRecord::Base.establish_connection(YAML::load(File.open('config/database.yml'))['standard'])
		end
	
	end
end