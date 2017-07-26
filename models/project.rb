require 'data_mapper'

class Project
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :job_code, String
  property :workshop_deadline, Date
  property :on_site, Date
  property :form, String
  property :summary, Text
  property :technical_requirements, Text
  property :terms, Text

  belongs_to :user
  belongs_to :client
  has n, :elements

end
