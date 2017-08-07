require 'data_mapper'

class Supplier
  include DataMapper::Resource

  property :id, Serial
  property :company, String, :required => true
  property :website, URI
  property :address, Text
  property :email, String
  property :phone, String

  has n, :materials

end
