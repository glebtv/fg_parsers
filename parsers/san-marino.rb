# encoding: UTF-8

class ParserSanMarino < ParserBase
  def init()
    # Очередь обрабатывается в порядке добавления.
    # Сначала спарсим опции, они будут нужны дальше
    queue('http://www.smpizza.ru/menu/pizza/ingredients/', :optset)

    # Парсим начальную страницу - там список разделов
    queue('http://www.smpizza.ru/menu/pizza/', :start)
  end

  def parse(el, doc)
    u = URI.parse(el[:url])
    if el[:type] == :start
      doc.css('div#workarea-inner div.sections > a').each do |a|
        url = (u + a['href']).to_s
        if url != el[:url]
          queue(url)
        end
      end
    elsif el[:type] == :optset
      parse_optset(el, doc, u)
    else
      parse_items(el, doc, u)
    end
  end

  def parse_items(el, doc, u)
    cat_name = doc.css('#workarea h1#pagetitle')[0].content.strip
    if cat_name == 'Пицца'
      category = {}
      category[33] = get_category(cat_name + ' (33 см)')
      category[41] = get_category(cat_name + ' (41 см)')
    else
      category = get_category(cat_name)
    end

    doc.css('div#workarea div#menu div.menu-pizza').each do |i|
      i.css('.menu-pizza-info .menu-pizza-price').each do |it|
        item = get_item()
        item.price = it.css('span')[0].content.strip

        name = i.css('.menu-pizza-name')[0].content.strip

        info_t = it.children[0].content
        if info_t.index('/').nil?
          weight = info_t.strip
        else
          info = info_t.split('/')
          weight = info[1].strip
        end

        if weight != '+ доп.ингрид.' && !weight.index('г').nil?
          item.weight = weight
        end

        if cat_name == 'Пицца'
          sz_match = info_t.strip.match(/(\d{2})(?: )?см/)
          if sz_match.nil?
            if info[1].strip == '1100 г'
              # обойдем баг сайта ресторана
              size = 41
            else
              # А этот баг мы еще не встретили
              raise ParserError, 'Пицца без размера'
            end
          else
            size = sz_match[0].to_i
          end
          item.name = "#{name} - #{size.to_s} см"
          item.my_category = category[size]
          item.optset = @optsets[size]
        else
          if i.css('.menu-pizza-info .menu-pizza-price').length > 1
            item.name = "#{name} - #{weight}"
          else
            item.name = name
          end

          item.my_category = category
        end

        item.short = i.css('.menu-pizza-text')[0].content

        # Разрешает относительные URL
        item.img_url = (u + i.css('.menu-pizza-img a')[0]['href']).to_s

        save_item(item)
      end
    end
  end

  def parse_optset(el, doc, u)
    # У ресторана на странице опций пицца 31 см, а в каталоге 33, предполагаем что в каталоге - правильно.

    options = {
        33 => [],
        41 => [],
    }

    i = 0
    doc.css('div#workarea-inner div#menu .menu-ingredients').each do |el|
      if el.css('.menu-ingredients-name span')[0].nil?
        p el.to_xhtml
        p el.css('.menu-ingredients-name span')
      end
      name = el.css('.menu-ingredients-name span')[0].content.gsub(/ +/, ' ').strip
      price = el.css('.menu-ingredients-price')[0].content.to_money
      if i == 0
        if name != 'Сыр ( для пиццы 31см)'
          raise ParserError, 'Наборы опций изменились непредусмотренным образом'
        end
        name = 'Сыр'
      end

      if i == 1
        if name != 'Сыр (для пиццы 41 см.)'
          raise ParserError, 'Наборы опций изменились непредусмотренным образом'
        end
        name = 'Сыр'
      end

      if i % 2 == 0
        options[33].push({name: name, price: price})
      else
        options[41].push({name: name, price: price})
      end

      i += 1
    end

    @optsets = {
        33 => get_optset('пицца 33см', options[33]),
        41 => get_optset('пицца 41см', options[41]),
    }
  end

end