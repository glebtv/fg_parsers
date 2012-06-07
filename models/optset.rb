# encoding: UTF-8

require 'digest/sha1'

class Optset
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,    type: String
  field :digest,  type: String

  embeds_many :options
  belongs_to :restaurant

  accepts_nested_attributes_for :options, reject_if: :all_blank, allow_destroy: true

  before_save do
    self.digest = self.get_digest
  end

  def get_digest()
    self.digest = Digest::SHA1.hexdigest({
        name: self.name,
        options: self.options.map { |o| [ o.name, o.price.cents ] }.sort_by { |o| o[0] }
    }.to_s)
  end

  def self.get_hash_digest(h)
    Digest::SHA1.hexdigest({
        name: h['name'],
        options: h['options'].map { |o| [ o[:name], o[:price].cents ] }.sort_by { |o| o[0] }
    }.to_s)
  end

  def self.make(restaurant, data)
    return nil if data['options'].nil? || data['options'].empty?

    digest = self.get_hash_digest(data)
    optset = restaurant.optsets.find_or_initialize_by(digest: digest)
    if optset.persisted?
      if optset.destroyed?
        optset.restore
      end
    else
      optset.name = data['name']
      data['options'].each do |o|
        optset.options.build(name: o[:name], price: o[:price])
      end
      optset.save!
    end
    optset
  end
end
