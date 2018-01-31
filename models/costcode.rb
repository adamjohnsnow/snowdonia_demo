require 'data_mapper'

class Costcode
  include DataMapper::Resource

  property :id, Serial
  property :code, String, :unique => true
  property :description, String

  belongs_to :user
  has n, :materials

end
