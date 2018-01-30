require 'data_mapper'

class Material
  include DataMapper::Resource

  property :id, Serial
  property :description, Text
  property :supplier, Text
  property :current_price, Float
  property :project_id, Integer
  property :unit, Text
  property :price_updated, Date, :default => Date.today
  property :global, Boolean, :default => false

  belongs_to :costcode
  has n, :element_materials

  def update_price(new_price)
    self.current_price = new_price
    self.price_updated = Date.today
    self.save!
  end
end
