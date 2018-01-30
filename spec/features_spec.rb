describe 'feature test' do

  before do
    DatabaseCleaner.clean
    @user = User.create('Adam', 'Snow', 'adamjohnsnow@icloud.com', 'password', 'Developer')
    @user.update(:level => 3)
    @client = Client.create(:name => "Made Up Client", :address => '1 Client Road, Clientville, CL1 1CL', :manager => 'Mrs Client')
    @site = Site.create(:name => "Made Up Site", :contact_name => 'Mr Site', :address => '2 Site Lane, Sitetown, S12 1QW')
    @project = Project.create(:title => 'Feature Project', :user_id => @user.id, :site_id => @site.id, :client_id => @client.id)
  end

  it 'creates a project with site, pm and client' do
    expect(@project.user.firstname).to eq 'Adam'
    expect(@project.site.contact_name).to eq 'Mr Site'
    expect(@project.client.manager).to eq 'Mrs Client'
  end

  it 'can add project versions' do
    ProjectVersion.create(:version_no => @project.current_version, :project_id => @project.id)
    expect(@project.project_versions.count).to eq 1
  end

end
