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
      # Get a new random talk set
      colors = Color.count
      obs = SimpleObject.count
      
      # Take a random number of all the possible ones (starts at 0)
      p guess = Random.rand(colors*obs*colors*obs)
      
      # Find the next available talk from the guessed number up
      p ref = find_next_free_ref(guess)

      # Assign to this talk
      self[:color_1] = (ref / (obs*obs*colors)).floor + 1
      ref = ref % (obs*obs*colors)
      self[:object_1] = (ref / (obs*colors)).floor + 1
      ref = ref % (obs*colors)
      self[:color_2] = (ref / obs).floor + 1
      self[:object_2] = ref % obs
    end
  end
  
  def image_1
    "/objects/#{object_1.name}.png"
  end
  
  def image_2
    "/objects/#{object_2.name}.png"
  end
  
  private
  def find_next_free_ref(ref)
    colors = Color.count
    obs = SimpleObject.count
    
    Talk.find_by_sql("
    SELECT ref
    FROM (
      SELECT ref
      FROM (
        SELECT #{ref} AS ref
      ) q1
      WHERE NOT EXISTS (
        SELECT  #{ref}
        FROM    talks
        WHERE   ((color_1 - 1)*#{obs*obs*colors} + (object_1-1) * #{obs*colors} + (color_2-1) * #{obs} + (object_2-1)) = #{ref}
      )
      UNION ALL
      SELECT  *
      FROM (
        SELECT ((color_1 - 1)*#{obs*obs*colors} + (object_1-1) * #{obs*colors} + (color_2-1) * #{obs} + (object_2-1)) + 1 as ref
        FROM talks t
        WHERE NOT EXISTS (
          SELECT  1
          FROM    talks ti
          WHERE   ((ti.color_1-1)*#{obs*obs*colors} + (ti.object_1-1) * #{obs*colors} + (ti.color_2-1) * #{obs} + (ti.object_2-1)) = ((1-t.color_1)*#{obs*obs*colors} + (1-t.object_1) * #{obs*colors} + (1-t.color_2) * #{obs} + (t.object_2-1)) + 1
        )
        ORDER BY
          ref
        LIMIT 1
      ) q2
      ORDER BY ref DESC
    ) as a
    WHERE ref < #{obs*obs*colors*colors}
    LIMIT 1").first.ref.to_i
  end  
end

class AlternateName < ActiveRecord::Base
  belongs_to :simple_object
end

class NextTalk < ActiveRecord::Base
end
