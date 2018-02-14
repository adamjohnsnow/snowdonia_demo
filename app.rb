require 'sinatra/base'
require 'sinatra/flash'
require 'pry'
require_relative './data_mapper_setup'

ENV['RACK_ENV'] ||= 'development'

class SnowdoniaFestival < Sinatra::Base
  enable :sessions
  configure do
    use Rack::Session::Cookie,
    :expire_after => 43200,
    :secret => ENV['SESSION_SECRET'] || 'something'
  end
  register Sinatra::Flash

  get '/' do
    erb :index, :layout => false
  end

  get '/home' do
    erb :home
  end

end
require_relative 'routes/init'
