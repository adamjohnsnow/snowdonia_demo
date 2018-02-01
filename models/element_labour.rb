require 'data_mapper'

class ElementLabour
  include DataMapper::Resource

  property :id, Serial
  property :carpentry, Float, :default => 0.0
  property :steelwork, Float, :default => 0.0
  property :scenic, Float, :default => 0.0
  property :onsite_paint, Float, :default => 0.0
  property :on_site_day, Float, :default => 0.0
  property :draughting, Float, :default => 0.0
  property :project_management, Float, :default => 0.0
  property :carpentry_cost, Float, :default => 0.0
  property :steelwork_cost, Float, :default => 0.0
  property :scenic_cost, Float, :default => 0.0
  property :onsite_paint_cost, Float, :default => 0.0
  property :on_site_day_cost, Float, :default => 0.0
  property :draughting_cost, Float, :default => 0.0
  property :project_management_cost, Float, :default => 0.0

  belongs_to :element

end
