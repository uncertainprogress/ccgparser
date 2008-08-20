MIGRATEPATH = './migrate'

module CCGParser
  module Database
  	def self.migrate(version = nil)
  		ActiveRecord::Migrator.migrate(MIGRATEPATH, version)
		end
	end
end