require 'data_mapper'

class ElementMaterial
  include DataMapper::Resource

  property :id, Serial
  property :units, Integer, :default => 1
  property :notes, String
  property :price, Float
  property :contingency, Float, :default => 0.1
  property :overhead, Float, :default => 0.385
  property :profit, Float, :default => 0.1
  property :units_after_drawing, Integer
  property :subcontract, Boolean, :default => false
  property :last_update, String
  property :mat_order, Integer

  belongs_to :element
  belongs_to :material

end
