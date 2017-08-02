require 'data_mapper'

class Element
  include DataMapper::Resource

  property :id, Serial
  property :title, String, :default => 'Unnamed Element'
  property :quantity, Integer, :default => 1
  property :notes, Text
  property :build_start, Date
  property :build_end, Date
  property :markup, Float
  property :quote_include, Boolean, :default => true

  belongs_to :project
  has n, :element_materials

end
