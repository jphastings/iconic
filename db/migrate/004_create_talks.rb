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

    # create red heart brown hat = http://iconic.im
    Talk.create(
      :color_1 => Color.find_by_name('red'),
      :object_1 => SimpleObject.find_by_name('heart'),
      :color_2 => Color.find_by_name('brown'),
      :object_2 => SimpleObject.find_by_name('hat'),
      :url => "http://iconic.im/",
      :title => "Iconic"
    )
  end
  
  def self.down
    drop_table :talks
  end
end