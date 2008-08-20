class CreateWords < ActiveRecord::Migration
  def self.up
    create_table :words, :force => true do |t|
      t.column :word, :string
      t.column :pos, :string
      t.column :stem, :string
      t.column :type_raise, :boolean, :default => false
    end    
  end
  
  def self.down
   drop_table :words
  end
  
end