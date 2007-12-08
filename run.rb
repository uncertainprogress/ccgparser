require 'lib/parser'

p = CCGParser::Parser.new

if ARGV.length > 0
  p.start(ARGV[0])
  
else #run through the corpus
  File.readlines("corpus").each do |line|
    p = CCGParser::Parser.new
		next if line == nil || line.strip == ""
    p.start(line.strip) unless line[0].chr == "#"
  end
end

puts "\n"

