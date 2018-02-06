describe 'feature test' do
  before do
    @project = set_up_project
    @material = Material.create(
      :costcode_id => 1,
      :description => 'Test Material',
      :current_price => 5.5,
      :project_id => @project.id,
      :unit => 'm2'
    )
  end

  context 'project set up' do

    it 'creates a project with site, pm and client' do
      expect(@project.user.firstname).to eq 'Adam'
      expect(@project.site.contact_name).to eq 'Mr Site'
      expect(@project.client.manager).to eq 'Mrs Client'
    end

    it 'can add project versions' do
      ProjectVersion.create(
        :version_name => 'v1',
        :project_id => @project.id
      )
      expect(@project.project_versions.count).to eq 1
    end

    it 'can add elements to projects' do
      project_version = ProjectVersion.create(
        :version_name => 'v1',
        :project_id => @project.id
      )
      element = Element.create(
        :project_version_id => project_version.id,
        :title => 'Test Element'
      )
      ElementLabour.create(:element_id => element.id)
      expect(project_version.elements.count).to eq 1
      expect(@project.project_versions.first
            .elements.first.title).to eq 'Test Element'
      expect(element.element_labour.carpentry).to eq 0.0
    end

    it 'can add materials to element' do
      project_version = ProjectVersion.create(
        :version_name => 'v1',
        :project_id => @project.id
      )
      element = Element.create(
        :project_version_id => project_version.id,
        :title => 'Test Element'
      )
      ElementMaterial.create(
        :element_id => element.id,
        :material_id => 1,
        :price => @material.current_price
      )
      expect(element.element_materials[0].units).to eq 1
      expect(element.element_materials[0].price).to eq 5.5
      expect(@project.project_versions.first
            .elements.first
            .element_materials.first.
            material.description).to eq 'Test Material'
    end

    it 'calculates totals' do
      project_version = ProjectVersion.create(
        :version_name => 'v1',
        :project_id => @project.id
      )
      element = Element.create(
        :project_version_id => project_version.id,
        :title => 'Test Element'
      )
      ElementLabour.create(
        :element_id => element.id,
        :carpentry => 2.0
      )
      ElementMaterial.create(
        :element_id => element.id,
        :material_id => 1,
        :price => @material.current_price,
        :units => 3
      )
      total = Totals.new.summarise_project(project_version)
      expect(total[0][:markup]).to eq 254.46
      expect(total[0][:labour]).to eq 360.00
      expect(total[0][:materials]).to eq 16.5
    end
  end

  context 'updating and itterating' do
    it 'can update one material price' do
      project_version = ProjectVersion.create(
        :version_name => 'v1',
        :project_id => @project.id
      )
      element = Element.create(
        :project_version_id => project_version.id,
        :title => 'Test Element'
      )
      ElementMaterial.create(
        :element_id => element.id,
        :material_id => 1,
        :price => @material.current_price
      )
      material_list = Material.all(:project_id => @project.id)
      material_list[0].update_price(7.3)
      PriceUpdater.new(element.element_materials, material_list)
      expect(element.element_materials[0].price).to eq 7.3
    end

    it 'can add users to projects' do
      @project.users << User.first
      @project.save!
      expect(@project.users.count).to eq 1
      expect(@project.users.first.surname).to eq 'Snow'
    end

    it 'can create new versions of projects' do
      project_version = ProjectVersion.create(
        :version_name => 'v1',
        :project_id => @project.id
      )
      element = Element.create(
        :project_version_id => project_version.id,
        :title => 'Test Element'
      )
      element2 = Element.create(
        :project_version_id => project_version.id,
        :title => '2nd Element'
      )
      ElementLabour.create(:element_id => element.id)
      ElementLabour.create(:element_id => element2.id)
      ElementMaterial.create(
        :element_id => element.id,
        :material_id => 1,
        :price => @material.current_price
      )
      VersionUpdater.new(
        project_version,
        ProjectVersion.create(
          :project_id => @project.id,
          :version_name => 'v2'
        )
      )
      expect(@project.project_versions[0].elements.count).to eq 2
      expect(@project.project_versions[1].elements.count).to eq 2
      expect(@project.project_versions[0].current_version).to eq false
      expect(@project.project_versions[1].current_version).to eq true
      expect(@project.project_versions[1].elements.element_labour.count).to eq 2
      expect(Element.all.count).to eq 4
      expect(ElementMaterial.all.count).to eq 2
    end
  end
end
