require 'data_mapper'

class ProjectVersion
  include DataMapper::Resource

  property :id, Serial
  property :version_name, String
  property :created_date, Date, :default => Date.today
  property :current_version, Boolean, :default => true
  property :contracted, Boolean, :default => false
  property :created_by, String
  property :status, String, :default => 'New'
  property :last_update, String

  belongs_to :project
  has n, :elements

end
