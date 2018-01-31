require 'data_mapper'

class ProjectVersion
  include DataMapper::Resource

  property :id, Serial
  property :version_name, String
  property :created_date, Date, :default => Date.today
  property :current_version, Boolean, :default => true

  belongs_to :project
  has n, :elements

end
