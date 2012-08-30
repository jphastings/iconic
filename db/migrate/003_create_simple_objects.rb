#require File.join(File.dirname(__FILE__),'..','..','Rakefile')

class CreateSimpleObjects < ActiveRecord::Migration
  def self.up
    create_table :simple_objects do |table|
      table.string  :name
    end

    # rake load
    Rake.application['db:load'].invoke
  end
  
  def self.down
    drop_table :simple_objects
  end
end