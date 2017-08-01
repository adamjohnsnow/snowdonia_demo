require 'data_mapper'

class ElementMaterial
  include DataMapper::Resource

  property :id, Serial
  property :units, Integer, :default => 1
  property :notes, Text
  property :markup, Float, :default => 0
  property :units_after_drawing, Integer

  belongs_to :element
  belongs_to :material

end
