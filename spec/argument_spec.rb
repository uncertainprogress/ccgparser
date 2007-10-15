require File.join(File.dirname(__FILE__),"spec_helper.rb")

describe CCGParser::Argument do
	it "should be created with the proper parameters" do
		CCGParser::Argument.new("t1", "t2", "t3").should be_instance_of(CCGParser::Argument)
	end
end