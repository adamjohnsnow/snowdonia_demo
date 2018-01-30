require 'data_mapper'

class ProjectVersion
  include DataMapper::Resource

  property :id, Serial
  property :version_no, String
  property :created_date, Date, :default => Date.today

  belongs_to :project
  has n, :elements

end
