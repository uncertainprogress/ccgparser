%w(rubygems active_record yaml).each{|f| require f}

#CCGParser classes
%w(argument category lexicon word morph chartparser).each{|f| require 'lib/'+f}


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
  class IncorrectPOSError < Exception; end
  class NoMatchingCategory < Exception; end
  
  def self.print_trace(prs)
    out = '['
    prs.each{|e| out << e.to_s + " "}
    out << ']'
    puts out
  end
	
		
	class Parser
		
		#load up the lexicon and morphology, lexicon comes from the lexicon file, morphology from the database, 
		#an ActiveRecord connection
		def initialize
			ActiveRecord::Base.establish_connection(YAML::load(File.open('config/database.yml'))['standard'])
			Lexicon.load('config/lexicon.yml')
		end
		
		def start(string)
			terminals = string.split.map{|word| word.downcase.strip}
			p terminals if DEBUG_OUTPUT
			terminals.each_with_index do |word, i|
				#dispatch to the parser based on whether the current word position is a start point for parsing or not
				#this query to the dictionary returns an array of possible parts of speech for the word
        Word.find_pos(word).each do |pos|
					Lexicon.find(pos).each do |cat|
						if cat.start
							begin
                parse(terminals, i, cat)
              rescue IncorrectPOSError
                print "Word recognized as wrong part of speech in sentence - " if DEBUG_OUTPUT
                p terminals if DEBUG_OUTPUT
              end              
            end
          end
        end
      end			
    end
    
    protected #HERE THERE BE PRIVATE METHODS ------------------------------------
    
    def parse(words, startposition, category)
      puts "\n\nParsing from '#{words[startposition]}' as #{category.reference}" if DEBUG_OUTPUT
			
      prs = words.clone
      prs[startposition] = category
      
      #terminal or category to the right?
      if prs[startposition+1].is_a? String #terminal, need to charparse right to get a category
        prs, startposition = ChartParser.chart_parse(prs, startposition, :right)
        CCGParser::print_trace(prs) if DEBUG_OUTPUT
      end
      
      #terminal or category to the left?
      if prs[startposition-1].is_a? String #this is a terminal, need to chart-parse left to get a category
        prs, startposition = ChartParser.chart_parse(prs, startposition, :left)
        CCGParser::print_trace(prs) if DEBUG_OUTPUT
      end
      
      #type raising
      
      #composition, left, then right
      
      #argument application, right, then left
      
    end
  end 
end