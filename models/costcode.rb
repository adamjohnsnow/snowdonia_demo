require 'data_mapper'

class Costcode
  include DataMapper::Resource

  property :id, Serial
  property :code, String, :unique => true
  property :description, String
  property :owner, String

  has n, :materials

end
