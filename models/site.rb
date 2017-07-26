require 'data_mapper'

class Site
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true
  property :contact_name, String
  property :address, Text
  property :email, String
  property :phone, String

  has n, :projects

end
