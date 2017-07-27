require 'data_mapper'

class Element
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :quantity, Integer
  property :notes, Text
  property :build_start, Date
  property :build_end, Date
  property :markup, Float
  property :quote_include, Boolean

  belongs_to :project
  has n, :materials, through: Resource

end
