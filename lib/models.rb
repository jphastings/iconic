class SimpleObject < ActiveRecord::Base
  has_many :alternate_names
  
  def alternates
    self.alternate_names.collect{|a| a.name}
  end
  
  def to_s
    self[:name]
  end
end

class Color < ActiveRecord::Base
  def to_s
    self[:name]
  end
end

class Talk < ActiveRecord::Base
  belongs_to :object_1, :class_name => 'SimpleObject', :foreign_key => :object_1
  belongs_to :color_1, :class_name => 'Color', :foreign_key => :color_1
  belongs_to :object_2, :class_name => 'SimpleObject', :foreign_key => :object_2
  belongs_to :color_2, :class_name => 'Color', :foreign_key => :color_2
  
  before_save :before_save
  
  def before_save
    if self[:object_1].nil? # If one is nil they should all be nil
      # Pick the next talk from that database
      nt = NextTalk.first
      self[:object_1] = nt.object_1
      self[:color_1]  = nt.color_1
      self[:object_2] = nt.object_2
      self[:color_2]  = nt.color_2
      nt.delete
    else
      # If this URL has been selected as a NextTalk, remove it so it's not overwritten
      begin
        NextTalk.find_by_object_1_and_color_1_and_object_2_and_color_2(
          self[:object_1],
          self[:color_1],
          self[:object_2],
          self[:color_2]
        ).delete
      rescue
      end
    end
  end
  
  def image_1
    "/objects/#{object_1.name}.png"
  end
  
  def image_2
    "/objects/#{object_2.name}.png"
  end
  
end

class AlternateName < ActiveRecord::Base
  belongs_to :simple_object
end

class NextTalk < ActiveRecord::Base
end
