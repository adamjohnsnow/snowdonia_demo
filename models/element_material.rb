require 'data_mapper'

class ElementMaterial
  include DataMapper::Resource

  property :id, Serial
  property :units, Integer, :default => 1
  property :notes, String
  property :price, Float
  property :contingency, Float, :default => 10
  property :overhead, Float, :default => 38.5
  property :profit, Float, :default => 10
  property :subcontractor, Float, :default => 20
  property :markup_defaults, Boolean, :default => true
  property :units_after_drawing, Integer
  property :subcontract, Boolean, :default => false
  property :last_update, String
  property :mat_order, Integer

  belongs_to :element
  belongs_to :material

end
