class CreateSimpleObjects < ActiveRecord::Migration
  def self.up
    create_table :simple_objects do |table|
      table.string  :name
    end
  end
  
  def self.down
    drop_table :simple_objects
  end
end