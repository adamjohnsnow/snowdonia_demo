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
