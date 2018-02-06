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
require_relative './models/markup_updater'
require_relative './models/totals'

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


def set_up_test
  destroy_all
  new_project = Project.create(
    :title => 'First Project',
    :user_id => 1,
    :site_id => 1,
    :client_id => 1
  )
  new_project.users << User.get(1)
  new_project.save!
  pv = ProjectVersion.create(
    :version_name => 'v1',
    :project_id => new_project.id
  )
  element_1 = Element.create(
    :project_version_id => new_project.project_versions.last.id,
    :title => 'First Element'
  )
  ElementLabour.create(
    :element_id => element_1.id,
  )

  element_2 = Element.create(
    :project_version_id => new_project.project_versions.last.id,
    :title => 'Second Element'
  )
  ElementLabour.create(
    :element_id => element_2.id,
  )
  mat1 = Material.create(
    :costcode_id => 1,
    :description => 'First Material',
    :current_price => 15.5,
    :project_id => new_project.id,
    :unit => 'm2'
  )
  mat2 = Material.create(
    :costcode_id => 2,
    :description => 'Second Material',
    :current_price => 6.12,
    :project_id => new_project.id,
    :unit => 'm2'
  )
  ElementMaterial.create(
    :element_id => element_1.id,
    :material_id => mat1.id,
    :price => mat1.current_price,
    :units => 3
  )
  ElementMaterial.create(
      :element_id => element_1.id,
      :material_id => mat2.id,
      :price => mat2.current_price,
      :units => 3
    )
end
def destroy_all
  ElementMaterial.all.destroy!
  Material.all.destroy!
  Element.all.destroy!
  ProjectVersion.all.destroy!
  User.first.projects.all.destroy!
end
