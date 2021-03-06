begin
  require 'rspec/core/rake_task'

  task :default => :test
  task :test => :spec

  if !defined?(RSpec)
    puts "spec targets require RSpec"
  else
    desc "Run all examples"
    RSpec::Core::RakeTask.new(:spec) do |t|
      t.pattern = 'spec/**/*_spec.rb'
      t.rspec_opts = ['-cfs']
    end
  end
rescue LoadError
end

namespace :db do
  desc 'Migrate the database (destroys data)'
  task :migrate => :environment do
    ActiveRecord::Migrator.migrate(
      'db/migrate', 
      ENV["VERSION"] ? ENV["VERSION"].to_i : nil
    )
  end
  
  desc "Load any new objects and/or colours"
  task :load => :environment do
    open(File.join(File.dirname(__FILE__),'db','fixtures','objects.txt')) do |f|
      i = 0
      n = 0
      a = 0
      f.each do |line|
        names = line.strip.split(' ')
        if File.exists?(File.join('public','objects','svg',"#{names.first}.svg"))
          so = SimpleObject.find_or_initialize_by_name(names.first)
          n += 1 if so.new_record?
          
          names[1..-1].each do |name|
            alt = AlternateName.find_or_initialize_by_simple_object_id_and_name(so.id,name)
            a += 1 if alt.new_record?
            so.alternate_names << alt
          end
          so.save
          i += 1
        else
          $stderr.puts "There is no #{names.first}.svg - not added"
        end
      end
      $stdout.puts "#{n} new objects (with #{a+n} names) from #{i} rows"
    end
  end

=begin
  desc "Loads the next X talks into the queue to be used by new URLs"
  task :restock => :environment do
    number_to_populate = 1000
    
    $stdout.puts "Hunting down #{number_to_populate} new talks" 
    
    maximums = [Color.count,SimpleObject.count]*2
    maxall = maximums.inject(1){|a,b| a * b}
    talks = Talk.count
    
    # Count number of Objects, only find unused objects if there isn't a full compliment
    if talks < maximums.inject(1){|a,b| a * b}
      
      i = talks + 1
      
      while i < maxall
        skew = (i * (maximums[0] + 2)) % maxall
        
        object_2 = (skew / maximums[1]).floor + 1
        skew = skew % maximums[1]
        color_2 = (skew / maximums[0]).floor + 1
        skew = skew % maximums[0]
        object_1 = (skew / maximums[1]).floor + 1
        skew = skew % maximums[1]
        color_1 = (skew / maximums[0]).floor + 1
        
        NextTalk.find_or_create_by_color_1_and_object_1_and_color_2_and_object_2(
          color_1,object_1,color_2,object_2
        )
        
        number_to_populate -= 1
        break if number_to_populate <= 0
        i += 1
      end
    end

    # Choose the oldest 
    if (number_to_populate > 0)
      Talk.all.order('created_at ASC').limit(number_to_populate).each do |t|
        NextTalk.create(
          :object_1 => t.object_1,
          :color_1  => t.color_1,
          :object_2 => t.object_2,
          :color_2  => t.color_2
        )
      end
    end
    
    $stdout.puts "All populated"
  end
=end
end

task :environment do
  require File.join(File.dirname(__FILE__), 'environment.rb')
end

desc "Makes all images not already present"
task :images => :environment do
  SimpleObject.all.each do |ob|
    if File.exists?("public/objects/svg/#{ob.name}.svg")
      if !File.exists?("public/objects/#{ob.name}.png")
        `convert -density 184 -background None -extent 256x256 -gravity center public/objects/svg/#{ob.name}.svg -channel a -negate public/objects/#{ob.name}.png`
        `convert public/objects/#{ob.name}.png -fuzz 100% -fill white -opaque black public/objects/#{ob.name}.png`
      end
    else
      $stderr.puts "No #{ob.name}.svg"
    end
  end
end

#task :cron => 'db:restock'