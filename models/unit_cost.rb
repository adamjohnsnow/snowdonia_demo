require 'data_mapper'

class UnitCost
  include DataMapper::Resource

  property :id, Serial
  property :type, String, :unique => true

  belongs_to :material

end
