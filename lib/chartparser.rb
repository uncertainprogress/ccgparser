module CCGParser
  
  class ChartParser
    def self.chart_parse(parsearray, startpos, direction)
      #print "CP #{direction} from #{parsearray[startpos]} in " if DEBUG_OUTPUT
      #CCGParser::print_trace parsearray if DEBUG_OUTPUT
      if direction == :left
        target = parsearray[startpos].first_arg_left
        return ChartParser.scan_reverse(parsearray, target, startpos) unless target == nil
      elsif direction == :right
        target = parsearray[startpos].first_arg_right
        return ChartParser.scan(parsearray, target, startpos) unless target == nil
      end
      
      raise IncorrectPOS, "From postion #{startpos} as #{parsearray[startpos].to_s} in the parse array"
    end
    
    
    def self.scan(array, target, startpos)
      slice = array[startpos+1..array.length]
      Lexicon.find(target).each do |cat| #load all the potential target categories that match the target nonterminal
        index = 0
        cat.arguments.each do |arg|
          Word.find_words(slice[index]).each do |word|
            if word.pos == arg.nonterminal #category argument matches the word part of speech
              index += 1 
              break #move to the next argument in the category
            end
          end
          if(index == cat.arguments.length) #matched all arguments with words, in order, so this category matches
            array[startpos+1] = cat.to_root #the parse is irrelevant, just need the root
            startpos.upto(index+startpos) do |n| #replace elements in the array with the new category
              array[n] = nil if array[n].is_a? String
            end
            return array.compact, startpos
          end
        end
      end
      raise NoMatchingCategory, "No category exsists that matches the terminals to the right"
    end
    
    #return a new array that has replaced a terminal in the array with a category
    def self.scan_reverse(array, target, startpos)
      slice = array[0...startpos].reverse
      Lexicon.find(target).each do |cat| #load all the potential target categories that match the target nonterminal
        index = 0
        cat.arguments.reverse.each do |arg|
          Word.find_words(slice[index]).each do |word|
            if word.pos == arg.nonterminal #category argument matches the word part of speech
              index += 1 
              break #move to the next argument in the category
            end
          end
          if(index == cat.arguments.length) #matched all arguments with words, in order, so this category matches
            array[startpos-1] = cat.to_root #the parse is irrelevant, just need the root
            1.upto(index) do |n| #replace elements in the array with the new category
              array[startpos-n] = nil if array[startpos-n].is_a? String
            end
            return array.compact, startpos - cat.arguments.length + 1
          end
        end
      end
      raise NoMatchingCategory, "No category exsists that matches the terminals to the left"
    end
  end
  
end