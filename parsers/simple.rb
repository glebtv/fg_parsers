# encoding: UTF-8

class ParserSimple < ParserBase
  def init()
    queue('http://gleb.tv/', :start)
  end

  def parse(el, doc)
    # el - это хеш - элемент очереди. см. ParserBase#queue
    # doc - это объект 
    
    u = URI.parse(el[:url])
    if el[:type] == :start
      # добавим в очередь другие страницы ресторана, найденные по меню
      queue(url)
    end
    
    cat_name =  doc.css('#active_menu_item')[0].content.strip
    category = get_category(cat_name)
    
    pizza_opts = get_optset('пицца', ['Сыр', 'Ветчина', 'Помидоры'])
    
    doc.css('#content .product').each do |l|
        item = get_item()
        
        item.img_url = l.css('.product-img a')[0]['href'] unless l.css('.product-img a').empty?
        item.name = l.css('.product-text > h3')[0].content.strip.chomp('.')
        item.short = l.css('.product-text > p')[0].content.strip
        item.price = it.css('.shs-price .shk-price2 .shk-price')[0].content.strip
        item.weight = it.css('.shs-price > b')[0].content.strip
        item.name = item.name + ' - ' + weight
        item.my_category = category
        
        save_item(item)
      end
    end
  end
end