module CCGParser
  
  class ChartParser
    def initialize
      @reverse = false
      @edgelist = Edgelist.new
    end
    
    def parse(terminals, category, direction)
      
      @direction = direction
      @terminals = terminals
      if direction == :left
       @reverse = true
        target = category.first_arg_left
      elsif direction == :right
        target = category.first_arg_right
      end
      
      raise IncorrectPOS, "#{category} is not the right part of speech" unless target
      puts "ChartParse #{direction} to find #{target} in #{terminals}" if DEBUG_CP
      @rootedge = Edge.new(target, []<<target, 0, 0, 0)
      add_edge @rootedge
      
      #scan and match words
      @terminals.each_with_index { |word, i| scan_edge word, i}
      
      #fail if the root edge hasn't been fully consumed
      raise ChartParseError, "#{target} not found in terminal array to the #{direction}" unless @rootedge.at_end
    
    	puts @rootedge.print_with_children if DEBUG_CP_EDGES
      
      #finished, the rootedge should have links to the full tree
      return @rootedge.endindex
      
      nil
    end
    
    def add_edge newedge
      #add the edge to the chart
      unless @edgelist.contains_edge newedge
        puts 'Adding: ' +newedge.to_s if DEBUG_CP
        #add this edge to our list of edges
        @edgelist.add_edge newedge
        
        if newedge.at_end #expand new nonterminals in the list of rules (the ones right after the dot position)
          extend_edge newedge
        #otherwise, substitute this edge into the nonterminal 
        #positions right after the dot in all rules with this rule's start nonterminal
        else 
          predict_edge newedge
        end
      end   
    end
    
    def extend_edge newedge
      puts 'Extend: ' + newedge.to_s if DEBUG_CP
      @edgelist.elist.each do |curredge|
        unless curredge.currentNT == nil
          if (newedge.startNT == curredge.currentNT) && (newedge.startindex == curredge.endindex)
            curredge.childedges[curredge.bodyNTindex] = newedge
            curredge.bodyNTindex += 1 #take the current position over the nonterminal
            curredge.endindex = newedge.endindex
            if curredge.at_end
              extend_edge curredge
            else
              predict_edge curredge
            end
          end
        end
      end
    end
    
    def predict_edge newedge
      return unless Lexicon.contains?(newedge.currentNT)
      puts 'Predict: ' + newedge.to_s if DEBUG_CP
      Lexicon.find(newedge.currentNT).each do |nt|
          termlist = nt.argument_NT_list
          termlist.reverse! if @reverse
          add_edge Edge.new(newedge.currentNT, termlist, newedge.endindex, newedge.endindex, 0)
      end
    end
    
    def scan_edge word, i
      raise(WordNotFound, "#{word} not found in dictionary") unless Word.contains?(word)
      puts "Scan forward over #{word}" if DEBUG_CP
      match = false
      Word.find_pos(word).each do |category|
        @edgelist.elist.each do |curredge|
          if curredge.currentNT == category #edge match
            add_edge Edge.new(curredge.currentNT, Array.new(1) {word}, i, i+1, 1)
            match = true
          end
        end
      end
      #don't allow a scan without some kind of extension match to another rule
      raise ChartParseError, "POS not found to match #{word} when scanning" unless match
    end
    
  end
  
end