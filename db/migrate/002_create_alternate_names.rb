class CreateAlternateNames < ActiveRecord::Migration
  def self.up
    create_table :alternate_names do |table|
      table.integer :simple_object_id
      table.string  :name
    end
  end
  
  def self.down
    drop_table :alternate_names
  end
end
