require 'data_mapper'

class ElementMaterial
  include DataMapper::Resource

  property :id, Serial
  property :units, Integer, :default => 1
  property :notes, String
  property :price, Float
  property :contingency, Float
  property :overhead, Float
  property :profit, Float
  property :units_after_drawing, Integer
  property :subcontract, Boolean, :default => false
  property :last_update, String
  property :mat_order, Integer

  belongs_to :element
  belongs_to :material

end
