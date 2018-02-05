require 'data_mapper'
require 'dm-postgres-adapter'
require_relative './models/user'
require_relative './models/project'
require_relative './models/element'
require_relative './models/costcode'
require_relative './models/material'
require_relative './models/client'
require_relative './models/site'
require_relative './models/element_material'
require_relative './models/element_labour'
require_relative './models/project_version'
require_relative './models/version_updater'
require_relative './models/price_updater'

if ENV['RACK_ENV'] == 'test'
  @database = "postgres://localhost/factory_setting_test"
else
  @database = "postgres://localhost/factory_setting_dev"
end


p "Running on #{@database}"
DataMapper.setup(:default, ENV['DATABASE_URL'] || @database)
DataMapper::Property::String.length(255)
DataMapper.finalize
DataMapper.auto_upgrade!

def destroy_all
  ElementMaterial.all.destroy!
  Material.all.destroy!
  Element.all.destroy!
  ProjectVersion.all.destroy!
  User.first.projects.all.destroy!
end
