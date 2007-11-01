module CCGParser
	
	#simple ActiveRecord model to store the words, their stems, etc
	class Word < ActiveRecord::Base
	
		def self.find_pos(word)
			pos = []
			Word.find(:all, :conditions => {:word => word}).each do |w|
				if w.stem
					pos += Word.find_pos(w.stem) #look at the stem of the word
				else
					pos << w.pos
				end				
			end
			
			raise WordNotFound.new("#{word}") unless pos.length > 0
			return pos
		end
   
    def self.find_words(word)
      words = Word.find(:all, :conditions => {:word => word})
      return words if words.length > 0
      raise WordNotFound
    end
    
    def self.contains? word
      return Word.find(:all, :conditions => {:word => word}).length > 0
    end
    
	end
end