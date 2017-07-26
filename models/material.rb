require 'data_mapper'

class Material
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :unit_cost, Float

  belongs_to :supplier
  belongs_to :category
  has n, :elements, through: Resource

end
