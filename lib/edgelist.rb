module CCGParser
  class Edgelist
    
    attr_reader :elist
    
    def initialize
      @elist = Array.new(0)
    end
    
    def add_edge newedge
      @elist.push newedge unless self.contains_edge newedge
    end
    
    def contains_edge newedge
      @elist.each do |curredge|
        return true if newedge == curredge
      end
      return false
    end
  
  end
end