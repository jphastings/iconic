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

  def hex
    [self[:red],self[:green],self[:blue]].collect {|component| component.to_s(16).rjust(2,'0') }.join
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
      
      # TODO: This is a hack because the SQL below seems to return an already present ID sometimes...
      has_new_ref = false
      while not has_new_ref
        # Get a new random talk set
        colors = Color.count
        obs = SimpleObject.count

        # Take a random number of all the possible ones (starts at 0)
        guess = Random.rand(colors*obs*colors*obs)

        # Find the next available talk from the guessed number up
        ref = find_next_free_ref(guess)
      
        # Assign to this talk
        talk = {}
        talk[:color_1] = (ref / (obs*obs*colors)).floor + 1
        ref = ref % (obs*obs*colors)
        talk[:object_1] = (ref / (obs*colors)).floor + 1
        ref = ref % (obs*colors)
        talk[:color_2] = (ref / obs).floor + 1
        talk[:object_2] = ref % obs

        has_new_ref = Talk.first(:conditions=>talk).nil?
      end

      talk.each_pair do |key,val|
        self[key] = val
      end
    end
  end

  def image_1
    "/objects/#{object_1.name}.png"
  end

  def image_2
    "/objects/#{object_2.name}.png"
  end

  def fetch_title(timeout = 2)
    if read_attribute(:title).nil?
      require 'htmlentities'

      u = URI.parse(read_attribute(:url))

      if (['https','http'].include? u.scheme)
        require 'timeout'
        require 'net/http'
        require 'net/https'

        begin
          Timeout.timeout(timeout) do
            http = Net::HTTP.new(u.host, u.port)
            http.use_ssl = (u.scheme == 'https')
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE

            res = nil

            0.upto(3) do
              res = http.request_get(u.request_uri)

              break if res.code == "200"
              raise RuntimeError unless res.code =~ /^3/ # Too many redirects
            end

            break if res.code != "200"

            if res.body.match(/<meta property="og:title" content="(.+?)"/) or res.body.match(/<title>(.+?)<\/title>/) # TODO: Social title, see facebook
               write_attribute(:title,HTMLEntities.new.decode($1.strip))
            end
          end
        rescue
        end

        if read_attribute(:title).nil?
          write_attribute(:title,((u.path == "/" or u.path == '') ? u.host :  "#{u.path} at #{u.host}"))
        end
      else
        halt(200,"Not a website")
      end
    end

    read_attribute(:title)
  end

  private
  def find_next_free_ref(ref)
    colors = Color.count
    obs = SimpleObject.count

    sql = "
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
    LIMIT 1"

    Talk.find_by_sql(sql).first.ref.to_i
  end
end

class AlternateName < ActiveRecord::Base
  belongs_to :simple_object
end
