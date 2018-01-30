require 'data_mapper'
require 'dm-postgres-adapter'
require_relative './models/user'
require_relative './models/project'
require_relative './models/element'
require_relative './models/costcode'
require_relative './models/material'
require_relative './models/client'
require_relative './models/unit_cost'
require_relative './models/site'
require_relative './models/element_material'
require_relative './models/project_version'

if ENV['RACK_ENV'] == 'test'
  @database = "postgres://localhost/factory_setting_test"
else
  @database = "postgres://localhost/factory_setting_dev"
end

p "Running on #{@database}"
DataMapper.setup(:default, ENV['DATABASE_URL'] || @database)
DataMapper.finalize
DataMapper.auto_upgrade!
