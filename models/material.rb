require 'data_mapper'

class Material
  include DataMapper::Resource

  property :id, Serial
  property :description, Text
  property :supplier, Text
  property :current_price, Float

  belongs_to :costcode
  has n, :element_materials

end
