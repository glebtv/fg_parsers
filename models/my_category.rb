# encoding: UTF-8

class MyCategory
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug

  acts_as_nested_set

  field :name,      type: String
  field :enabled,   type: Boolean, default: true
  field :itemcount, type: Integer, default: 0
  slug :name, scope: :restaurant

  belongs_to :restaurant
  
  validates_presence_of :name, :slug
  validates_uniqueness_of :name, scope: [:restaurant_id]
  attr_accessible :slug, :name, :enabled, :restaurant_id

  scope :enabled, where(enabled: true, itemcount: {'$gt' => 0})

  before_validation do |doc|
    if self.slug.nil? || self.slug.empty?
      doc.build_slug
    end
  end
end
