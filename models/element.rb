require 'data_mapper'

class Element
  include DataMapper::Resource

  property :id, Serial
  property :title, String, :default => 'Unnamed Element'
  property :reference, String
  property :client_ref, String
  property :quantity, Integer, :default => 1
  property :notes, Text
  property :build_start, Date
  property :build_end, Date
  property :contingency, Float, :default => 0.1
  property :overhead, Float, :default => 0.385
  property :profit, Float, :default => 0.1
  property :quote_include, Boolean, :default => true
  property :component, Boolean, :default => false
  property :el_order, Integer

  belongs_to :project_version
  has n, :element_materials
  has 1, :element_labour

end
