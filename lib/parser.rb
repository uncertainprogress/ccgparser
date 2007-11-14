%w(rubygems active_record yaml).each{|f| require f}

#CCGParser classes
%w(argument category lexicon word morph chartparser edge edgelist).each{|f| require 'lib/'+f}


module CCGParser
	DEBUG_OUTPUT = true
  DEBUG_CP = false
  DEBUG_CP_EDGES = false

	SLASHTYPES = {:star => true, :diamond => true, :cross => true, :any => true}.freeze
	#star is argument application only
	#diamond adds order-preserving composition
	#cross adds cross-element composition
	#any is an unlimited combination
	
	class LexiconLoadError < Exception; end
	class CategoryShiftReduceError < Exception; end
	class WordNotFound < Exception; end 
  class IncorrectPOS < Exception; end
  class ChartParseError < Exception; end
  class NoMatchingCategory < Exception; end
  class NoSlashArgument < Exception; end
  
  def self.print_trace(prs, position)
    out = '['
    prs.each{|e| out << e.to_s + " "}
    out << "] at #{position.to_s}"
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
      puts "\n---------------PARSING:---------------"
      p terminals if DEBUG_OUTPUT
			puts "\n" if DEBUG_OUTPUT
			
			startarray = []
			
			terminals.each_with_index do |word, i|
				posarr = []
				Word.find_pos(word).each do |w|
					Lexicon.find(w.pos).each do |cat|
						posarr << cat if cat.start
					end
				end
				if posarr.length > 0
					startarray << posarr
				else
					startarray[i] = word
				end
      end
			parse_from(startarray, 0)
      
		rescue WordNotFound => e
			puts "Word not in dictionary: #{e.message}"
        
		end
    
		protected #HERE THERE BE PRIVATE METHODS ------------------------------------
		def parse_from(termarray, position)
			run_parse = true
			termarray.each{|ele| run_parse = false if ele.is_a?(Array) }
			
			return parse(termarray, position, termarray[position]) if(run_parse)
			
			termarray.each_with_index do |arr, i|
				next unless i > position
				next unless arr.is_a?(Array) && arr.length > 0
				arr.each do |cat|
					newarr = termarray.clone
					newarr[i] = cat
					begin
						parse_from(newarr, i)
					rescue IncorrectPOS => e
						puts "Wrong starting part of speech - #{e.message} \n\n" if DEBUG_OUTPUT
					rescue NoMatchingCategory => e
						puts "#{e.message} \n\n" if DEBUG_OUTPUT
					rescue ChartParseError => e 
						puts "#{e.message} \n\n" if DEBUG_OUTPUT
					end
				end
			end
		end
		
		
		def parse(prs, startposition, category)
			return true if prs.length <= 1 && prs[0].root == "S" && !prs[0].has_arguments? #we're done if there's only one non-terminal in the parse array
			raise IncorrectPOS, "#{category} is not the right part of speech" if prs.length <= 1
     
			CCGParser::print_trace(prs, startposition) if DEBUG_OUTPUT
      
			#terminal or category to the left?
			unless startposition == 0
				if prs[startposition-1].is_a? String #this is a terminal, need to chart-parse left to get a category
					numparsed, newcat = ChartParser.new.parse(prs[0..startposition-1].reverse, prs[startposition], :left)
					raise IncorrectPOS, "#{category} is an incorrect part of speech." unless numparsed
					numparsed.downto(1) {|n| prs[startposition - n] = nil}
					prs[startposition-1] = newcat
					prs.compact!
					startposition -= numparsed-1
					CCGParser::print_trace(prs, startposition) if DEBUG_OUTPUT
				end
			end
      
			#terminal or category to the right?
			if prs[startposition+1].is_a? String #terminal, need to charparse right to get a category
				numparsed, newcat = ChartParser.new.parse(prs[startposition+1..prs.length-1], prs[startposition], :right)
				raise IncorrectPOS, "#{category} is an incorrect part of speech." unless numparsed
				numparsed.downto(1) {|n| prs[startposition + n] = nil}
				prs[startposition + 1] = newcat
				prs.compact!
				CCGParser::print_trace(prs, startposition) if DEBUG_OUTPUT
			end
      
			#type raising
			#if the category at position-1 is an NP for type-raising, then replace the previous NP with the type-raising operator
			if startposition > 0
				if prs[startposition-1].typeraise 
					newcat = prs[startposition-1].raise_with(prs[startposition])
					if newcat
						prs[startposition-1] = nil
						prs[startposition] = newcat
						startposition -= 1
						prs.compact!
						CCGParser::print_trace(prs, startposition) if DEBUG_OUTPUT
					end
				end
			end
      
			#composition, left, then right
			if startposition > 0 && prs[startposition-1].is_a?(Category) 
				newcat = prs[startposition-1].compose_with(prs[startposition])
				if newcat
					prs[startposition] = newcat
					prs[startposition-1] = nil
					startposition -= 1
					prs.compact!
					CCGParser::print_trace(prs, startposition) if DEBUG_OUTPUT
				end
			end
      
			if prs[startposition-1].is_a?(Category) 
				newcat = prs[startposition].compose_with(prs[startposition+1])
				if newcat
					prs[startposition] = newcat
					prs[startposition+1] = nil
					prs.compact!
					CCGParser::print_trace(prs, startposition) if DEBUG_OUTPUT
				end
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
        
			CCGParser::print_trace(prs, startposition) if DEBUG_OUTPUT
      
			parse(prs, startposition, prs[startposition]) #recursively parse
		end
	end 
end