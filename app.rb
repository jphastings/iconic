# encoding: utf-8
require 'sinatra'
require 'nokogiri'
require File.join(File.dirname(__FILE__), 'environment')
require 'slim'
require 'maruku'

get '/' do
  @commit = case
  when File.directory?('.git')
    `git show --pretty=%H | head -n 1`
  when File.exist?('.from_commit')
    File.read('current_commit.txt')
  else
    nil
  end

  slim :index
end

get '/create' do
  begin
    u = URI.parse(params['uri'])
    raise ArgumentError if params['uri'].strip == ''
  rescue
    halt(400,"Please send a uri! ?uri=xxxxxx")
  end
  
  u.scheme ||= 'http'
  
  halt(403,"You may not store javascript like that here") if u.scheme == 'javascript'
  halt(414,"That URI is too long") if u.to_s.length > 1024

  @talk = Talk.find_or_create_by_url(u.to_s)
  @talk.save
  
  slim :shapes
end

get '/objects/:color-:object.svg' do
  colored_svg = File.join(File.dirname(__FILE__),'public','objects',"#{params[:color]}-#{params[:object]}.svg")

  pass if File.exist? colored_svg
  
  color = Color.find_by_name(params[:color])
  object = SimpleObject.find_by_name(params[:object])

  halt(404,"No such object") if color.nil? or object.nil?

  svg = Nokogiri::XML(open(File.join(File.dirname(__FILE__),'public','objects','svg',"#{object.name}.svg")))
  style = Nokogiri::XML::Node.new('style',svg)
  style.content = "* {fill:##{color.hex};}"
  svg.at_css('svg') << style
  File.open(colored_svg,'w') do |f|
    f.write svg.to_xml
  end

  content_type :svg
  svg.to_xml
end

get '/suggest/:color_1-:object_1-:color_2-:object_2' do
  query = {
    :color_1  => Color.find_by_name(params[:color_1]),
    :object_1 => SimpleObject.find_by_name(params[:object_1]),
    :color_2  => Color.find_by_name(params[:color_2]),
    :object_2 => SimpleObject.find_by_name(params[:object_2])
  }.delete_if {|k,v| v.nil?}

  if query.keys.length == 0
    talk = Talk.first(:order => "RANDOM()")
    halt 404,'[]' if talk.nil?
    halt(200,[
      talk.color_1.name,
      talk.object_1.name,
      talk.color_2.name,
      talk.object_2.name
    ].to_json)
  end

  if query.keys.include?(:color_1) and !query.keys.include?(:object_1)
    halt(200,{:object_1 => Talk.all(:select => :object_1, :conditions => query,:group => :object_1).collect{|t| t.object_1.name}}.to_json)
  end

  if !query.keys.include?(:color_1) and query.keys.include?(:object_1)
    halt(200,{:color_1  => Talk.all(:select => :color_1, :conditions => query,:group => :color_1).collect{|t| t.color_1.name}}.to_json)
  end

  if query.keys.include?(:color_1) and query.keys.include?(:object_1)
    if !query.keys.include?(:color_2) and !query.keys.include?(:object_2)
      halt(200,{
        :color_2  => Talk.all(:select => :color_2, :conditions => query,:group => :color_2).collect{|t| t.color_2.name},
        :object_2 => Talk.all(:select => :object_2, :conditions => query,:group => :object_2).collect{|t| t.object_2.name}
      }.to_json)
    end

    if query.keys.include?(:color_2) and !query.keys.include?(:object_2)
      halt(200,{:object_2 => Talk.all(:select => :object_2, :conditions => query,:group => :object_2).collect{|t| t.object_2.name}}.to_json)
    end

    if !query.keys.include?(:color_2) and query.keys.include?(:object_2)
      halt(200,{:color_2  => Talk.all(:select => :color_2, :conditions => query,:group => :color_2).collect{|t| t.color_2.name}}.to_json)
    end
  end

  query.to_json
end



get '/title/:color_1-:object_1-:color_2-:object_2' do
  color_1  = Color.find_by_name(params[:color_1])
  object_1 = SimpleObject.find_by_name(params[:object_1])
  color_2  = Color.find_by_name(params[:color_2])
  object_2 = SimpleObject.find_by_name(params[:object_2])
  
  talk = Talk.find_by_color_1_and_object_1_and_color_2_and_object_2(color_1,object_1,color_2,object_2)
  
  halt(404,"No such URI") if (talk.nil?)

  talk.fetch_title.to_json
end

get '/discover/:descr' do
  descr = params[:descr].split('-')
  color_1  = Color.find_by_name(descr[0])
  object_1 = SimpleObject.find_by_name(descr[1])
  color_2  = Color.find_by_name(descr[2])
  object_2 = SimpleObject.find_by_name(descr[3])
  
  talk = Talk.find_by_color_1_and_object_1_and_color_2_and_object_2(color_1,object_1,color_2,object_2)
  
  halt(404,"No such URI") if (talk.nil?)
  
  {
    :uri => talk.url,
    :title => talk.title
  }.to_json
end

get '/css/colors.css' do
  content_type :css
  Color.all.each.collect do |c|
    ".#{c.name} {background-color:rgb(#{c.red},#{c.green},#{c.blue});color:rgb(#{c.red},#{c.green},#{c.blue});}"
  end
end

get '/:color_1-:object_1-:color_2-:object_2' do
  color_1  = Color.find_by_name(params[:color_1])
  object_1 = SimpleObject.find_by_name(params[:object_1])
  color_2  = Color.find_by_name(params[:color_2])
  object_2 = SimpleObject.find_by_name(params[:object_2])
  
  @talk = Talk.find_by_color_1_and_object_1_and_color_2_and_object_2(color_1,object_1,color_2,object_2)
  
  halt(404) if (@talk.nil?)

  slim :shapes
end

