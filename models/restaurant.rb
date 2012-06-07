# encoding: UTF-8

class Restaurant
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name
  
  has_many :parsings
  has_many :optsets
  has_many :my_categories
end
