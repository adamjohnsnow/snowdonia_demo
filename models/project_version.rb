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
  property :contingency, Float, :default => 10
  property :overhead, Float, :default => 38.5
  property :profit, Float, :default => 10
  property :subcontractor, Float, :default => 20

  belongs_to :project
  has n, :elements

end
