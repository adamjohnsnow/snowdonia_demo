describe Project do

  context 'project creation' do

    it 'create project' do
      Project.create(:title => 'Test Project', :pm_id => 1, :site_id => 1, :client_id => 1)
      expect(Project.all.count).to eq 1
    end

    it 'no duplicate project title' do
      Project.create(:title => 'Test Project', :pm_id => 1, :site_id => 1, :client_id => 1)
      expect(Project.all.count).to eq 1
    end

    it 'add second project' do
      Project.create(:title => '2nd Test Project', :pm_id => 1, :site_id => 1, :client_id => 1)
      expect(Project.all.count).to eq 2
    end

    it { expect(Project.first.status).to eq 'New' }

  end

end
