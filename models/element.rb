require 'data_mapper'

class Element
  include DataMapper::Resource

  property :id, Serial
  property :title, String, :default => 'Unnamed Element'
  property :reference, String
  property :quantity, Integer, :default => 1
  property :notes, Text
  property :build_start, Date
  property :build_end, Date
  property :contingency, Float, :default => 0.1
  property :overhead, Float, :default => 0.385
  property :profit, Float, :default => 0.1
  property :quote_include, Boolean, :default => true
  property :carpentry, Float, :default => 0.0
  property :steelwork, Float, :default => 0.0
  property :scenic, Float, :default => 0.0
  property :onsite_paint, Float, :default => 0.0
  property :on_site_day, Float, :default => 0.0
  property :draughting, Float, :default => 0.0
  property :project_management, Float, :default => 0.0


  belongs_to :project_version
  has n, :element_materials

end
