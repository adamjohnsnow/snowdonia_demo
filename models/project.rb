require 'data_mapper'

class Project
  include DataMapper::Resource

  property :id, Serial
  property :title, String, :unique => true, :required => true
  property :job_code, String
  property :workshop_deadline, Date, :default => Date.today
  property :on_site, Date, :default => Date.today
  property :summary, Text
  property :technical_requirements, Text
  property :terms, Text
  property :status, String, :default => 'New'
  property :pm_id, Integer
  property :current_version, String, :default => '0.1'

  has n, :users, through: Resource
  has n, :project_versions
  belongs_to :site
  belongs_to :client

  def add_user(user_id)
    self.users << User.get(user_id)
  end

end
