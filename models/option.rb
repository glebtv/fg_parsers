class Option
  include Mongoid::Document
  include Mongoid::MoneyField

  field :name,  type: String
  money_field :price

  validates_presence_of :name, :price

  embedded_in :optset
end
