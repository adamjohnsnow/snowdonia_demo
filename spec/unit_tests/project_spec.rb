describe Project do
  before do
    DatabaseCleaner.clean
  end

  context 'project creation' do

    it 'create project' do
      Project.create(:title => 'Test Project', :user_id => 1, :site_id => 1, :client_id => 1)
      expect(Project.all.count).to eq 1
      expect(Project.first.status).to eq 'New'
      expect(Project.first.title).to eq 'Test Project'
      expect(Project.first.current_version).to eq '0.1'
    end

    it 'no duplicate project title' do
      Project.create(:title => 'Test Project', :user_id => 1, :site_id => 1, :client_id => 1)
      Project.create(:title => 'Test Project', :user_id => 1, :site_id => 1, :client_id => 1)
      expect(Project.all.count).to eq 1
    end

    it 'add second project' do
      Project.create(:title => 'Test Project', :user_id => 1, :site_id => 1, :client_id => 1)
      Project.create(:title => '2nd Test Project', :user_id => 1, :site_id => 1, :client_id => 1)
      expect(Project.all.count).to eq 2
    end
  end
end
