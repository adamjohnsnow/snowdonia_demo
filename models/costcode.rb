require 'data_mapper'

class Costcode
  include DataMapper::Resource

  property :id, Serial
  property :type, String, :unique => true

  has n, :materials

end
