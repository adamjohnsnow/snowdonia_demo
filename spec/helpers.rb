def set_up_test
  destroy_all
  set_up_projects
  set_up_elements
  set_up_materials
end

def destroy_all
  ElementMaterial.all.destroy!
  Material.all.destroy!
  ElementLabour.all.destroy!
  Element.all.destroy!
  ProjectVersion.all.destroy!
  User.all.projects.all.destroy!
  Project.all.destroy!
end

def set_up_projects
  @new_project = Project.create(
    :title => 'Second Project',
    :user_id => 1,
    :site_id => 1,
    :client_id => 1
  )
  @new_project.users << User.get(1)
  @new_project.save!
  @pv = ProjectVersion.create(
    :version_name => 'v1',
    :project_id => @new_project.id,
    :status => 'New'
  )
  @new_project = Project.create(
    :title => 'First Project',
    :user_id => 1,
    :site_id => 1,
    :client_id => 1
  )
  @new_project.users << User.get(1)
  @new_project.save!
  @pv = ProjectVersion.create(
    :version_name => 'v1',
    :project_id => @new_project.id,
    :status => 'Tender'
  )
end

def set_up_elements
  @element_1 = Element.create(
    :project_version_id => @pv.id,
    :title => 'First Element',
    :el_order => 1
  )
  ElementLabour.create(
    :element_id => @element_1.id,
  )
  element_2 = Element.create(
    :project_version_id => @pv.id,
    :title => 'Second Element',
    :el_order => 2
  )
  ElementLabour.create(
    :element_id => element_2.id,
  )
end

def set_up_materials
  mat1 = Material.create(
    :costcode_id => 1,
    :description => 'First Material',
    :current_price => 15.5,
    :project_id => @new_project.id,
    :unit => 'm2'
  )
  mat2 = Material.create(
    :costcode_id => 2,
    :description => 'Second Material',
    :current_price => 6.12,
    :project_id => @new_project.id,
    :unit => 'm2'
  )
  ElementMaterial.create(
    :element_id => @element_1.id,
    :material_id => mat1.id,
    :price => mat1.current_price,
    :units => 3,
    :mat_order => 1
  )
  ElementMaterial.create(
    :element_id => @element_1.id,
    :material_id => mat2.id,
    :price => mat2.current_price,
    :units => 3,
    :mat_order => 2
  )
end

def set_up_project
  DatabaseCleaner.clean
  user = User.create(
    'Adam',
    'Snow',
    'adamjohnsnow@icloud.com',
    'password',
    'Developer',
    3
  )
  client = Client.create(
    :name => "Made Up Client",
    :address => '1 Client Road, Clientville, CL1 1CL',
    :manager => 'Mrs Client'
  )
  site = Site.create(:name => "Made Up Site",
    :contact_name => 'Mr Site',
    :address => '2 Site Lane, Sitetown, S12 1QW'
  )
  Costcode.create(:code => 'C001')
  project = Project.create(
    :title => 'Feature Project',
    :user_id => user.id,
    :site_id => site.id,
    :client_id => client.id
  )
  return project
end
