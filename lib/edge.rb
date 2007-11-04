module CCGParser
  class Edge
    
    attr_accessor :startindex, :endindex, :startNT, :bodyNTlist, :bodyNTindex, :childedges
    attr_reader :rootedge
  
    def initialize(startnonterm, bodynonterminals, startpos, endpos, ntindex, rootedge = false)
      @startindex = startpos
      @endindex = endpos
      @startNT = startnonterm
      @bodyNTlist = bodynonterminals #array of nonterminals
      @bodyNTindex = ntindex
      @childedges = Array.new(bodynonterminals.length)
      @rootedge = rootedge
    end
    
    def at_end
      return @bodyNTindex == @bodyNTlist.length
    end
    
    def currentNT
      unless at_end 
        @bodyNTlist[@bodyNTindex]
      else
        nil
      end
    end
    
    def to_s
      return @startindex.to_s + ', ' + @endindex.to_s + ' ' + @startNT + ' -> ' + @bodyNTlist.to_s + ', ' + @bodyNTindex.to_s
    end
    
    def print_with_children
      puts self.to_s
      return if @childedges == nil
      @childedges.each { |curredge| puts '     ' + curredge.to_s}
      @childedges.each { |curredge| curredge.print_with_children unless curredge == nil}
    end
    
    def == otheredge
     	return otheredge && ((self.startNT == otheredge.startNT)&&(self.bodyNTlist == otheredge.bodyNTlist)&&(self.startindex == otheredge.startindex)&&(self.endindex == otheredge.endindex))
    end
  end
end