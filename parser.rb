require 'rubygems'
require 'active_record'
require 'yaml'

#CCGParser classes
require 'argument'
require 'category'
require 'word'


module CCGParser
	SLASHTYPES = {:star => true, :diamond => true, :cross => true}.freeze
	
		
	class Parser
		
		#load up the lexicon and morphology, lexicon comes from the lexicon file, morphology from the database, 
		#an ActiveRecord connection
		def initialize
			ActiveRecord::Base.establish_connection(YAML::load(File.open('database.yml'))['standard'])
		end
	
	end
end