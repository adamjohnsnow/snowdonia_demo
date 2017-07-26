require 'data_mapper'
require 'dm-postgres-adapter'
require_relative './models/user'
require_relative './models/project'
require_relative './models/element'
require_relative './models/supplier'
require_relative './models/category'
require_relative './models/material'
require_relative './models/client'
require_relative './models/site'

if ENV['RACK_ENV'] == 'test'
  @database = "postgres://localhost/factory_setting_test"
else
  @database = "postgres://localhost/factory_setting_dev"
end

p "Running on #{@database}"
DataMapper.setup(:default, ENV['DATABASE_URL'] || @database)
DataMapper.finalize
DataMapper.auto_upgrade!
