describe 'feature test' do

  before do
    DatabaseCleaner.clean
    user = User.create('Adam', 'Snow', 'adamjohnsnow@icloud.com', 'password', 'Developer')
    user.update(:level => 3)
    client = Client.create(:name => "Made Up Client", :address => '1 Client Road, Clientville, CL1 1CL', :manager => 'Mrs Client')
    site = Site.create(:name => "Made Up Site", :contact_name => 'Mr Site', :address => '2 Site Lane, Sitetown, S12 1QW')
    @project = Project.create(:title => 'Feature Project', :user_id => user.id, :site_id => site.id, :client_id => client.id)
    Costcode.create(:code => 'C001')
    @material = Material.create(:costcode_id => 1, :description => 'Test Material', :current_price => 5.5)
  end

  it 'creates a project with site, pm and client' do
    expect(@project.user.firstname).to eq 'Adam'
    expect(@project.site.contact_name).to eq 'Mr Site'
    expect(@project.client.manager).to eq 'Mrs Client'
  end

  it 'can add project versions' do
    ProjectVersion.create(:version_name => @project.current_version, :project_id => @project.id)
    expect(@project.project_versions.count).to eq 1
    expect(@project.project_versions.first.version_name).to eq @project.current_version
  end

  it 'can add elements to projects' do
    project_version = ProjectVersion.create(:version_name => @project.current_version, :project_id => @project.id)
    Element.create(:project_version_id => project_version.id, :title => 'Test Element')
    expect(project_version.elements.count).to eq 1
    expect(@project.project_versions.first.elements.first.title).to eq 'Test Element'
  end

  it 'can add materials to element' do
    project_version = ProjectVersion.create(:version_name => @project.current_version, :project_id => @project.id)
    element = Element.create(:project_version_id => project_version.id, :title => 'Test Element')
    ElementMaterial.create(:element_id => element.id, :material_id => 1, :price => @material.current_price)
    expect(element.element_materials[0].units).to eq 1
    expect(element.element_materials[0].price).to eq 5.5
    expect(@project.project_versions.first.elements.first.element_materials.first.material.description).to eq 'Test Material'
  end
end
