# encoding: UTF-8

class ParserCorleonePizza < ParserBase
  def init()
    queue('http://www.corleone.ru/', :start)
  end

  def parse(el, doc)
    u = URI.parse(el[:url])
    if el[:type] == :start
      doc.css('div#content div.cont_menu ul.menu-h li a').each do |a|
        url = (u + a['href']).to_s
        if url != el[:url]
          queue(url)
        end
      end
    end

    cat_name =  doc.css('div#content div.cont_menu ul.menu-h li.active a')[0].content
    if el[:type] == :start
      if cat_name != 'Пицца'
        raise ParserError, 'Изменилась структура категорий'
      end
      category = {}
      category['20'] = get_category(cat_name + ' (20 см)')
      category['30'] = get_category(cat_name + ' (30 см)')
      category['40'] = get_category(cat_name + ' (40 см)')
    else
      category = get_category(cat_name)
    end

    # Опции есть только у пиццы. Пицца на начальной странице
    if el[:type] == :start
      options = []
      doc.css('div#content div.content div.product_param form div.shs-price select.addparam').each do |option|
        base_el = option.parent.css('span.shk-price2 span.shk-price')
        base_price = base_el[0].content.to_money
        option.css('option').each do |o|
          name = o.content.to_s.strip
          next if name == ''
          price_offset = o['value'].split('__')[1].to_money
          options.push({name: name, price: base_price + price_offset})
        end
      end
      pizza_opts = get_optset('пицца', options.uniq)
    end

    doc.css('#content .product').each do |l|
      l.css('div.product_param').each do |it|
        item = get_item()
        # q l.css('.product-img a')[0]
        item.img_url = l.css('.product-img a')[0]['href'] unless l.css('.product-img a').empty?
        item.name = l.css('.product-text > h3')[0].content.strip.chomp('.')
        item.short = l.css('.product-text > p')[0].content.strip
        price = it.css('.shs-price .shk-price2 .shk-price')[0].content.strip
        # q price, price.to_money.cents, !price.index(' ').nil?
        if price.to_money.cents > 10_000_00 && !price.index("\r\n").nil?
          price = price.split("\r\n")[1]
        end
        item.price = price.to_money
        weight = it.css('.shs-price > b')[0].content.strip
        if el[:type] == :start
          sz_match = weight.match(/(?:Размер: )?(\d{2}) см/)
          size = sz_match[1].to_s
          item.my_category = category[size]
          item.name = item.name + ' - ' + size + 'см'
          item.optset = pizza_opts
        else
          item.name = item.name + ' - ' + weight
          item.my_category = category
        end
        
        # У этого ресторана есть несколько повторяющихся товаров
        if @parsing.parsed_items.where(name: item.name).first.nil?
          save_item(item)
        end
      end
    end
  end
end