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
  property :last_update, String

  belongs_to :site
  belongs_to :client
  belongs_to :user
  has n, :materials
  has n, :users, through: Resource
  has n, :project_versions

end
