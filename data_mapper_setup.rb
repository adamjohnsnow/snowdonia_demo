require 'data_mapper'
require 'dm-postgres-adapter'
require_relative './spec/helpers'

if ENV['DATABASE_URL']
  @database = 'Heroku Postgres'
elsif ENV['RACK_ENV'] == 'test'
  @database = "postgres://localhost/snowdonia_festival_test"
else
  @database = "postgres://localhost/snowdonia_festival_dev"
end


p "Running on #{@database}"
DataMapper.setup(:default, ENV['DATABASE_URL'] || @database)
DataMapper::Property::String.length(255)
DataMapper.finalize
DataMapper.auto_upgrade!
