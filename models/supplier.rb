require 'data_mapper'

class Supplier
  include DataMapper::Resource

  property :id, Serial
  property :company, String, :required => true
  property :website, URI
  property :address, Text

  has n, :materials

end
