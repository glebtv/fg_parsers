class ParsedItem
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::MoneyField
  
  # Название товара
  field :name, type: String
  
  # Короткое описание товара
  field :short, type: String
  
  # Подробное описание товара (если есть)
  field :long, type: String
  
  # Состав товара (если есть)
  field :composition, type: String
  
  # Вес товара (если есть)
  field :weight, type: String
  
  # Полный URL изображения товара (если есть)
  field :img_url, type: String

  # Цена товара
  money_field :price

  belongs_to :parsing
  belongs_to :optset
  belongs_to :my_category
  
  validates_uniqueness_of :name, scope: :parsing_id
  validates_presence_of :name, :price, :my_category_id
end