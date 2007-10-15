module CCGParser
	
	#simple ActiveRecord model to store the words, their stems, etc
	class Word < ActiveRecord::Base
	
		def self.find_as_pos(word)
			pos = []
			self.find(:all, :conditions => {:word => word}).each do |w|
				if w.stem
					pos += Word.find_as_pos(w.stem) #look at the stem of the word
				else
					pos << w.pos
				end				
			end
			
			raise WordNotFound unless pos.length > 0
			return pos
		end
		
		
	end
end