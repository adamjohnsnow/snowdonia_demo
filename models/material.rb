require 'data_mapper'

class Material
  include DataMapper::Resource

  property :id, Serial
  property :description, Text
  property :unit_cost, Float
  property :workshop, Float

  belongs_to :supplier
  belongs_to :category
  has n, :element_materials

end
