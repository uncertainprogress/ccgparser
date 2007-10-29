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
	class WordNotFound < Exception; end 
  class IncorrectPOS < Exception; end
  class NoMatchingCategory < Exception; end
  class NoSlashArgument < Exception; end
  
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
                puts "\n\nParsing from '#{terminals[i]}' as #{cat.reference}" if DEBUG_OUTPUT
                parse(terminals.compact, i, cat)
              rescue IncorrectPOS => e
                puts "Word recognized as wrong part of speech in sentence - #{e.message} " if DEBUG_OUTPUT
              rescue NoMatchingCategory => e
                puts e.message
              end              
            end
          end
        end
      end
      
      rescue WordNotFound => e
        puts "Word not in dictionary: #{e.message}"
        
    end
    
    protected #HERE THERE BE PRIVATE METHODS ------------------------------------
    
    def parse(prs, startposition, category)
      return if prs.length <= 1 #we're done if there's only one non-terminal in the parse array			
      
      prs[startposition] = category
     
      CCGParser::print_trace(prs) if DEBUG_OUTPUT
      
      #terminal or category to the left?
      if prs[startposition-1].is_a? String #this is a terminal, need to chart-parse left to get a category
        prs, startposition = ChartParser.chart_parse(prs, startposition, :left)
        CCGParser::print_trace(prs) if DEBUG_OUTPUT
      end
      
      #terminal or category to the right?
      if prs[startposition+1].is_a? String #terminal, need to charparse right to get a category
        prs, startposition = ChartParser.chart_parse(prs, startposition, :right)
        CCGParser::print_trace(prs) if DEBUG_OUTPUT
      end
      
      #type raising
      #if the category at position-1 is an NP for type-raising, then replace the previous NP with the type-raising operator
      
      
      
      #composition, left, then right
      newcat = prs[startposition-1].compose_with(prs[startposition])
      if newcat
        prs[startposition] = newcat
        prs[startpostion-1] = nil
        startposition -= 1
        prs.compact!
      end
      newcat = prs[startposition].compose_with(prs[startposition+1])
      if newcat
        prs[startposition] = newcat
        prs[startpostion+1] = nil
        prs.compact!
      end
      
      #argument application
      newcat, direction = prs[startposition].apply(prs, startposition)
      newcat = newcat.to_root unless newcat.has_arguments?
      case(direction)
      when :left
        prs[startposition-1] = newcat
        prs[startposition] = nil
        startposition -= 1
        prs.compact!
      when :right
        prs[startposition] = newcat
        prs[startposition + 1] = nil
        prs.compact!
      when nil #no application
       
      end
        
      CCGParser::print_trace(prs) if DEBUG_OUTPUT
      
      parse(prs, startposition, prs[startposition]) #recursively parse
      
    end
  end 
end