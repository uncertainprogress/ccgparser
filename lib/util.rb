class Array
	def has_conjunction?
		self.each do |ele|
			return true if ele.is_a?(CCGParser::Category) && ele.conjunction
    end
  end
	
	def conjunction_left?(pos)
		self.each_with_index do |ele, i|
			if ele.is_a?(CCGParser::Category) && ele.conjunction
				return true if i < pos
      end
    end
		return false
  end
	
	def conjunction_right?(pos)
		self.each_with_index do |ele, i|
			if ele.is_a?(CCGParser::Category) && ele.conjunction
				return true if i > pos
      end
    end
		return false
  end
	
	def conjunction_position
		self.each_with_index do |ele, i|
			return i if ele.is_a?(CCGParser::Category) && ele.conjunction
    end
		return 0
  end
end