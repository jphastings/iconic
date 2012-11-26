require 'dotenv'
Dotenv.load
require 'active_record'
require 'uri'
require File.join(File.dirname(__FILE__), 'lib','helpers')

require 'sinatra' unless defined?(Sinatra)

configure do
  require File.join(File.dirname(__FILE__),'lib','models.rb')
  
  db = URI.parse(ENV['DATABASE_URL'])

  ActiveRecord::Base.establish_connection(
   :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
   :host     => db.host,
   :username => db.user,
   :password => db.password,
   :database => db.path[1..-1],
   :encoding => 'utf8',
   :pool     => 20
  )
end