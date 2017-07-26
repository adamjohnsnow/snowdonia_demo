require 'data_mapper'

class Category
  include DataMapper::Resource

  property :id, Serial
  property :type, String, :unique => true

  has n, :materials

end
