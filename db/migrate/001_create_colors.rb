class CreateColors < ActiveRecord::Migration
  def self.up
    create_table :colors do |table|
      table.string  :name
      table.integer :red
      table.integer :green
      table.integer :blue
    end
    
    YAML.load(open(File.join('db','fixtures','colors.yaml'))).each_pair do |color,rgb|
      Color.new(
        :name => color,
        :red => rgb[0],
        :green => rgb[1],
        :blue => rgb[2]
      ).save
    end
  end
  
  def self.down
    drop_table :colors
  end
end