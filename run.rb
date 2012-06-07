#!/usr/bin/env ruby
# encoding: UTF-8

require 'bundler'
Bundler.require

ENV["MONGOID_ENV"] = 'development'
Mongoid.load!(File.dirname(__FILE__) + '/mongoid.yml')
# Закомментируйте, чтобы увидеть лог запросов к MongoDB
Mongoid.logger = nil

Dir.glob(File.dirname(__FILE__) + '/lib/*.rb').each do |file|
  require(file)
end
Dir.glob(File.dirname(__FILE__) + '/models/*.rb').each do |file|
  require(file)
end

slug = ARGV[0].to_url
parser_name = 'Parser' + slug.underscore.camelize

puts "Запускаю парсер. Файл: /parsers/#{slug}.rb, Класс: #{parser_name} "
require "./parsers/#{slug}.rb"

Restaurant.destroy_all
Parsing.destroy_all
ParsedItem.destroy_all
Optset.destroy_all
MyCategory.destroy_all

restaurant = Restaurant.create!(name: 'test restaurant')
parsing = restaurant.parsings.create!
parser = parser_name.constantize.new(parsing, restaurant)
parser.start

parsing = Parsing.find(parsing.id)

puts Hirb::Helpers::AutoTable.render(restaurant.my_categories, fields: [:id, :name])

restaurant.optsets.each do |optset|
  puts "Набор опций #{optset.name} (#{optset.id})"
  puts Hirb::Helpers::AutoTable.render(optset.options, fields: [:id, :name, :price])
end

# :long, :composition, :weight, - не отображаются в таблице (не уместились)
puts Hirb::Helpers::AutoTable.render(parsing.parsed_items, resize: true, max_width: 200, fields: [:name, :price, :short, :img_url, :optset_id, :my_category_id])
