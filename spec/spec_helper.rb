require 'sinatra'
require 'rack/test'

# set test environment
ENV['RACK_ENV'] = 'test'
Sinatra::Base.set :environment, :test
Sinatra::Base.set :run, false
Sinatra::Base.set :raise_errors, true
Sinatra::Base.set :logging, false

require File.join(File.dirname(__FILE__), '../app')

ActiveRecord::Base.silence do
	ActiveRecord::Migration.verbose = false
	ActiveRecord::Migrator.migrate(File.join(File.dirname(__FILE__), '..','db','migrate'))
end

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure { |c| c.include RSpecMixin }