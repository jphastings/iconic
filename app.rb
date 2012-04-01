# encoding: utf-8
require 'sinatra'
require File.join(File.dirname(__FILE__), 'environment')
require 'slim'
require 'maruku'

get '/' do
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

get '/title/:descr' do
  descr = params[:descr].split(':')
  color_1  = Color.find_by_name(descr[0])
  object_1 = SimpleObject.find_by_name(descr[1])
  color_2  = Color.find_by_name(descr[2])
  object_2 = SimpleObject.find_by_name(descr[3])
  
  talk = Talk.find_by_color_1_and_object_1_and_color_2_and_object_2(color_1,object_1,color_2,object_2)
  
  halt(404,"No such URI") if (talk.nil?)
  
  if talk.title.nil?
    u = URI.parse(talk.url)
  
    if (u.scheme == 'http')
      require 'timeout'
      require 'net/http'
    
      begin
        Timeout.timeout(2) do
          Net::HTTP.start(u.host, u.port) do |http|
            http.request_get(u.request_uri) do |res|
              content = ""
              res.read_body do |segment|
                puts content << segment
                if content.match(/<title>(.+?)<\/title>/)
                  talk.title = $1.strip
                  break
                end
                break if content.length > 4096
              end
            end
          end
        end
      rescue
      end
      
      talk.title ||= '-'
      talk.save
    else
      halt(200,"Not a website")
    end
  end
  
  talk.title.to_json
end

get '/discover/:descr' do
  descr = params[:descr].split(':')
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