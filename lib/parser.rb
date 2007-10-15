require 'rubygems'
require 'active_record'
require 'yaml'

#CCGParser classes
require 'lib/argument'
require 'lib/category'
require 'lib/lexicon'
require 'lib/word'
require 'lib/morph'


module CCGParser
	DEBUG_OUTPUT = true

	SLASHTYPES = {:star => true, :diamond => true, :cross => true, :any => true}.freeze
	#star is argument application only
	#diamond adds order-preserving composition
	#cross adds cross-element composition
	#any is an unlimited combination
	
	class LexiconLoadError < Exception; end
	class CategoryShiftReduceError < Exception; end
	class WordNotFoundError < Exception; end 
	
		
	class Parser
		
		#load up the lexicon and morphology, lexicon comes from the lexicon file, morphology from the database, 
		#an ActiveRecord connection
		def initialize
			ActiveRecord::Base.establish_connection(YAML::load(File.open('config/database.yml'))['standard'])
			@morph = Morph.new
			@lexicon = Lexicon.new('config/lexicon.yml')
		end
		
		def start(string)
			terminals = string.split.map{|word| word.downcase.strip}
			p terminals if DEBUG_OUTPUT
			terminals.each_with_index do |word, i|
				#dispatch to the parser based on whether the current word position is a start point for parsing or not
				#this query to the dictionary returns an array of possible parts of speech for the word
				print "#{word} - " if DEBUG_OUTPUT
				p @morph.find_as_pos(word) if DEBUG_OUTPUT
				@morph.find_as_pos(word).each do |pos|
					@lexicon.find(pos).each do |cat|
						if cat.start
							parse(terminals, i, cat)
						end
					end
				end
			end			
		end
		
		def parse(words, startposition, category)
			puts "Parsing from '#{words[startposition]}' as #{category.reference}" if DEBUG_OUTPUT
			
			
		end
	end
end