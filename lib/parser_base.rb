# encoding: UTF-8

class ParserError < Exception

end

module Kernel
  def q(*stuff)
    stuff.each { |thing| $stderr.print(thing.inspect + "\n")}
  end
end


class ParserBase
  def initialize(parsing, restaurant)
    @parsing    = parsing
    @restaurant = restaurant
    @queue   = []
    @done    = []
    @rng = Random.new
    
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO
    @logger.datetime_format = "%Y-%m-%d %H:%M:%S"
    
    @he = HTMLEntities.new
    @agent  = Mechanize.new
    @agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:10.0.1) Gecko/20100101 Firefox/10.0.1'
  end

  def init
    raise ParserError, 'Парсер не переопределяет ParserBase#init'
  end

  def parse(el, doc)
    raise ParserError, 'Парсер не переопределяет ParserBase#parse'
  end

  def queue(url, type=:default)
    @queue.push({
        url: url.to_s,
        type: type
    })
  end

  def run()
    init()
    until @queue.empty?
      sleep 3
      el = @queue.shift()
      download(el)
      @done.push el
    end

    @parsing = Parsing.find(@parsing.id)

    @parsing.parsed_items.each do |pi|
      unless pi.valid?
        raise ParserError, 'Invalid item: ' + pi.inspect + ' errors: ' + pi.errors.inspect
      end
    end

    @parsing.save!

    items_total = @parsing.parsed_items.count
    raise ParserError, 'Спарсено 0 товаров' if items_total == 0
    @parsing.save!
  end

  def download(el)
    url = el[:url]
    puts "GET " + url
    @agent.get(url) do |page|
      parse(el, page.root)
    end
  end

  def get_optset(name, data)
    raise ParserError, 'Парсер попытался сохранить пустой набор опций' if data.nil? || data.empty?
    raise ParserError, 'Парсер попытался сохранить набор опций без названия' if name.nil? || name.empty?

    optset = Optset.make(@restaurant, {'name' => name, 'options' => data})
    if optset.nil?
      raise ParserError, 'Не удалось сохранить набор опций'
    end
    optset
  end

  def get_item()
    @parsing.parsed_items.new
  end

  def get_category(name)
    if name.nil? || name.empty?
      raise ParserError, 'Неверная категория: ' + name.inspect
    end
    MyCategory.find_or_create_by({restaurant_id: @restaurant.id, name: name})
  end

  def save_item(item)
    if item.valid?
      item.save!
    else
      # logger.warn 'Неверный товар: ' + item.inspect
      raise ParserError, 'Неверный товар: ' + "\n" + item.inspect + "\n" + item.errors.inspect
    end
  end

  def logger
    @logger
  end

  def start()
    logger.info 'starting parser ' + self.class.name
    run()
    logger.info 'finished parser ' + self.class.name
  end
end