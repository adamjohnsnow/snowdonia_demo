require 'data_mapper'

class Project
  include DataMapper::Resource

  property :id, Serial
  property :title, String, :unique => true, :required => true
  property :job_code, String
  property :workshop_deadline, Date
  property :on_site, Date
  property :form, String
  property :summary, Text
  property :technical_requirements, Text
  property :terms, Text
  property :status, String, :default => 'New'

  belongs_to :user
  belongs_to :site
  belongs_to :client
  has n, :elements

end
