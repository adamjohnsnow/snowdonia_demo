require 'data_mapper'

class ElementLabour
  include DataMapper::Resource

  property :id, Serial
  property :carpentry, Float, :default => 0.0
  property :steelwork, Float, :default => 0.0
  property :scenic, Float, :default => 0.0
  property :onsite_paint, Float, :default => 0.0
  property :onsite_day, Float, :default => 0.0
  property :drafting, Float, :default => 0.0
  property :project_management, Float, :default => 0.0
  property :carpentry_cost, Float, :default => 180.0
  property :steelwork_cost, Float, :default => 180.0
  property :scenic_cost, Float, :default => 180.0
  property :onsite_paint_cost, Float, :default => 200.0
  property :onsite_day_cost, Float, :default => 200.0
  property :drafting_cost, Float, :default => 180.0
  property :project_management_cost, Float, :default => 180.0

  belongs_to :element

end
