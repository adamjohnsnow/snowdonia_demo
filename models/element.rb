require 'data_mapper'

class Element
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :quantity, Integer
  property :notes, Text

  has n, :materials, through: Resource

end
