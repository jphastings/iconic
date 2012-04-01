class CreateNextTalks < ActiveRecord::Migration
  def self.up
    create_table :next_talks do |table|
      table.integer :color_1
      table.integer :object_1
      table.integer :color_2
      table.integer :object_2

      table.timestamp :created_at
    end      
  end
  
  def self.down
    drop_table :next_talks
  end
end
