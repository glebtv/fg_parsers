# encoding: UTF-8

class Parsing
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :restaurant
  has_many :parsed_items
end