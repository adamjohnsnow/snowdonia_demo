require 'data_mapper'

class Client
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true
  property :address, Text
  property :manager, String
  property :email, String
  property :phone, String

  has n, :projects

end
