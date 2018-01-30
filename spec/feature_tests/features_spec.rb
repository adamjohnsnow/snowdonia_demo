describe 'feature test' do

  before do
    @project = set_up_project
    @material = Material.create(:costcode_id => 1, :description => 'Test Material', :current_price => 5.5, :scope => @project.id, :unit => 'm2')
  end

  it 'creates a project with site, pm and client' do
    expect(@project.user.firstname).to eq 'Adam'
    expect(@project.site.contact_name).to eq 'Mr Site'
    expect(@project.client.manager).to eq 'Mrs Client'
  end

  it 'can add project versions' do
    ProjectVersion.create(:version_name => @project.current_version, :project_id => @project.id)
    expect(@project.project_versions.count).to eq 1
    expect(@project.project_versions.first
          .version_name).to eq @project.current_version
  end

  it 'can add elements to projects' do
    project_version = ProjectVersion.create(:version_name => @project.current_version, :project_id => @project.id)
    Element.create(:project_version_id => project_version.id, :title => 'Test Element')
    expect(project_version.elements.count).to eq 1
    expect(@project.project_versions.first
          .elements.first.title).to eq 'Test Element'
  end

  it 'can add materials to element' do
    project_version = ProjectVersion.create(:version_name => @project.current_version, :project_id => @project.id)
    element = Element.create(:project_version_id => project_version.id, :title => 'Test Element')
    ElementMaterial.create(:element_id => element.id, :material_id => 1, :price => @material.current_price)
    expect(element.element_materials[0].units).to eq 1
    expect(element.element_materials[0].price).to eq 5.5
    expect(@project.project_versions.first
          .elements.first
          .element_materials.first.
          material.description).to eq 'Test Material'
  end

  it 'can update one material price' do
    project_version = ProjectVersion.create(:version_name => @project.current_version, :project_id => @project.id)
    element = Element.create(:project_version_id => project_version.id, :title => 'Test Element')
    ElementMaterial.create(:element_id => element.id, :material_id => 1, :price => @material.current_price)
    material_list = Material.all(:scope => @project.id)
    material_list[0].update(:current_price => 7.3)
    material_list.first.save!
    PriceUpdater.new(element.element_materials, material_list)
    expect(element.element_materials[0].price).to eq 7.3
  end
end
