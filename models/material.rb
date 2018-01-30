require 'data_mapper'

class Material
  include DataMapper::Resource

  property :id, Serial
  property :description, Text
  property :workshop, Float
  property :supplier, Text

  belongs_to :costcode
  has n, :element_materials
  has n, :unit_costs

end
