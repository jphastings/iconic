class CreateTalks < ActiveRecord::Migration
  def self.up
    create_table :talks do |table|
      table.text    :url
      table.integer :color_1
      table.integer :object_1
      table.integer :color_2
      table.integer :object_2
      table.text    :title

      table.timestamp :created_at
    end      
  end
  
  def self.down
    drop_table :talks
  end
end