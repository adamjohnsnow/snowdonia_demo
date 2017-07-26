require 'data_mapper'

class Supplier
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :address, Text

  has n, :materials

end
